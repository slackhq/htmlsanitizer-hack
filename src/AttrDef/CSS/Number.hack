/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates a number as defined by the CSS spec.
 */
class HTMLPurifier_AttrDef_CSS_Number extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Indicates whether or not only positive values are allowed.
	 */
	protected bool $non_negative = false;

	/**
	 * @param bool $non_negative indicates whether negatives are forbidden
	 */
	public function __construct(bool $non_negative = false): void {
		$this->non_negative = $non_negative;
	}

	public function validate(
		string $number,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$number = $this->parseCDATA($number);

		if ($number === '') {
			return '';
		}
		if ($number === '0') {
			return '0';
		}

		$sign = '';
		switch ($number[0]) {
			case '-':
				if ($this->non_negative) {
					return '';
				}
				$sign = '-';
				// FALLTHROUGH
			case '+':
				$number = Str\slice($number, 1);
				// FALLTHROUGH
			default: // Do nothing (required in newer hhvm versions)
		}

		if (\ctype_digit($number)) {
			$number = Str\trim_left($number, '0');
			return $number ? $sign.$number : '0';
		}

		// Period is the only non-numeric character allowed
		if (!Str\contains($number, '.')) {
			return '';
		}

		list($left, $right) = Str\split($number, '.', 2);

		if ($left === '' && $right === '') {
			return '';
		}
		if ($left !== '' && !\ctype_digit($left)) {
			return '';
		}

		$left = Str\trim_left($left, '0');
		$right = Str\trim_right($right, '0');

		if ($right === '') {
			return $left ? $sign.$left : '0';
		} else if (!\ctype_digit($right)) {
			return '';
		}
		return $sign.$left.'.'.$right;
	}
}
