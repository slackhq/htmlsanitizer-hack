/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\Str;

/**
 * Validates a MultiLength as defined by the HTML spec.
 *
 * A multilength is either a integer (pixel count), a percentage, or
 * a relative number.
 */
class HTMLPurifier_AttrDef_HTML_MultiLength extends AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Length {

	/**
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$string = Str\trim($string);
		if ($string === '') {
			return '';
		}

		$parent_result = parent::validate($string, $config, $context);
		if ($parent_result !== '') {
			return $parent_result;
		}

		$length = Str\length($string);
		$last_char = $string[$length - 1];

		if ($last_char !== '*') {
			return '';
		}

		$int = Str\slice($string, 0, $length - 1);

		if ($int == '') {
			return '*';
		}
		if (!\ctype_digit($int)) {
			return '';
		}

		$int = (int)$int;
		if ($int < 0) {
			return '';
		}
		if ($int == 0) {
			return '0';
		}
		if ($int == 1) {
			return '*';
		}
		return ((string)$int).'*';
	}
}
