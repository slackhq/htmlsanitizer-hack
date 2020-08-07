/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, Definition};
use namespace HH\Lib\{C, Str};

/**
 * Validates the HTML type length (not to be confused with CSS's length).
 *
 * This accepts integer pixels or percentages as lengths for certain
 * HTML attributes.
 */

class HTMLPurifier_AttrDef_HTML_Length extends AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Pixels
{
    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        $string = Str\trim($string);
        if ($string === '') {
            return '';
        }

        $parent_result = parent::validate($string, $config, $context);
        if ($parent_result !== '') {
            return $parent_result;
        }

        $length = Str\length($string);
        $last_char = $string[$length - 1];

        if ($last_char !== '%') {
            return '';
        }

        $points = Str\slice($string, 0, $length - 1);

        if (!\ctype_digit($points)) {
            return '';
        }

        $points = (int)$points;

        if ($points < 0) {
            return '0%';
        }
        if ($points > 100) {
            return '100%';
        }
        return ((string)$points) . '%';
    }
}