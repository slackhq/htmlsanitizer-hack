/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier\AttrDef\CSS;
use namespace HH\Lib\{C, Str};

/**
 * Validates the border property as defined by CSS.
 */
class HTMLPurifier_AttrDef_CSS_Border extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Local copy of properties this property is shorthand for.
	 */
	protected dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info = dict[];

	public function __construct(HTMLPurifier\HTMLPurifier_Config $_config): void {
		$border_width = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(vec['thin', 'medium', 'thick']),
				new CSS\HTMLPurifier_AttrDef_CSS_Length('0'), //disallow negative
			],
		);

		$this->info['border-width'] = new HTMLPurifier_AttrDef_CSS_Multiple($border_width);

		$border_style = new AttrDef\HTMLPurifier_AttrDef_Enum(
			vec[
				'none',
				'hidden',
				'dotted',
				'dashed',
				'solid',
				'double',
				'groove',
				'ridge',
				'inset',
				'outset',
			],
			false,
		);

		$this->info['border-style'] = new HTMLPurifier_AttrDef_CSS_Multiple($border_style);
		$this->info['border-top-color'] = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(vec['transparent']),
				new HTMLPurifier_AttrDef_CSS_Color(),
			],
		);
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
		$string = $this->parseCDATA($string);
		$string = $this->mungeRgb($string);
		$bits = Str\split($string, ' ');
		$done = dict[]; // segments we've finished
		$ret = ''; // return value
		foreach ($bits as $bit) {
			foreach ($this->info as $propname => $validator) {
				if (C\contains_key($done, $propname)) {
					continue;
				}
				$r = $validator->validate($bit, $config, $context);
				if ($r !== '') {
					$ret .= $r.' ';
					$done[$propname] = true;
					break;
				}
			}
		}
		return Str\trim_right($ret);
	}
}
