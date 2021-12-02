//Created by Nikita Ashok on 6/18/20.
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Dict, Str};

// Enum = Enumerated
/**
 * Validates a keyword against a list of valid values.
 * @warning The case-insensitive compare of this function uses PHP's
 *          built-in strtolower and ctype_lower functions, which may
 *          cause problems with international comparisons
 */
class HTMLPurifier_AttrDef_Enum extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Lookup table of valid values.
	 * @type array
	 * @todo Make protected
	 */
	public vec<string> $valid_values = vec[];

	/**
	 * Bool indicating whether or not enumeration is case sensitive.
	 * @note In general this is always case insensitive.
	 */
	protected bool $case_sensitive = false; // values according to W3C spec

	/**
	 * @param array $valid_values List of valid values
	 * @param bool $case_sensitive Whether or not case sensitive
	 */
	public function __construct(vec<string> $valid_values = vec[], bool $case_sensitive = false) {
		$this->valid_values = $valid_values;
		$this->case_sensitive = $case_sensitive;
	}

	/**
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string
	 */
	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$string = Str\trim($string);
		if (!$this->case_sensitive) {
			// we may want to do full case-insensitive libraries
			$string = \ctype_lower($string) ? $string : Str\lowercase($string);
		}
		$result = C\contains($this->valid_values, $string);

		return $result ? $string : '';
	}

	/**
	 * @param string $string In form of comma-delimited list of case-insensitive
	 *      valid values. Example: "foo,bar,baz". Prepend "s:" to make
	 *      case sensitive
	 * @return HTMLPurifier_AttrDef_Enum
	 */
	public function make(string $string): HTMLPurifier_AttrDef_Enum {
		if (Str\length($string) > 2 && $string[0] == 's' && $string[1] == ':') {
			$string = Str\slice($string, 2);
			$sensitive = true;
		} else {
			$sensitive = false;
		}
		$values = Str\split(',', $string);
		return new HTMLPurifier_AttrDef_Enum($values, $sensitive);
	}
}
