/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\Str;

/**
 * Base class for all validating attribute definitions.
 */
abstract class HTMLPurifier_AttrDef {
	// Tells us whether or not an HTML attribute is minimized.
	public bool $minimized = false;

	//Tells us whether or not an HTML attribute is required
	public bool $required = false;

	// Validates and cleans passed string according to a definition
	abstract public function validate(
		string $string,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): string;

	// Convenience method that parses a string as if it were CDATA.
	public function parseCDATA(string $string): string {
		$string = Str\trim($string);
		$string = Str\replace_every($string, dict["\n" => ' ', "\t" => ' ', "\r" => ' ']);
		return $string;
	}

	//Factory method for creating this class from a string.
	public function make(string $_string): HTMLPurifier_AttrDef {
		return $this;
	}

	// Removes spaces from rgb(0, 0, 0) so that shorthand CSS properties work properly.
	protected function mungeRgb(string $string): string {
		$p = '\s*(\d+(\.\d+)?([%]?))\s*';

		if (\preg_match('/(rgba|hsla)\(/', $string)) {
			return \preg_replace('/(rgba|hsla)\('.$p.','.$p.','.$p.','.$p.'\)/', '\1(\2,\5,\8,\11)', $string);
		}

		return \preg_replace('/(rgb|hsl)\('.$p.','.$p.','.$p.'\)/', '\1(\2,\5,\8)', $string);
	}

	// Parses a possibly escaped CSS string and returns the "pure" version of it.
	protected function expandCSSEscape(string $string): string {
		// flexibly parse it
		$ret = '';
		for ($i = 0, $c = Str\length($string); $i < $c; $i++) {
			if ($string[$i] === '\\') {
				$i++;
				if ($i >= $c) {
					$ret .= '\\';
					break;
				}
				if (\ctype_xdigit($string[$i])) {
					$code = $string[$i];
					for ($a = 1, $i++; $i < $c && $a < 6; $i++, $a++) {
						if (!\ctype_xdigit($string[$i])) {
							break;
						}
						$code .= $string[$i];
					}
					// We have to be extremely careful when adding
					// new characters, to make sure we're not breaking
					// the encoding.
					$char = HTMLPurifier_Encoder::unichr(\hexdec($code));
					if (HTMLPurifier_Encoder::cleanUTF8($char) === '') {
						continue;
					}
					$ret .= $char;
					if ($i < $c && Str\trim($string[$i]) !== '') {
						$i--;
					}
					continue;
				}
				if ($string[$i] === "\n") {
					continue;
				}
			}
			$ret .= $string[$i];
		}
		return $ret;
	}
}
