/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str};

/**
 * Validates shorthand CSS property list-style.
 * @warning Does not support url tokens that have internal spaces.
 */
class HTMLPurifier_AttrDef_CSS_ListStyle extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * Local copy of validators.
     */
    protected dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info = dict[];

    public function __construct(HTMLPurifier\HTMLPurifier_Config $_config) : void {
        $this->info['list-style-type'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec[
                'disc',
                'circle',
                'square',
                'decimal',
                'lower-roman',
                'upper-roman',
                'lower-alpha',
                'upper-alpha',
                'none'
            ],
            false
        );
        $this->info['list-style-position'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['inside', 'outside'],
            false
        );

        $uri_or_none = new HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['none']),
                new HTMLPurifier_AttrDef_CSS_URI()
            ]
        );
        $this->info['list-style-image'] = $uri_or_none;
    }

    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        // regular pre-processing
        $string = $this->parseCDATA($string);
        if ($string === '') {
            return '';
        }

        $string = Str\lowercase($string);
        // assumes URI doesn't have spaces in it
        $bits = Str\split($string, ' '); // bits to process

        $caught = dict[];
        $caught['type'] = '';
        $caught['position'] = '';
        $caught['image'] = '';

        $i = 0; // number of catches
        $none = false;

        foreach ($bits as $bit) {
            if ($i >= 3) {
                return '';
            } // optimization bit
            if ($bit === '') {
                continue;
            }
            foreach ($caught as $key => $status) {
                if ($status !== '') {
                    continue;
                }
                $r = $this->info['list-style-' . $key]->validate($bit, $config, $context);
                if ($r === '') {
                    continue;
                }
                if ($r === 'none') {
                    if ($none) {
                        continue;
                    } else {
                        $none = true;
                    }
                    if ($key == 'image') {
                        continue;
                    }
                }
                $caught[$key] = $r;
                $i++;
                break;
            }
        }

        if (!$i) {
            return '';
        }

        $ret = vec[];

        // construct type
        if ($caught['type']) {
            $ret[] = $caught['type'];
        }

        // construct image
        if ($caught['image']) {
            $ret[] = $caught['image'];
        }

        // construct position
        if ($caught['position']) {
            $ret[] = $caught['position'];
        }

        if (C\is_empty($ret)) {
            return '';
        }
        return Str\join($ret, ' ');
    }
}
