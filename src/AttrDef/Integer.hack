// Created by Nikita Ashok on 7/7/20;
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates an integer.
 * @note While this class was modeled off the CSS definition, no currently
 *       allowed CSS uses this type.  The properties that do are: widows,
 *       orphans, z-index, counter-increment, counter-reset.  Some of the
 *       HTML attributes, however, find use for a non-negative version of this.
 */
class HTMLPurifier_AttrDef_Integer extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Whether or not negative values are allowed.
	 * @type bool
	 */
	protected bool $negative = true;

	/**
	 * Whether or not zero is allowed.
	 * @type bool
	 */
	protected bool $zero = true;

	/**
	 * Whether or not positive values are allowed.
	 * @type bool
	 */
	protected bool $positive = true;

	/**
	 * @param $negative Bool indicating whether or not negative values are allowed
	 * @param $zero Bool indicating whether or not zero is allowed
	 * @param $positive Bool indicating whether or not positive values are allowed
	 */
	public function __construct(bool $negative = false, bool $zero = false, bool $positive = true) {
		$this->negative = $negative;
		$this->zero = $zero;
		$this->positive = $positive;
	}

	/**
	 * @param string $integer
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string
	 */
	public function validate(
		string $integer,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$integer = $this->parseCDATA($integer);
		if ($integer === '') {
			return '';
		}

		$is_negative = false;
		// we could possibly simply typecast it to integer, but there are
		// certain fringe cases that must not return an integer.

		// clip leading sign
		if ($this->negative && $integer[0] === '-') {
			$digits = Str\slice($integer, 1);
			if ($digits === '0') {
				$integer = '0'; // rm minus sign for zero
			} else {
				$is_negative = true;
			}
		} elseif ($this->positive && $integer[0] === '+') {
			$integer = Str\slice($integer, 1); // rm unnecessary plus
			$digits = $integer;
		} else {
			$digits = $integer;
		}

		// test if it's numeric
		if (!\ctype_digit($digits)) {
			return '';
		}

		// perform scope tests
		if (!$this->zero && $integer == 0) {
			return '';
		}
		// Original checked if $integer > 0, which isn't allowed in Hack
		if (!$this->positive && (!$is_negative && $integer != 0)) {
			return '';
		}
		// Original checked if $integer < 0, which isn't allowed in Hack
		if (!$this->negative && ($is_negative && $integer != 0)) {
			return '';
		}

		return $integer;
	}
}
