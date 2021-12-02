/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

/**
 * Validates the value for the CSS property text-decoration
 * @note This class could be generalized into a version that acts sort of
 *       like Enum except you can compound the allowed values.
 */
class HTMLPurifier_AttrDef_CSS_TextDecoration extends HTMLPurifier\HTMLPurifier_AttrDef {

	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$allowed_values = dict[
			'line-through' => true,
			'overline' => true,
			'underline' => true,
		];

		$string = Str\lowercase($this->parseCDATA($string));

		if ($string === 'none') {
			return $string;
		}

		$parts = Str\split($string, ' ');
		$final = '';
		foreach ($parts as $part) {
			if (C\contains_key($allowed_values, $part)) {
				$final .= $part.' ';
			}
		}
		$final = Str\trim_right($final);
		return $final;
	}
}
