// Created by Nikita Ashok on 6/18/20;
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
/**
 * Validates arbitrary text according to the HTML spec.
 */
class HTMLPurifier_AttrDef_Text extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $_config, HTMLPurifier\HTMLPurifier_Context $_context): string {
        return $this->parseCDATA($string);
    }
}
