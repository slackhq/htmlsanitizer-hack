/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str, Vec};

/**
 * Validates shorthand CSS property font.
 */
class HTMLPurifier_AttrDef_CSS_Font extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Local copy of validators
	 * @type HTMLPurifier_AttrDef[]
	 * @note If we moved specific CSS property definitions to their own
	 *       classes instead of having them be assembled at run time by
	 *       CSSDefinition, this wouldn't be necessary.  We'd instantiate
	 *       our own copies.
	 */
	protected dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info = dict[];

	/**
	 * @param HTMLPurifier_Config $config
	 */
	public function __construct(HTMLPurifier\HTMLPurifier_Config $_config): void {
		$this->info['font-style'] = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(
					vec[
						'xx-small',
						'x-small',
						'small',
						'medium',
						'large',
						'x-large',
						'xx-large',
						'larger',
						'smaller',
					],
				),
				new HTMLPurifier_AttrDef_CSS_Percentage(),
				new HTMLPurifier_AttrDef_CSS_Length(),
			],
		);
		$this->info['font-variant'] = new AttrDef\HTMLPurifier_AttrDef_Enum(vec['normal', 'small-caps'], false);
		$this->info['font-weight'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
			vec[
				'normal',
				'bold',
				'bolder',
				'lighter',
				'100',
				'200',
				'300',
				'400',
				'500',
				'600',
				'700',
				'800',
				'900',
			],
			false,
		);
		$this->info['font-size'] = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(
					vec[
						'xx-small',
						'x-small',
						'small',
						'medium',
						'large',
						'x-large',
						'xx-large',
						'larger',
						'smaller',
					],
				),
				new HTMLPurifier_AttrDef_CSS_Percentage(),
				new HTMLPurifier_AttrDef_CSS_Length(),
			],
		);
		$this->info['line-height'] = new HTMLPurifier_AttrDef_CSS_Composite(
			vec[
				new AttrDef\HTMLPurifier_AttrDef_Enum(vec['normal']),
				new HTMLPurifier_AttrDef_CSS_Number(true), // no negatives
				new HTMLPurifier_AttrDef_CSS_Length('0'),
				new HTMLPurifier_AttrDef_CSS_Percentage(true),
			],
		);
		$this->info['font-family'] = new HTMLPurifier_AttrDef_CSS_FontFamily();
	}

	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$system_fonts = dict[
			'caption' => true,
			'icon' => true,
			'menu' => true,
			'message-box' => true,
			'small-caption' => true,
			'status-bar' => true,
		];

		// regular pre-processing
		$string = $this->parseCDATA($string);
		if ($string === '') {
			return '';
		}

		// check if it's one of the keywords
		$lowercase_string = Str\lowercase($string);
		if (C\contains_key($system_fonts, $lowercase_string)) {
			return $lowercase_string;
		}

		$bits = Str\split($string, ' '); // bits to process
		$stage = 0; // this indicates what we're looking for
		$caught = dict[]; // which stage 0 properties have we caught?
		$stage_1 = vec['font-style', 'font-variant', 'font-weight'];
		$final = ''; // output
		$r = '';

		for ($i = 0, $size = C\count($bits); $i < $size; $i++) {
			if ($bits[$i] === '') {
				continue;
			}
			switch ($stage) {
				case 0:
					foreach ($stage_1 as $validator_name) {
						if (isset($caught[$validator_name])) {
							continue;
						}
						$r = $this->info[$validator_name]->validate($bits[$i], $config, $context);
						if ($r !== '') {
							$final .= $r.' ';
							$caught[$validator_name] = true;
							break;
						}
					}
					// all three caught, continue on
					if (C\count($caught) >= 3) {
						$stage = 1;
					}
					if ($r !== '') {
						break;
					}
					// FALLTHROUGH
				case 1: // attempting to catch font-size and perhaps line-height
					$found_slash = false;
					if (Str\search($bits[$i], '/') != false) {
						list($font_size, $line_height) = Str\split($bits[$i], '/');
						if ($line_height === '') {
							// ooh, there's a space after the slash!
							$line_height = false;
							$found_slash = true;
						}
					} else {
						$font_size = $bits[$i];
						$line_height = false;
					}
					$r = $this->info['font-size']->validate($font_size, $config, $context);
					if ($r !== '') {
						$final .= $r;
						// attempt to catch line-height
						if ($line_height === false) {
							// we need to scroll forward
							for ($j = $i + 1; $j < $size; $j++) {
								if ($bits[$j] === '') {
									continue;
								}
								if ($bits[$j] === '/') {
									if ($found_slash) {
										return '';
									} else {
										$found_slash = true;
										continue;
									}
								}
								$line_height = $bits[$j];
								break;
							}
						} else {
							// slash already found
							$found_slash = true;
							$j = $i;
						}
						if ($found_slash && $line_height is string) {
							$i = $j;
							$r = $this->info['line-height']->validate($line_height, $config, $context);
							if ($r !== '') {
								$final .= '/'.$r;
							}
						}
						$final .= ' ';
						$stage = 2;
						break;
					}
					return '';
				case 2: // attempting to catch font-family
					$sliced_bits = Vec\slice($bits, $i, $size - $i);
					$font_family = Str\join($sliced_bits, ' ');
					$r = $this->info['font-family']->validate($font_family, $config, $context);
					if ($r !== '') {
						$final .= $r.' ';
						// processing completed successfully
						return Str\trim_right($final);
					}
					return '';
			}
		}
		return '';
	}
}
