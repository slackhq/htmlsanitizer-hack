/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;

class HTMLPurifier_AttrDef_CSS_AlphaValue extends HTMLPurifier_AttrDef_CSS_Number {

    public function __construct() : void {
        parent::__construct(false); // opacity is non-negative, but we will clamp it
    }

    public function validate(string $number, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        $result = parent::validate($number, $config, $context);
        if ($result === '') { 
            return $result;
        }
        $float = (float)$result;
        if ($float < 0.0) {
            $result = '0';
        }
        if ($float > 1.0) {
            $result = '1';
        }
        return $result;
    }
}
