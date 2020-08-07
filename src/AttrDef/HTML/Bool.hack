/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
/**
 * Validates a boolean attribute
 */
class HTMLPurifier_AttrDef_HTML_Bool extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * @type string
     */
    protected string $name;

    /**
     * @type bool
     */
    public bool $minimized = true;

    /**
     * @param string $name
     */
    public function __construct(string $name = '')
    {
        $this->name = $name;
    }

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        return $this->name;
    }

    /**
     * @param string $string Name of attribute
     * @return HTMLPurifier_AttrDef_HTML_Bool
     */
    public function make(string $string): HTMLPurifier_AttrDef_HTML_Bool
    {
        return new HTMLPurifier_AttrDef_HTML_Bool($string);
    }
}

// vim: et sw=4 sts=4
