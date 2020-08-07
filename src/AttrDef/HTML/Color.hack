/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, Definition};
use namespace HH\Lib\{C, Str};
/**
 * Validates a color according to the HTML spec.
 */
class HTMLPurifier_AttrDef_HTML_Color extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        $colors = $config->def->defaults['Core.ColorKeywords'];

        $string = Str\trim($string);

        if ($string === '') {
            return '';
        }
        $lower = Str\lowercase($string);
        if (C\contains_key($colors, $lower)) {
            return $colors[$lower];
        }
        if ($string[0] === '#') {
            $hex = Str\slice($string, 1);
        } else {
            $hex = $string;
        }

        $length = Str\length($hex);
        if ($length !== 3 && $length !== 6) {
            return '';
        }
        if (!\ctype_xdigit($hex)) {
            return '';
        }
        if ($length === 3) {
            $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
        }
        return "#$hex";
    }
}