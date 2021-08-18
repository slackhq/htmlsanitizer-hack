/* Created by Nikita Ashok on 07/14/2020 */
namespace HTMLPurifier;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Vec, Dict};

class HTMLPurifier_HTMLModuleManager {
    /**
     * @type HTMLPurifier_DoctypeRegistry
     */
    public HTMLPurifier_DoctypeRegistry $doctypes;

    /**
     * Instance of current doctype.
     * @type HTMLPurifier_Doctype
     */
    public ?HTMLPurifier_Doctype $doctype;

    // /**
    //  * @type HTMLPurifier_AttrTypes
    //  */
    // public $attrTypes;

    /**
     * Active instances of modules for the specified doctype are
     * indexed, by name, in this array.
     * @type HTMLPurifier_HTMLModule[]
     */
    public dict<string, HTMLPurifier\HTMLPurifier_HTMLModule> $modules = dict[];

    /**
     * Array of recognized HTMLPurifier_HTMLModule instances,
     * indexed by module's class name. This array is usually lazy loaded, but a
     * user can overload a module by pre-emptively registering it.
     * @type HTMLPurifier_HTMLModule[]
     */
    public dict<string, HTMLPurifier\HTMLPurifier_HTMLModule> $registeredModules = dict[];

    /**
     * List of extra modules that were added by the user
     * using addModule(). These get unconditionally merged into the current doctype, whatever
     * it may be.
     * @type HTMLPurifier_HTMLModule[]
     */
    public vec<HTMLPurifier_HTMLModule> $userModules = vec[];

    /**
     * Associative array of element name to list of modules that have
     * definitions for the element; this array is dynamically filled.
     * @type array
     */
    public dict<string, vec<string>>$elementLookup = dict[];

    // /**
    //  * List of prefixes we should use for registering small names.
    //  * @type array
    //  */
    // public $prefixes = array('HTMLPurifier_HTMLModule_');

    public ?HTMLPurifier\HTMLPurifier_ContentSets $contentSets;

    // /**
    //  * @type HTMLPurifier_AttrCollections
    //  */
    // public $attrCollections;

    /**
     * If set to true, unsafe elements and attributes will be allowed.
     * @type bool
     */
    public bool $trusted = false;
    
    public HTMLPurifier_AttrTypes $attrTypes;

    public function __construct()
    {
        // editable internal objects
        $this->attrTypes = new HTMLPurifier_AttrTypes();
        $this->doctypes  = new HTMLPurifier_DoctypeRegistry();

        // setup basic modules
        $common = dict[
            'CommonAttributes' => true, 'Text' => true, 'Hypertext' => true, 'List' => true,
            'Presentation' => true, 'Edit' => true, 'Bdo' => true, 'Tables' => true, 'Image' => true,
            'StyleAttribute' => true,
            // Unsafe:
            'Scripting' => true, 'Object' => true, 'Forms' => true,
            // Sorta legacy, but present in strict:
            'Name' => true,
        ];
        $transitional = dict['Legacy' => true, 'Target' => true, 'Iframe' => true];
        $xml = dict['XMLCommonAttributes' => true];
        $non_xml = dict['NonXMLCommonAttributes' => true];

        // setup basic doctypes
        $this->doctypes->register(
            'HTML 4.01 Transitional',
            false,
            Dict\merge($common, $transitional, $non_xml),
            dict['Tidy_Transitional' => true, 'Tidy_Proprietary' => true],
            vec[],
            '-//W3C//DTD HTML 4.01 Transitional//EN',
            'http://www.w3.org/TR/html4/loose.dtd'
        );

        $this->doctypes->register(
            'HTML 4.01 Strict',
            false,
            Dict\merge($common, $non_xml),
            dict['Tidy_Strict' => true, 'Tidy_Proprietary' => true, 'Tidy_Name' => true],
            vec[],
            '-//W3C//DTD HTML 4.01//EN',
            'http://www.w3.org/TR/html4/strict.dtd'
        );

        $this->doctypes->register(
            'XHTML 1.0 Transitional',
            true,
            Dict\merge($common, $transitional, $xml, $non_xml),
            dict['Tidy_Transitional' => true, 'Tidy_XHTML' => true, 'Tidy_Proprietary' => true, 'Tidy_Name' => true],
            vec[],
            '-//W3C//DTD XHTML 1.0 Transitional//EN',
            'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'
        );

        $this->doctypes->register(
            'XHTML 1.0 Strict',
            true,
            Dict\merge($common, $xml, $non_xml),
            dict['Tidy_Strict' => true, 'Tidy_XHTML' => true, 'Tidy_Strict' => true, 'Tidy_Proprietary' => true, 'Tidy_Name' => true],
            vec[],
            '-//W3C//DTD XHTML 1.0 Strict//EN',
            'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        );

        $this->doctypes->register(
            'XHTML 1.1',
            true,
            // Iframe is a real XHTML 1.1 module, despite being
            // "transitional"!
            Dict\merge($common, $xml, dict['Ruby' => true, 'Iframe' => true]),
            dict['Tidy_Strict' => true, 'Tidy_XHTML' => true, 'Tidy_Proprietary' => true, 'Tidy_Strict' => true, 'Tidy_Name' => true], // Tidy_XHTML1_1
            vec[],
            '-//W3C//DTD XHTML 1.1//EN',
            'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'
        );

    }

    /**
     * Registers a module to the recognized module list, useful for
     * overloading pre-existing modules.
     * @param $module Mixed: string module name, with or without
     *                HTMLPurifier_HTMLModule prefix, or instance of
     *                subclass of HTMLPurifier_HTMLModule.
     * @param $overload Boolean whether or not to overload previous modules.
     *                  If this is not set, and you do overload a module,
     *                  HTML Purifier will complain with a warning.
     * @note This function will not call autoload, you must instantiate
     *       (and thus invoke) autoload outside the method.
     * @note If a string is passed as a module name, different variants
     *       will be tested in this order:
     *          - Check for HTMLPurifier_HTMLModule_$name
     *          - Check all prefixes with $name in order they were added
     *          - Check for literal object name
     *          - Throw fatal error
     *       If your object name collides with an internal class, specify
     *       your module manually. All modules must have been included
     *       externally: registerModule will not perform inclusions for you!
     */
    public function registerModule(string $module, bool $overload = false): void {
        // if (is_string($module)) {
        //     // attempt to load the module
        //     $original_module = $module;
        //     $ok = false;
        //     foreach ($this->prefixes as $prefix) {
        //         $module = $prefix . $original_module;
        //         if (class_exists($module)) {
        //             $ok = true;
        //             break;
        //         }
        //     }
        //     if (!$ok) {
        //         $module = $original_module;
        //         if (!class_exists($module)) {
        //             trigger_error(
        //                 $original_module . ' module does not exist',
        //                 E_USER_ERROR
        //             );
        //             return;
        //         }
        //     }
        //     $module = new $module();
        // }
        // if (empty($module->name)) {
        //     trigger_error('Module instance of ' . get_class($module) . ' must have name');
        //     return;
        // }
        // if (!$overload && isset($this->registeredModules[$module->name])) {
        //     trigger_error('Overloading ' . $module->name . ' without explicit overload parameter', E_USER_WARNING);
        // }
        //$this->registeredModules[$module->name] = $module;
    }

    /**
     * Adds a module to the current doctype by first registering it,
     * and then tacking it on to the active doctype
     */
    public function addModule(HTMLPurifier_HTMLModule $module) : void {
        $this->registerModule($module->name);
        $this->userModules[] = $module;
    }

    // /**
    //  * Adds a class prefix that registerModule() will use to resolve a
    //  * string name to a concrete class
    //  */
    // public function addPrefix($prefix)
    // {
    //     $this->prefixes[] = $prefix;
    // }

    /**
     * Performs processing on modules, after being called you may
     * use getElement() and getElements()
     * @param HTMLPurifier_Config $config
     */
    public function setup(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->trusted = $config->def->defaults['HTML.Trusted'];

        // generate
        $doctype = $this->doctypes->make($config);
        $this->doctype = $doctype;
        $modules = $doctype->modules;

        // take out the default modules that aren't allowed
        $lookup = $config->def->defaults['HTML.AllowedModules'];
        $special_cases = $config->def->defaults['HTML.CoreModules'];

        if (!C\is_empty($lookup)) {
            foreach ($modules as $key => $value) {
                if (C\contains_key($special_cases, $key)) {
                    continue;
                }
                if (!C\contains_key($lookup, $key)) {
                    unset($modules[$key]);
                }
            }
        }

        // custom modules
        if ($config->def->defaults['HTML.Proprietary']) {
            $modules['Proprietary'] = true;
        }
        if ($config->def->defaults['HTML.SafeObject']) {
            $modules['SafeObject'] = true;
        }
        if ($config->def->defaults['HTML.SafeEmbed']) {
            $modules['SafeEmbed'] = true;
        }
        if ($config->def->defaults['HTML.SafeScripting'] !== vec[]) {
            $modules['SafeScripting'] = true;
        }
        if ($config->def->defaults['HTML.Nofollow']) {
            $modules['Nofollow'] = true;
        }
        if ($config->def->defaults['HTML.TargetBlank']) {
            $modules['TargetBlank'] = true;
        }
        // NB: HTML.TargetNoreferrer and HTML.TargetNoopener must be AFTER HTML.TargetBlank
        // so that its post-attr-transform gets run afterwards.
        if ($config->def->defaults['HTML.TargetNoreferrer']) {
            $modules['TargetNoreferrer'] = true;
        }
        if ($config->def->defaults['HTML.TargetNoopener']) {
            $modules['TargetNoopener'] = true;
        }

        // merge in custom modules
        $modules = Dict\merge($modules, $this->userModules);

        //foreach ($modules as $module => $value) {
            //$this->processModule($module);
            //$this->modules[$module]->setup($config);
        //}

        // foreach ($this->doctype->tidyModules as $module) {
        //     $this->processModule($module);
        //     $this->modules[$module]->setup($config);
        // }

        // // prepare any injectors
        // foreach ($this->modules as $module) {
        //     $n = array();
        //     foreach ($module->info_injector as $injector) {
        //         if (!is_object($injector)) {
        //             $class = "HTMLPurifier_Injector_$injector";
        //             $injector = new $class;
        //         }
        //         $n[$injector->name] = $injector;
        //     }
        //     $module->info_injector = $n;
        // }

        // setup lookup table based on all valid modules
        foreach ($this->modules as $module => $value ) {
            foreach ($value->info as $name => $def) {
                if (!isset($this->elementLookup[$name])) {
                    $this->elementLookup[$name] = vec[];
                }
                //$this->elementLookup[$name][] = $module->name;
            }
        }

        // note the different choice
        // $this->contentSets = new HTMLPurifier_ContentSets(
        //     // content set assembly deals with all possible modules,
        //     // not just ones deemed to be "safe"
        //     $this->modules
        // );
        // $this->attrCollections = new HTMLPurifier_AttrCollections(
        //     $this->attrTypes,
        //     // there is no way to directly disable a global attribute,
        //     // but using AllowedAttributes or simply not including
        //     // the module in your custom doctype should be sufficient
        //     $this->modules
        // );
    }

    /**
     * Takes a module and adds it to the active module collection,
     * registering it if necessary.
     */
    public function processModule(string $module): void {
        if (!C\contains_key($this->registeredModules, $module)) {
            $this->registerModule($module);
        }
        $this->modules[$module] = $this->registeredModules[$module];
    }

    // /**
    //  * Retrieves merged element definitions.
    //  * @return Array of HTMLPurifier_ElementDef
    //  */
    public function getElements(): dict<string, ?HTMLPurifier\HTMLPurifier_ElementDef> {
        $elements = dict[];
        foreach ($this->modules as $module) {
            if (!$this->trusted && !$module->safe) {
                continue;
            }
            foreach ($module->info as $name => $v) {
                if (isset($elements[$name])) {
                    continue;
                }
                $elements[$name] = $this->getElement($name);
            }
        }
        // remove dud elements, this happens when an element that
        // appeared to be safe actually wasn't
        foreach ($elements as $n => $v) {
            if ($v === false) {
                unset($elements[$n]);
            }
        }

        return $elements;

    }

    /**
     * Retrieves a single merged element definition
     * @param string $name Name of element
     * @param bool $trusted Boolean trusted overriding parameter: set to true
     *                 if you want the full version of an element
     * @return HTMLPurifier_ElementDef Merged HTMLPurifier_ElementDef
     * @note You may notice that modules are getting iterated over twice (once
     *       in getElements() and once here). This
     *       is because
     */
    public function getElement(string $name, bool $trusted = false): ?HTMLPurifier\HTMLPurifier_ElementDef {
        if (!C\contains_key($this->elementLookup, $name)) {
            return null;
        }

        // setup global state variables
        $def = null;
        if ($trusted === null) {
            $trusted = $this->trusted;
        }

        // iterate through each module that has registered itself to this
        // element
        foreach ($this->elementLookup[$name] as $module_name) {
            $module = $this->modules[$module_name];

            // refuse to create/merge from a module that is deemed unsafe--
            // pretend the module doesn't exist--when trusted mode is not on.
            if (!$trusted && !$module->safe) {
                continue;
            }

            // clone is used because, ideally speaking, the original
            // definition should not be modified. Usually, this will
            // make no difference, but for consistency's sake
            $new_def = clone $module->info[$name];

            if (!$def && $new_def->standalone) {
                $def = $new_def;
            } elseif ($def) {
                // This will occur even if $new_def is standalone. In practice,
                // this will usually result in a full replacement.
                //$def->mergeIn($new_def);
            } else {
                // :TODO:
                // non-standalone definitions that don't have a standalone
                // to merge into could be deferred to the end
                // HOWEVER, it is perfectly valid for a non-standalone
                // definition to lack a standalone definition, even
                // after all processing: this allows us to safely
                // specify extra attributes for elements that may not be
                // enabled all in one place.  In particular, this might
                // be the case for trusted elements.  WARNING: care must
                // be taken that the /extra/ definitions are all safe.
                continue;
            }

            // attribute value expansions
            // $this->attrCollections->performInclusions($def->attr);
            // $this->attrCollections->expandIdentifiers($def->attr, $this->attrTypes);

            // // descendants_are_inline, for ChildDef_Chameleon
            // if (is_string($def->content_model) &&
            //     strpos($def->content_model, 'Inline') !== false) {
            //     if ($name != 'del' && $name != 'ins') {
            //         // this is for you, ins/del
            //         $def->descendants_are_inline = true;
            //     }
            // }

            // $this->contentSets->generateChildDef($def, $module);
        }

        // This can occur if there is a blank definition, but no base to
        // mix it in with
        if (!$def) {
            return null;
        }

        // add information on required attributes
        foreach ($def->attr as $attr_name => $attr_def) {
            if ($attr_def->required) {
                $def->required_attr[] = $attr_name;
            }
        }
        return $def;
    }
}
