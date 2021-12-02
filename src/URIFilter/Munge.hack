/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;
use namespace HH\Lib\Dict;
use namespace HH\Shapes;
use namespace Facebook\TypeAssert;

class HTMLPurifier_URIFilter_Munge extends HTMLPurifier\HTMLPurifier_URIFilter {
	/**
	 * @type string
	 */
	public string $name = 'Munge';

	/**
	 * @type bool
	 */
	public bool $post = true;

	/**
	 * @type string
	 */
	private string $target = '';

	/**
	 * @type HTMLPurifier_URIParser
	 */
	private ?HTMLPurifier\HTMLPurifier_URIParser $parser;

	/**
	 * @type bool
	 */
	private bool $doEmbed = false;

	/**
	 * @type string
	 */
	private string $secretKey = '';

	/**
	 * @type dict
	 */
	protected dict<string, mixed> $replace = dict[];

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool
	 */
	public function prepare(HTMLPurifier\HTMLPurifier_Config $config): bool {
		$target = Shapes::toArray($config->def->defaults)['URI.'.$this->name];
		if (!($target is string)) {
			throw new \Exception('Target is not a string');
		}
		$this->target = $target;
		$this->parser = new HTMLPurifier\HTMLPurifier_URIParser();
		$this->doEmbed = $config->def->defaults['URI.MungeResources'];
		$this->secretKey = $config->def->defaults['URI.MungeSecretKey'];
		if ($this->secretKey && !\function_exists('hash_hmac')) {
			throw new \Exception("Cannot use %URI.MungeSecretKey without hash_hmac support.");
		}
		return true;
	}

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function filter(
		inout HTMLPurifier\HTMLPurifier_URI $uri,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): bool {
		if ($context->get('EmbeddedURI', true) && !$this->doEmbed) {
			return true;
		}

		$scheme_obj = $uri->getSchemeObj($config, $context);
		if (!$scheme_obj) {
			return true;
		} // ignore unknown schemes, maybe another postfilter did it
		if (!$scheme_obj->browsable) {
			return true;
		} // ignore non-browseable schemes, since we can't munge those in a reasonable way
		if ($uri->isBenign($config, $context)) {
			return true;
		} // don't redirect if a benign URL

		$this->makeReplace($uri, $config, $context);
		$this->replace = Dict\map($this->replace, $val ==> \rawurlencode((string)$val));

		$new_uri = \strtr($this->target, $this->replace);
		if ($this->parser is null) throw new \Error("Parser was never properly initialized for Munge URI Filter.");
		$new_uri = $this->parser->parse($new_uri);
		// don't redirect if the target host is the same as the
		// starting host
		if ($uri->host === $new_uri->host) {
			return true;
		}
		$uri = $new_uri; // overwrite
		return true;
	}

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 */
	protected function makeReplace(
		HTMLPurifier\HTMLPurifier_URI $uri,
		HTMLPurifier\HTMLPurifier_Config $_config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): void {
		$string = $uri->toString();
		// always available
		$this->replace['%s'] = $string;
		$this->replace['%r'] = $context->get('EmbeddedURI', true);
		$token = TypeAssert\instance_of(Token\HTMLPurifier_Token_Tag::class, $context->get('CurrentToken', true));
		$this->replace['%n'] = $token ? $token->name : null;
		$this->replace['%m'] = $context->get('CurrentAttr', true);
		$this->replace['%p'] = $context->get('CurrentCSSProperty', true);
		// not always available
		if ($this->secretKey) {
			$this->replace['%t'] = \hash_hmac("sha256", $string, $this->secretKey);
		}
	}
}
