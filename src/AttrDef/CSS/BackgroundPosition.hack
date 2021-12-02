/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str, Vec};

/* W3C says:
    [ // adjective and number must be in correct order, even if
      // you could switch them without introducing ambiguity.
      // some browsers support that syntax
        [
            <percentage> | <length> | left | center | right
        ]
        [
            <percentage> | <length> | top | center | bottom
        ]?
    ] |
    [ // this signifies that the vertical and horizontal adjectives
      // can be arbitrarily ordered, however, there can only be two,
      // one of each, or none at all
        [
            left | center | right
        ] ||
        [
            top | center | bottom
        ]
    ]
    top, left = 0%
    center, (none) = 50%
    bottom, right = 100%
*/

/* QuirksMode says:
    keyword + length/percentage must be ordered correctly, as per W3C

    Internet Explorer and Opera, however, support arbitrary ordering. We
    should fix it up.

    Minor issue though, not strictly necessary.
*/

// control freaks may appreciate the ability to convert these to
// percentages or something, but it's not necessary

/**
 * Validates the value of background-position.
 */
class HTMLPurifier_AttrDef_CSS_BackgroundPosition extends HTMLPurifier\HTMLPurifier_AttrDef {

	protected HTMLPurifier_AttrDef_CSS_Length $length;

	protected HTMLPurifier_AttrDef_CSS_Percentage $percentage;

	public function __construct(): void {
		$this->length = new HTMLPurifier_AttrDef_CSS_Length();
		$this->percentage = new HTMLPurifier_AttrDef_CSS_Percentage();
	}

	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$string = $this->parseCDATA($string);
		$bits = Str\split($string, ' ');

		$keywords = dict[];
		$keywords['h'] = ''; // left, right
		$keywords['v'] = ''; // top, bottom
		$keywords['ch'] = ''; // center (first word)
		$keywords['cv'] = ''; // center (second word)
		$measures = vec[];

		$i = 0;

		$lookup = dict[
			'top' => 'v',
			'bottom' => 'v',
			'left' => 'h',
			'right' => 'h',
			'center' => 'c',
		];

		foreach ($bits as $bit) {
			if ($bit === '') {
				continue;
			}

			// test for keyword
			$lbit = \ctype_lower($bit) ? $bit : Str\lowercase($bit);
			if (C\contains_key($lookup, $lbit)) {
				$status = $lookup[$lbit];
				if ($status == 'c') {
					if ($i == 0) {
						$status = 'ch';
					} else {
						$status = 'cv';
					}
				}
				$keywords[$status] = $lbit;
				$i++;
			}

			// test for length
			$r = $this->length->validate($bit, $config, $context);
			if ($r !== '') {
				$measures[] = $r;
				$i++;
			}

			// test for percentage
			$r = $this->percentage->validate($bit, $config, $context);
			if ($r !== '') {
				$measures[] = $r;
				$i++;
			}
		}

		if (!$i) {
			return '';
		} // no valid values were caught

		$ret = vec[];

		// first keyword
		if ($keywords['h']) {
			$ret[] = $keywords['h'];
		} elseif ($keywords['ch']) {
			$ret[] = $keywords['ch'];
			$keywords['cv'] = ''; // prevent re-use: center = center center
		} elseif (C\count($measures)) {
			$ret[] = $measures[0];
			$measures = Vec\drop($measures, 1);
		}

		if ($keywords['v']) {
			$ret[] = $keywords['v'];
		} elseif ($keywords['cv']) {
			$ret[] = $keywords['cv'];
		} elseif (C\count($measures)) {
			$ret[] = $measures[0];
			$measures = Vec\drop($measures, 1);
		}

		if (C\is_empty($ret)) {
			return '';
		}
		return Str\join($ret, ' ');
	}
}
