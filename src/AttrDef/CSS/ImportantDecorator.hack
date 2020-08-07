/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Decorator which enables !important to be used in CSS values.
 */
class HTMLPurifier_AttrDef_CSS_ImportantDecorator extends HTMLPurifier\HTMLPurifier_AttrDef {

    public HTMLPurifier\HTMLPurifier_AttrDef $def;

    public bool $allow;

    public function __construct(HTMLPurifier\HTMLPurifier_AttrDef $def, bool $allow = false) : void {
        $this->def = $def;
        $this->allow = $allow;
    }

    /**
     * Intercepts and removes !important if necessary
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        // test for ! and important tokens
        $string = Str\trim($string);
        $is_important = false;
        // :TODO: optimization: test directly for !important and ! important
        if (Str\ends_with($string, "important")) {
            $sub_string = Str\strip_suffix($string, "important");
            $temp = Str\trim_right($sub_string);
            // use a temp, because we might want to restore important
            if (Str\ends_with($temp, '!')) {
                $string = Str\trim_right(Str\strip_suffix($temp, "!"));
                $is_important = true;
            }
        }
        $string = $this->def->validate($string, $config, $context);
        if ($this->allow && $is_important) {
            $string .= ' !important';
        }
        return $string;
    }
}
