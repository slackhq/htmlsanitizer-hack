// Created by Nikita Ashok on 6/18/20;
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};
/**
 * Validates the HTML attribute lang, effectively a language code.
 * @note Built according to RFC 3066, which obsoleted RFC 1766
 */
class HTMLPurifier_AttrDef_Lang extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $_config,
		HTMLPurifier\HTMLPurifier_Context $_context,
	): string {
		$string = Str\trim($string);
		if (!$string) {
			return '';
		}

		$subtags = Str\split('-', $string);
		$num_subtags = C\count($subtags);

		if ($num_subtags == 0) { // sanity check
			return '';
		}

		// process primary subtag : $subtags[0]
		$length = Str\length($subtags[0]);
		switch ($length) {
			case 0:
				return '';
			case 1:
				if (!($subtags[0] == 'x' || $subtags[0] == 'i')) {
					return '';
				}
				break;
			case 2:
			case 3:
				if (!\ctype_alpha($subtags[0])) {
					return '';
				} elseif (!\ctype_lower($subtags[0])) {
					$subtags[0] = Str\lowercase($subtags[0]);
				}
				break;
			default:
				return '';
		}

		$new_string = $subtags[0];
		if ($num_subtags == 1) {
			return $new_string;
		}

		// process second subtag : $subtags[1]
		$length = Str\length($subtags[1]);
		if ($length == 0 || ($length == 1 && $subtags[1] != 'x') || $length > 8 || !\ctype_alnum($subtags[1])) {
			return $new_string;
		}
		if (!\ctype_lower($subtags[1])) {
			$subtags[1] = Str\lowercase($subtags[1]);
		}

		$new_string .= '-'.$subtags[1];
		if ($num_subtags == 2) {
			return $new_string;
		}

		// process all other subtags, index 2 and up
		for ($i = 2; $i < $num_subtags; $i++) {
			$length = Str\length($subtags[$i]);
			if ($length == 0 || $length > 8 || !\ctype_alnum($subtags[$i])) {
				return $new_string;
			}
			if (!\ctype_lower($subtags[$i])) {
				$subtags[$i] = Str\lowercase($subtags[$i]);
			}
			$new_string .= '-'.$subtags[$i];
		}
		return $new_string;
	}
}
