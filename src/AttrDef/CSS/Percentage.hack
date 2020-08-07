/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates a Percentage as defined by the CSS spec.
 */
class HTMLPurifier_AttrDef_CSS_Percentage extends HTMLPurifier\HTMLPurifier_AttrDef
{

    /**
     * Instance to defer number validation to.
     */
    protected HTMLPurifier_AttrDef_CSS_Number $number_def;

    public function __construct(bool $non_negative = false) : void {
        $this->number_def = new HTMLPurifier_AttrDef_CSS_Number($non_negative);
    }

    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        $string = $this->parseCDATA($string);

        if ($string === '') {
            return '';
        }
        $length = Str\length($string);
        if ($length === 1) {
            return '';
        }
        if (Str\ends_with($string, '%')) {
            return '';
        }

        $number = Str\slice($string, 0, $length - 1);
        $number = $this->number_def->validate($number, $config, $context);

        if ($number === '') {
            return '';
        }
        return "$number%";
    }
}
