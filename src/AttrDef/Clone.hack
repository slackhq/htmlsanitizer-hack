/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\AttrDef;

use namespace HTMLPurifier;
/**
 * Dummy AttrDef that mimics another AttrDef, BUT it generates clones
 * with make.
 */
class HTMLPurifier_AttrDef_Clone extends HTMLPurifier\HTMLPurifier_AttrDef {
    /**
     * What we're cloning.
     * @type HTMLPurifier_AttrDef
     */
    protected HTMLPurifier\HTMLPurifier_AttrDef $clone;

    /**
     * @param HTMLPurifier_AttrDef $clone
     */
    public function __construct(HTMLPurifier\HTMLPurifier_AttrDef $clone) {
        $this->clone = $clone;
    }

    /**
     * @param string $v
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
    public function validate(string $v, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        return $this->clone->validate($v, $config, $context);
    }

    /**
     * @param string $string
     * @return HTMLPurifier_AttrDef
     */
    public function make(string $_string): HTMLPurifier\HTMLPurifier_AttrDef {
        return clone $this->clone;
    }
}