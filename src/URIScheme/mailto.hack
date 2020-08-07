//created by Nikita Ashok on 07/22/20;
namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;

// VERY RELAXED! Shouldn't cause problems, not even Firefox checks if the
// email is valid, but be careful!

/**
 * Validates mailto (for E-mail) according to RFC 2368
 * @todo Validate the email address
 * @todo Filter allowed query parameters
 */

class HTMLPurifier_URIScheme_mailto extends HTMLPurifier\HTMLPurifier_URIScheme
{
    /**
     * @type bool
     */
    public bool $browsable = false;

    /**
     * @type bool
     */
    public bool $may_omit_host = true;

    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function doValidate(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $_config, HTMLPurifier\HTMLPurifier_Context $_context): bool {
        $uri->userinfo = '';
        $uri->host     = '';
        $uri->port     = 0;
        // we need to validate path against RFC 2368's addr-spec
        return true;
    }
}

// vim: et sw=4 sts=4
