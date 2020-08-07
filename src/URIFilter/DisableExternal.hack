/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Definition;
use namespace HH\Lib\{C, Str, Vec};
use namespace Facebook\TypeAssert;

class HTMLPurifier_URIFilter_DisableExternal extends HTMLPurifier\HTMLPurifier_URIFilter {
    /**
     * @type string
     */
    public string $name = 'DisableExternal';

    /**
     * @type array
     */
    protected vec<string> $ourHostParts = vec[];

    /**
     * @param HTMLPurifier_Config $config
     * @return bool
     */
    public function prepare(HTMLPurifier\HTMLPurifier_Config $config): bool {
        $def = TypeAssert\instance_of(Definition\HTMLPurifier_URIDefinition::class, $config->getURIDefinition());
        if ($def is null) {
            throw new \Error("URIDefinition is null when retreived in URIFilter_DisableExternal");
        }
        $our_host = $def->host;
        if ($our_host !== '') {
            $this->ourHostParts = Vec\reverse(Str\split($our_host, '.'));
        }
        return true;
    }

    /**
     * @param HTMLPurifier_URI $uri Reference
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function filter(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $_config,
        HTMLPurifier\HTMLPurifier_Context $_context): bool {
        if ($uri->host === '') {
            return true;
        }
        if (C\is_empty($this->ourHostParts)) {
            return false;
        }
        $host_parts = Vec\reverse(Str\split($uri->host, '.'));
        if ($host_parts === $this->ourHostParts) {
            return true;
        } else {
            return false;
        }
    }
}
