/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;

/**
 * Allows multiple validators to attempt to validate attribute.
 *
 * Composite is just what it sounds like: a composite of many validators.
 * This means that multiple HTMLPurifier_AttrDef objects will have a whack
 * at the string.  If one of them passes, that's what is returned.  This is
 * especially useful for CSS values, which often are a choice between
 * an enumerated set of predefined values or a flexible data type.
 */
class HTMLPurifier_AttrDef_CSS_Composite extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * List of objects that may process strings.
     * @type HTMLPurifier_AttrDef[]
     * @todo Make protected
     */
    public vec<HTMLPurifier\HTMLPurifier_AttrDef> $defs;

    public function __construct(vec<HTMLPurifier\HTMLPurifier_AttrDef> $defs) : void {
        $this->defs = $defs;
    }

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, 
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        foreach ($this->defs as $i => $def) {
            $result = $this->defs[$i]->validate($string, $config, $context);
            if ($result !== '') {
                return $result;
            }
        }
        return '';
    }
}
