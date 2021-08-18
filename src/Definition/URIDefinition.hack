//Created by Nikita Ashok on 7/21/20.
namespace HTMLPurifier\Definition;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Enums;
use namespace HTMLPurifier\URIFilter;
use namespace HH\Lib\{Str, C};
use namespace HH\Shapes;

class HTMLPurifier_URIDefinition extends HTMLPurifier\HTMLPurifier_Definition {

    public ?Enums\DefinitionType $type = Enums\DefinitionType::URI;
    protected dict<string, HTMLPurifier\HTMLPurifier_URIFilter> $filters = dict[];
    protected dict<string, HTMLPurifier\HTMLPurifier_URIFilter> $postFilters = dict[];
    protected dict<string, HTMLPurifier\HTMLPurifier_URIFilter> $registeredFilters = dict[];

    /**
     * HTMLPurifier_URI object of the base specified at %URI.Base
     */
    public ?HTMLPurifier\HTMLPurifier_URI $base;

    /**
     * String host to consider "home" base, derived off of $base
     */
    public string $host = '';

    /**
     * Name of default scheme based on %URI.DefaultScheme and %URI.Base
     */
    public string $defaultScheme = '';

    public function __construct()
    {
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_DisableExternal());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_DisableExternalResources());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_DisableResources());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_HostBlocklist());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_SafeIframe());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_MakeAbsolute());
        $this->registerFilter(new URIFilter\HTMLPurifier_URIFilter_Munge());
    }

    private function registerFilter(HTMLPurifier\HTMLPurifier_URIFilter $filter): void {
        $this->registeredFilters[$filter->name] = $filter;
    }

    public function addFilter(HTMLPurifier\HTMLPurifier_URIFilter $filter, HTMLPurifier\HTMLPurifier_Config $config): void {
        $r = $filter->prepare($config);
        if ($r === false) return; // null is ok, for backwards compat
        if ($filter->post) {
            $this->postFilters[$filter->name] = $filter;
        } else {
            $this->filters[$filter->name] = $filter;
        }
    }

    protected function doSetup(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->setupMemberVariables($config);
        $this->setupFilters($config);
    }

    protected function setupFilters(HTMLPurifier\HTMLPurifier_Config $config): void {
        foreach ($this->registeredFilters as $name => $filter) {
            if ($filter->always_load) {
                $this->addFilter($filter, $config);
            } else {
                $conf = Shapes::toArray($config->def->defaults)['URI.' . $name];
                if ($conf !== false && $conf !== '') {
                    $this->addFilter($filter, $config);
                }
            }
        }
        $this->registeredFilters = dict[];
    }

    protected function setupMemberVariables(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->host = $config->def->defaults['URI.Host'];
        $base_uri = $config->def->defaults['URI.Base'];
        if (!Str\is_empty($base_uri)) {
            $parser = new HTMLPurifier\HTMLPurifier_URIParser();
            $this->base = $parser->parse($base_uri);
            if ($this->base is nonnull) {
                $this->defaultScheme = $this->base->scheme;
            }
            if (Str\is_empty($this->host) && $this->base is nonnull) {
                $this->host = $this->base->host;
            }
        }
        if (Str\is_empty($this->defaultScheme)) { 
            $this->defaultScheme = $config->def->defaults['URI.DefaultScheme'];
        };
    }

    public function getDefaultScheme(HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): HTMLPurifier\HTMLPurifier_URIScheme {
        $scheme = HTMLPurifier\HTMLPurifier_URISchemeRegistry::instance()->getScheme($this->defaultScheme, $config, $context);
        if ($scheme is null) {
            throw new \Exception("Default scheme needs to be non-null");
        } else {
            return $scheme;
        }
    }

    public function filter(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): bool {
        foreach ($this->filters as $name => $f) {
            $result = $f->filter(inout $uri, $config, $context);
            if (!$result) return false;
        }
        return true;
    }

    public function postFilter(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): bool {
        foreach ($this->postFilters as $name => $f) {
            $result = $f->filter(inout $uri, $config, $context);
            if (!$result) return false;
        }
        return true;
    }

}