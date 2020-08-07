/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str};

/**
 * Special-case enum attribute definition that lazy loads allowed frame targets
 */
class HTMLPurifier_AttrDef_HTML_FrameTarget extends AttrDef\HTMLPurifier_AttrDef_Enum {

    /**
     * @type vec
     */
    public vec<string> $valid_values = vec[]; // uninitialized value

    /**
     * @type bool
     */
    protected bool $case_sensitive = false;

    public function __construct()
    {
        parent::__construct();
    }

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        if (C\is_empty($this->valid_values)) {
            $this->valid_values = $config->def->defaults['Attr.AllowedFrameTargets'];
        }
        return parent::validate($string, $config, $context);
    }
}

// vim: et sw=4 sts=4
