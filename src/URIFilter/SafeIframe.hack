// Created by Nikita Ashok on 07/21/20;
namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Implements safety checks for safe iframes.
 *
 * @warning This filter is *critical* for ensuring that %HTML.SafeIframe
 * works safely.
 */
class HTMLPurifier_URIFilter_SafeIframe extends HTMLPurifier\HTMLPurifier_URIFilter {
    /**
     * @type string
     */
    public string $name = 'SafeIframe';

    /**
     * @type bool
     */
    public bool $always_load = true;

    /**
     * @type string
     */
    protected string $regexp = '';

    // XXX: The not so good bit about how this is all set up now is we
    // can't check HTML.SafeIframe in the 'prepare' step: we have to
    // defer till the actual filtering.
    /**
     * @param HTMLPurifier_Config $config
     * @return bool
     */
    public function prepare(HTMLPurifier\HTMLPurifier_Config $config): bool {
        $this->regexp = $config->def->defaults['URI.SafeIframeRegexp'];
        return true;
    }

    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function filter(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): bool {
        // check if filter not applicable
        if (!$config->def->defaults['HTML.SafeIframe']) {
            return true;
        }
        // check if the filter should actually trigger
        if (!$context->get('EmbeddedURI', true)) {
            return true;
        }
        $token = $context->get('CurrentToken', true);
        if (!($token && ($token is Token\HTMLPurifier_Token_Tag || $token is Token\HTMLPurifier_Token_Text) && $token->name === 'iframe')) {
            return true;
        }
        // check if we actually have some allowlists enabled
        if ($this->regexp === null) {
            return false;
        }
        // actually check the allowlists
        $check = \preg_match($this->regexp, $uri->toString());
        if ($check === 0) {
            return false;
        } else {
            return true;
        }
    }
}
