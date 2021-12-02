/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

/**
 * Validates contents based on NMTOKENS attribute type.
 */
class HTMLPurifier_AttrDef_HTML_Nmtokens extends HTMLPurifier\HTMLPurifier_AttrDef {

	const TRIM_CHARLIST = " \t\n\r\0\x0B";

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
		$string = Str\trim($string, $this::TRIM_CHARLIST);

		// early abort: '' and '0' (strings that convert to false) are invalid
		if (!$string) {
			return '';
		}

		$tokens = $this->split($string, $config, $context);
		$tokens = $this->filter($tokens, $config, $context);
		if (C\is_empty($tokens)) {
			return '';
		}
		return Str\join($tokens, ' ');
	}

	/**
	 * Splits a space separated list of tokens into its constituent parts.
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return vec of strings
	 */
	protected function split(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<string> {
		// OPTIMIZABLE!
		// do the preg_match, capture all subpatterns for reformulation

		// we don't support U+00A1 and up codepoints or
		// escaping because I don't know how to do that with regexps
		// and plus it would complicate optimization efforts (you never
		// see that anyway).
		$pattern = '/(?:(?<=\s)|\A)'. // look behind for space or string start
			'((?:--|-?[A-Za-z_])[A-Za-z_\-0-9]*)'.
			'(?:(?=\s)|\z)/'; // look ahead for space or string end
		$matches = vec[];
		\preg_match_all_with_matches($pattern, $string, inout $matches);
		return $matches[1];
	}

	/**
	 * Template method for removing certain tokens based on arbitrary criteria.
	 * @note If we wanted to be really functional, we'd do an array_filter
	 *       with a callback. But... we're not.
	 * @param array $tokens
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return vec of strings
	 */
	protected function filter(
		vec<string> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<string> {
		return $tokens;
	}
}
