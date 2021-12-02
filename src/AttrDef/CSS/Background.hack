/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str};

/**
 * Validates shorthand CSS property background.
 * @warning Does not support url tokens that have internal spaces.
 */
class HTMLPurifier_AttrDef_CSS_Background extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Local copy of component validators.
	 * @type HTMLPurifier_AttrDef[]
	 * @note See HTMLPurifier_AttrDef_Font::$info for a similar impl.
	 */
	protected dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info = dict[];

	public function __construct(HTMLPurifier\HTMLPurifier_Config $_config): void {
		$uri_or_none = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(vec['none']),
				new HTMLPurifier_AttrDef_CSS_URI(),
			],
		);

		$this->info['background-color'] = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(vec['transparent']),
				new HTMLPurifier_AttrDef_CSS_Color(),
			],
		);
		$this->info['background-image'] = $uri_or_none;
		$this->info['background-repeat'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
			vec['repeat', 'repeat-x', 'repeat-y', 'no-repeat'],
		);
		$this->info['background-attachment'] = new AttrDef\HTMLPurifier_AttrDef_Enum(vec['scroll', 'fixed']);
		$this->info['background-position'] = new HTMLPurifier_AttrDef_CSS_BackgroundPosition();
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
		// regular pre-processing
		$string = $this->parseCDATA($string);
		if ($string === '') {
			return '';
		}

		// munge rgb() decl if necessary
		$string = $this->mungeRgb($string);

		// assumes URI doesn't have spaces in it
		$bits = Str\split($string, ' '); // bits to process

		$caught = dict[];
		$caught['color'] = '';
		$caught['image'] = '';
		$caught['repeat'] = '';
		$caught['attachment'] = '';
		$caught['position'] = '';

		$i = 0; // number of catches

		foreach ($bits as $bit) {
			if ($bit === '') {
				continue;
			}
			foreach ($caught as $key => $status) {
				if ($key != 'position') {
					if ($status !== '') {
						continue;
					}
					$r = $this->info['background-'.$key]->validate($bit, $config, $context);
				} else {
					$r = $bit;
				}
				if ($r === '') {
					continue;
				}
				if ($key == 'position') {
					$caught[$key] .= $r.' ';
				} else {
					$caught[$key] = $r;
				}
				$i++;
				break;
			}
		}

		if (!$i) {
			return '';
		}
		if ($caught['position'] !== '') {
			$caught['position'] = $this->info['background-position']->validate($caught['position'], $config, $context);
		}

		$ret = vec[];
		foreach ($caught as $value) {
			if ($value === '') {
				continue;
			}
			$ret[] = $value;
		}

		if (C\is_empty($ret)) {
			return '';
		}
		return Str\join($ret, ' ');
	}
}
