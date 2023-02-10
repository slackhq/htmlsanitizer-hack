/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;
use namespace HH\Lib\{Regex, Str};

/**
 * Forgivingly lexes HTML markup into tokens. 
 */
class HTMLPurifier_Lexer {
	/**
	* Whether or not this lexer implements line-number/column-number tracking.
	*/
	public bool $tracksLineNumbers = false;
	public HTMLPurifier_EntityParser $entity_parser;

	//returns a Lexer object
	public static function create(HTMLPurifier_Config $config): HTMLPurifier_Lexer {
		//no need to do check if config is instance of HTMLPurifier_Config
		$lexer = $config->def->defaults['Core.LexerImpl'];
		$needs_tracking = $config->def->defaults['Core.MaintainLineNumbers'] ||
			$config->def->defaults['Core.CollectErrors'];

		$inst = null;
		if (\is_object($lexer) && $lexer is HTMLPurifier_Lexer) {
			$inst = $lexer;
		} else {
			if (!$lexer) {
				do {
					// if ($needs_tracking) {
					//     $lexer = 'DirectLex';
					//     break;
					// }
					if (
						\class_exists('DOMDocument', false) &&
						\method_exists('DOMDocument', 'loadHTML') &&
						!\extension_loaded('domxml')
					) {
						$lexer = 'DOMLex';
					} // } else {
					//     $lexer = 'DirectLex';
					// }
				} while (0);
			}
			switch ($lexer) {
				case 'DOMLex':
					$inst = new Lexer\HTMLPurifier_Lexer_DOMLex();
					break;
				// case 'DirectLex':
				//     $inst = new Lexer\HTMLPurifier_Lexer_DirectLex();
				//     break;
				// case 'PHP5':
				//     $inst = new HTMLPurifier_Lexer_PHP5();
				//     break;
				default:
					throw new \Exception("Cannot instantiate unrecognized Lexer type");
			}
		}

		if (!$inst) {
			throw new \Exception("No lexer was instantiated");
		}

		//tracksLineNumber access throwing an error
		// if ($needs_tracking && !($inst->tracksLineNumbers)) {
		//     throw new \Exception(
		//         'Cannot use lexer that does not support line numbers with ' .
		//         'Core.MaintainLineNumbers or Core.CollectErrors (use DirectLex instead)'
		//     );
		// }
		return $inst;

	}
	public function __construct() {
		$this->entity_parser = new HTMLPurifier_EntityParser();
	}

	protected dict<string, string> $special_entity2str = dict[
		'&quot;' => '"',
		'&amp;' => '&',
		'&lt;' => '<',
		'&gt;' => '>',
		'&#39;' => "'",
		'&#039;' => "'",
		'&#x27;' => "'",
	];

	public function parseText(string $string, HTMLPurifier_Config $config): string {
		return $this->parseData($string, false, $config);
	}

	public function parseAttr(string $string, HTMLPurifier_Config $config): string {
		return $this->parseData($string, true, $config);
	}

	/**
	 * Parses special entities into the proper characters.
	 *
	 * This string will translate escaped versions of the special characters
	 * into the correct ones.
	 *
	 * @param string $string String character data to be parsed.
	 * @return string Parsed character data.
	 */
	public function parseData(string $string, bool $is_attr, HTMLPurifier_Config $config): string {
		// following functions require at least one character
		if ($string === '') {
			return '';
		}

		// subtracts amps that cannot possibly be escaped
		$num_amp = \substr_count($string, '&') -
			\substr_count($string, '& ') -
			($string[\strlen($string) - 1] === '&' ? 1 : 0);

		if (!$num_amp) {
			return $string;
		} // abort if no entities
		$num_esc_amp = \substr_count($string, '&amp;');
		$string = \strtr($string, $this->special_entity2str);

		// code duplication for sake of optimization, see above
		$num_amp_2 = \substr_count($string, '&') -
			\substr_count($string, '& ') -
			($string[\strlen($string) - 1] === '&' ? 1 : 0);

		if ($num_amp_2 <= $num_esc_amp) {
			return $string;
		}

		// hmm... now we have some uncommon entities. Use the callback.
		if ($config->def->defaults['Core.LegacyEntityDecoder']) {
			$string = $this->entity_parser->substituteSpecialEntities($string);
		} else {
			if ($is_attr) {
				$string = $this->entity_parser->substituteAttrEntities($string);
			} else {
				$string = $this->entity_parser->substituteTextEntities($string);
			}
		}
		return $string;
	}

	/**
	 * Lexes an HTML string into tokens.
	 * @param $string String HTML.
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return HTMLPurifier_Token[] array representation of HTML.
	 */
	public function tokenizeHTML(
		string $string,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): vec<HTMLPurifier_Token> {
		\trigger_error('Call to abstract class', \E_USER_ERROR);
		return vec<HTMLPurifier_Token>[];
	}

	/**
	 * Translates CDATA sections into regular sections (through escaping).
	 * @param string $string HTML string to process.
	 * @return string HTML with CDATA sections escaped.
	 */
	protected static function escapeCDATA(string $string): string {
		return Regex\replace_with($string, re"/<!\[CDATA\[(.+?)\]\]>/s", $m ==> static::CDATACallback($m[1]));
	}

	/**
	 * Special CDATA case that is especially convoluted for <script>
	 * @param string $string HTML string to process.
	 * @return string HTML with CDATA sections escaped.
	 */
	protected static function escapeCommentedCDATA(string $string): string {
		return Regex\replace_with(
			$string,
			re"#<!--//--><!\[CDATA\[//><!--(.+?)//--><!\]\]>#s",
			$m ==> static::CDATACallback($m[1]),
		);
	}

	/**
	 * Special Internet Explorer conditional comments should be removed.
	 * @param string $string HTML string to process.
	 * @return string HTML with conditional comments removed.
	 */
	protected static function removeIEConditional(string $string): string {
		return \preg_replace(
			'#<!--\[if [^>]+\]>.*?<!\[endif\]-->#si', // probably should generalize for all strings
			'',
			$string,
		);
	}

	/**
	 * Callback function for escapeCDATA() that does the work.
	 *
	 * @warning Though this is public in order to let the callback happen,
	 *          calling it directly is not recommended.
	* @param string $matches the inside of the CDATA section.
	* @return string Escaped internals of the CDATA section.
	 */
	public static function CDATACallback(string $match): string {
		// not exactly sure why the character set is needed, but whatever
		return \htmlspecialchars($match, \ENT_COMPAT, 'UTF-8');
	}

	/**
	 * Takes a piece of HTML and normalizes it by converting entities, fixing
	 * encoding, extracting bits, and other good stuff.
	 * @param string $html HTML.
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 * @todo Consider making protected
	 */
	public function normalize(string $html, HTMLPurifier_Config $config, HTMLPurifier_Context $context): string {
		// normalize newlines to \n
		if ($config->def->defaults['Core.NormalizeNewlines']) {
			$html = \str_replace("\r\n", "\n", $html);
			$html = \str_replace("\r", "\n", $html);
		}

		if ($config->def->defaults['HTML.Trusted']) {
			// escape convoluted CDATA
			$html = $this::escapeCommentedCDATA($html);
		}

		// escape CDATA
		$html = $this::escapeCDATA($html);

		$html = $this::removeIEConditional($html);

		// extract body from document if applicable
		if ($config->def->defaults['Core.ConvertDocumentToFragment']) {
			$e = false;
			if ($config->def->defaults['Core.CollectErrors']) {
				$e = $context->get('ErrorCollector');
			}
			$new_html = $this->extractBody($html);
			if ($e && $new_html != $html) {
				echo "Lexer: Extracted body \r\n";
				// $e->send(\E_WARNING, 'Lexer: Extracted body');
			}
			$html = $new_html;
		}

		// expand entities that aren't the big five
		if ($config->def->defaults['Core.LegacyEntityDecoder']) {
			$html = $this->entity_parser->substituteNonSpecialEntities($html);
		}

		// clean into wellformed UTF-8 string for an SGML context: this has
		// to be done after entity expansion because the entities sometimes
		// represent non-SGML characters (horror, horror!)
		$html = HTMLPurifier_Encoder::cleanUTF8($html);

		// if processing instructions are to removed, remove them now
		if ($config->def->defaults['Core.RemoveProcessingInstructions']) {
			$html = \preg_replace('#<\?.+?\?>#s', '', $html);
		}

		$hidden_elements = $config->def->defaults['Core.HiddenElements'];
		// $hidden_elements = TypeCoerce\match<dict<string, bool>>($config->get('Core.HiddenElements'));
		//hidden is definitely dict<string, bool>
		//if hidden elements is not null and config specifies to aggressively remove script for non trusted user inputs
		if (
			$hidden_elements &&
			$config->def->defaults['Core.AggressivelyRemoveScript'] &&
			!(
				$config->def->defaults['HTML.Trusted'] ||
				!$config->def->defaults['Core.RemoveScriptContents'] ||
				!$hidden_elements["script"]
			)
		) {
			$html = \preg_replace('#<script[^>]*>.*?</script>#i', '', $html);
		}

		return $html;
	}

	/**
	 * Takes a string of HTML (fragment or document) and returns the content
	 * @todo Consider making protected
	 */
	public function extractBody(string $html): string {
		// If the html doesn't even contain the start of a body tag, the regex on line 289 will never match.
		// This can lead to catastrophic backtracking, which has caused errors in the past, so let's just avoid that altogehter
		if (Str\contains($html, "<body")){
			$matches = vec[];
			$error = null;
			$result = \preg_match_with_matches_and_error('|(.*?)<body[^>]*>(.*)</body>|is', $html, inout $matches, inout $error);
			if ($error is nonnull) {
				// Adding some better error tracing here to get more info out of what's wrong with the regex on line 289
				// The error codes can be found here: https://github.com/facebook/hhvm/blob/c5da95da0bd1f0ba9524e6a6e020ab824c1e75b0/hphp/runtime/base/preg.h#L42
				throw new \Error("Error in preg_match_with_matches_and_error: $error", \E_USER_WARNING);
			}
			else if ($result) {
				// Make sure it's not in a comment
				$comment_start = \strrpos($matches[1], '<!--');
				$comment_end = \strrpos($matches[1], '-->');
				if ($comment_start === false || ($comment_end !== false && $comment_end > $comment_start)) {
					return $matches[2];
				}
			}
		}
		return $html;
	}

}
