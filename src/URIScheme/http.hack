//created by Nikita Ashok on 07/21/20;
namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;
/**
 * Validates http (HyperText Transfer Protocol) as defined by RFC 2616
 */
class HTMLPurifier_URIScheme_http extends HTMLPurifier\HTMLPurifier_URIScheme
{
    /**
     * @type int
     */
    public int $default_port = 80;

    /**
     * @type bool
     */
    public bool $browsable = true;

    /**
     * @type bool
     */
    public bool $hierarchical = true;

    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function doValidate(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $_config, HTMLPurifier\HTMLPurifier_Context $_context): bool {
        $uri->userinfo = '';
        return true;
    }
}
