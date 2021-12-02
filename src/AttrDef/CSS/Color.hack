/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str, Math};

/**
 * Validates Color as defined by CSS.
 */
class HTMLPurifier_AttrDef_CSS_Color extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * @type HTMLPurifier_AttrDef_CSS_AlphaValue
	 */
	protected HTMLPurifier_AttrDef_CSS_AlphaValue $alpha;

	public function __construct() {
		$this->alpha = new HTMLPurifier_AttrDef_CSS_AlphaValue();
	}

	public function validate(
		string $color,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$colors = $config->def->defaults['Core.ColorKeywords'];

		$color = Str\trim($color);
		if ($color === '') {
			return '';
		}

		$lower = Str\lowercase($color);
		if (C\contains_key($colors, $lower)) {
			return $colors[$lower];
		}

		$matches = vec[];
		if (\preg_match_with_matches('#(rgb|rgba|hsl|hsla)\(#', $color, inout $matches) === 1) {
			// There was weird class/function calls using strings in the PHP version - not allowed in Hack
			throw new \Exception(
				"AttrDef/CSS/Color.hack pregmatch not implemented. 
            Check https://github.com/ezyang/htmlpurifier/blob/master/library/HTMLPurifier/AttrDef/CSS/Color.php for implementation.",
				1,
			);

		} else {
			// hexadecimal handling
			if ($color[0] === '#') {
				$hex = Str\slice($color, 1);
			} else {
				$hex = $color;
				$color = '#'.$color;
			}
			$length = Str\length($hex);
			if ($length !== 3 && $length !== 6) {
				return '';
			}
			if (!\ctype_xdigit($hex)) {
				return '';
			}
		}
		return $color;
	}

}
