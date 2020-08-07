/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

// It's not clear to me whether or not Punycode means that hostnames
// do not have canonical forms anymore. As far as I can tell, it's
// not a problem (punycoding should be identity when no Unicode
// points are involved), but I'm not 100% sure
class HTMLPurifier_URIFilter_HostBlocklist extends HTMLPurifier\HTMLPurifier_URIFilter {
    /**
     * @type string
     */
    public string $name = 'HostBlocklist';

    /**
     * @type array
     */
    protected vec<string> $Blocklist = vec[];

    /**
     * @param HTMLPurifier_Config $config
     * @return bool
     */
    public function prepare(HTMLPurifier\HTMLPurifier_Config $config): bool {
        $this->Blocklist = $config->def->defaults['URI.HostBlocklist'];
        return true;
    }

    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function filter(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $_config,
        HTMLPurifier\HTMLPurifier_Context $_context): bool {
        foreach ($this->Blocklist as $Blocklisted_host_fragment) {
            if (Str\search($uri->host, $Blocklisted_host_fragment) is nonnull) {
                return false;
            }
        }
        return true;
    }
}
