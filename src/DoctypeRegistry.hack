// created by Nikita Ashok on 07/15/2020
namespace HTMLPurifier;

use namespace HH\Lib\{C, Str};

class HTMLPurifier_DoctypeRegistry {

    /**
     * Hash of doctype names to doctype objects.
     * @type array
     */
    protected dict<string, HTMLPurifier_Doctype> $doctypes = dict[];

    /**
     * Lookup table of aliases to real doctype names.
     * @type array
     */
    protected dict<string, string> $aliases = dict[];

    /**
     * Registers a doctype to the registry
     * @note Accepts a fully-formed doctype object, or the
     *       parameters for constructing a doctype object
     * @param string $doctype Name of doctype or literal doctype object
     * @param bool $xml
     * @param array $modules Modules doctype will load
     * @param array $tidy_modules Modules doctype will load for certain modes
     * @param array $aliases Alias names for doctype
     * @param string $dtd_public
     * @param string $dtd_system
     * @return HTMLPurifier_Doctype Editable registered doctype
     */
    public function register(
        string $doctype,
        bool $xml = true,
        dict<string, bool> $modules = dict[],
        dict<string, bool> $tidy_modules = dict[],
        vec<string> $aliases = vec[],
        string $dtd_public = '',
        string $dtd_system = ''
    ): HTMLPurifier_Doctype {
        $doctype = new HTMLPurifier_Doctype(
            $doctype,
            $xml,
            $modules,
            $tidy_modules,
            $aliases,
            $dtd_public,
            $dtd_system
        );
        $this->doctypes[$doctype->name] = $doctype;
        $name = $doctype->name;
        // hookup aliases
        foreach ($doctype->aliases as $alias) {
            if (C\contains_key($this->doctypes, $alias)) {
                continue;
            }
            $this->aliases[$alias] = $name;
        }
        // remove old aliases
        if (C\contains_key($this->aliases, $name)) {
            unset($this->aliases[$name]);
        }
        return $doctype;
    }

    /**
     * Retrieves reference to a doctype of a certain name
     * @note This function resolves aliases
     * @note When possible, use the more fully-featured make()
     * @param string $doctype Name of doctype
     * @return HTMLPurifier_Doctype Editable doctype object
     */
    public function get(string $doctype): HTMLPurifier_Doctype {
        if (C\contains_key($this->aliases, $doctype) && $this->aliases[$doctype]) {
            $doctype = $this->aliases[$doctype];
        }
        if (!C\contains_key($this->doctypes, $doctype)) {
            \trigger_error('Doctype ' . \htmlspecialchars($doctype) . ' does not exist', \E_USER_ERROR);
            $anon = new HTMLPurifier_Doctype($doctype);
            return $anon;
        }
        return $this->doctypes[$doctype];
    }

    /**
     * Creates a doctype based on a configuration object,
     * will perform initialization on the doctype
     * @note Use this function to get a copy of doctype that config
     *       can hold on to (this is necessary in order to tell
     *       Generator whether or not the current document is XML
     *       based or not).
     * @param HTMLPurifier_Config $config
     * @return HTMLPurifier_Doctype
     */
    public function make(HTMLPurifier_Config $config): HTMLPurifier_Doctype {
        return clone $this->get($this->getDoctypeFromConfig($config));
    }

    /**
     * Retrieves the doctype from the configuration object
     * @param HTMLPurifier_Config $config
     * @return string
     */
    public function getDoctypeFromConfig(HTMLPurifier_Config $config): string {
        // recommended test
        $doctype = $config->def->defaults['HTML.Doctype'];
        if (!Str\is_empty($doctype)) {
            return $doctype;
        }
        $doctype = $config->def->defaults['HTML.CustomDoctype'];
        if (!Str\is_empty($doctype)) {
            return $doctype;
        }
        // backwards-compatibility
        if ($config->def->defaults['HTML.XHTML']) {
            $doctype = 'XHTML 1.0';
        } else {
            $doctype = 'HTML 4.01';
        }
        if ($config->def->defaults['HTML.Strict']) {
            $doctype .= ' Strict';
        } else {
            $doctype .= ' Transitional';
        }
        return $doctype;
    }
}

// vim: et sw=4 sts=4
