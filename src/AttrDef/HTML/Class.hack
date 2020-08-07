/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, Definition};
use namespace HH\Lib\{C, Str};

/**
 * Implements special behavior for class attribute (normally NMTOKENS)
 */
class HTMLPurifier_AttrDef_HTML_Class extends AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Nmtokens {
    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    protected function split(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): vec<string> {
        // really, this twiddle should be lazy loaded
        $definition = $config->getHTMLDefinition();
        if ($definition is null) {
            throw new \Exception("HTML Definition should not be null");
        }
        $doctype = $definition->doctype;
        if ($doctype is null) {
            throw new \Exception("HTML Definition's Doctype is null");
        }
        $name = $doctype->name;
        if ($name == "XHTML 1.1" || $name == "XHTML 2.0") {
            return parent::split($string, $config, $context);
        } else {
            return \preg_split('/\s+/', $string);
        }
    }

    /**
     * @param vec $tokens
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return vec of HTMLPurifier_Token $tokens
     */
    protected function filter(vec<string> $tokens, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): vec<string> {
        $allowed = $config->def->defaults['Attr.AllowedClasses'];
        $forbidden = $config->def->defaults['Attr.ForbiddenClasses'];

        $ret = vec[];
        foreach ($tokens as $token) {
            if ((C\is_empty($allowed) || 
                C\contains_key($allowed, $token)) &&
                !C\contains_key($forbidden, $token) && !C\contains($ret, $token)
            ) {
                $ret[] = $token;
            }
        }
        return $ret;
    }
}
