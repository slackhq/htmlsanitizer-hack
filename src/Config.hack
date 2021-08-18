/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Shapes;
use namespace HH\Lib\{C, Str};
use namespace HTMLPurifier\Definition;

/**
 * Configuration object that triggers customizable behavior.
 */
class HTMLPurifier_Config {

    public string $version = '4.12.0';
    public bool $autoFinalize = true;
    protected dict<string, mixed> $serials = dict[];
    protected string $serial = '';

    //variables of unmade classes
    public HTMLPurifier_ConfigSchema $def;
    protected dict<string, HTMLPurifier_Definition> $definitions = dict[];

    protected bool $finalized = false;

    protected HTMLPurifier_PropertyList $plist;

    private bool $aliasMode = false;

    public bool $chatty = true;
    private string $lock = '';

    public function __construct(HTMLPurifier_ConfigSchema $definition, ?HTMLPurifier_PropertyList $parent = null) {
        $parent = $parent ? $parent : $definition->defaultPlist;
        $this->def = $definition;
        $this->plist = new HTMLPurifier_PropertyList($parent);
    }

    public static function createDefault(): HTMLPurifier_Config {
        $definition = (new HTMLPurifier_ConfigSchema())->instance(); 
        $config = new HTMLPurifier_Config($definition);
        return $config;
    }

    //TODO: implement $config loadIni and loadArray
    public static function create(mixed $config, ?HTMLPurifier_ConfigSchema $schema = null): HTMLPurifier_Config {
        if ($config is HTMLPurifier_Config) {
            return $config;
        }
        if (!$schema) {
            $ret = HTMLPurifier_Config::createDefault();
        } else {
            $ret = new HTMLPurifier_Config($schema);
        }
        return $ret;
    }

    public function getHTMLDefinition(bool $raw = false, bool $optimized = false): ?HTMLPurifier_Definition {
        return $this->getDefinition('HTML', $raw, $optimized);
    }

    public function getCSSDefinition() : Definition\HTMLPurifier_CSSDefinition {
        $css_def = new Definition\HTMLPurifier_CSSDefinition();
        $css_def->setup($this);
        return $css_def;
    }

    public function getURIDefinition(): Definition\HTMLPurifier_URIDefinition {
        $uri_def = new Definition\HTMLPurifier_URIDefinition();
        $uri_def->setup($this);
        return $uri_def;

    }

    /**
    * Retrieves an array of directives to values from a given namespace
    */
    public function getBatch(string $namespace) : dict<string, mixed> {
        if (!$this->finalized) {
            $this->autoFinalize();
        }
        $full = $this->getAll();
        if (!C\contains_key($full, $namespace)) {
            // $this->triggerError(
            //     'Cannot retrieve undefined namespace ' .
            //     htmlspecialchars($namespace),
            //     E_USER_WARNING
            // );
            // return;
            throw new \Exception('Cannot retrieve undefined namespace');
        }
        return $full[$namespace];
    }

    /**
     * Returns a SHA-1 signature of a segment of the configuration object
     * that uniquely identifies that particular configuration
     */
    public function getBatchSerial(string $namespace) : mixed {
        if (!C\contains_key($this->serials, $namespace)) {
            $batch = $this->getBatch($namespace);
            unset($batch['DefinitionRev']);
            $this->serials[$namespace] = \sha1(\fb_serialize($batch, \FB_SERIALIZE_HACK_ARRAYS));
        }
        return $this->serials[$namespace];
    }

    /**
     * Retrieves all directives, organized by namespace
     *
     * @warning This is a pretty inefficient function, avoid if you can
     */
    public function getAll() : dict<string, dict<string, mixed>> {
        if (!$this->finalized) {
            $this->autoFinalize();
        }
        $ret = dict[];
        $same_before = false;
        foreach (Shapes::toArray($this->def->defaults) as $name => $value) {
            $tuple = Str\split($name, '.', 2);
            if (!C\contains_key($ret, $tuple[0])) {
                $ret[$tuple[0]] = dict[];
            }
            $ret[$tuple[0]][$tuple[1]] = $value;            
        }
        return $ret;
    }

    /**
     * Sets a value to configuration.
     *
     * @param string $key key
     * @param mixed $value value
     * @param mixed $a
     */
    public function set(string $key, mixed $value, mixed $a = null): void {
        throw new \Exception("not implemented");
        // refer to https://github.com/ezyang/htmlpurifier/blob/master/library/HTMLPurifier/Config.php for original implementation
    }

    public function getDefinition(string $type, bool $raw = false, bool $optimized = false): ?HTMLPurifier_Definition {
        if ($optimized && !$raw) {
            throw new \Exception("Cannot set optimized to true when raw is false");
        }

        if (!$this->finalized) {
            $this->autoFinalize();
        }

        $lock = $this->lock;
        $this->lock = '';
        $factory = HTMLPurifier_DefinitionCacheFactory::instance(); // this takes a second
        $cache = $factory->create($type, $this); // so does this line
        $this->lock = $lock;
        if (!$raw) {
            if (C\contains_key($this->definitions, $type)) {
                $def = $this->definitions[$type];
                //check if the definition is setup
                if ($def->setup) {
                    return $def;
                } else {
                    $def->setup($this);
                    if ($def->optimized) {
                        $cache->add($def, $this);
                    }
                    return $def;
                }
            }

            // check if definition is in cache
            $def = $cache->get($this); // this takes a REAL long time
            if ($def) {
                // definition in cache, save to memory and return it
                $this->definitions[$type] = $def;
                return $def;
            }

            //initialize it
            $def = $this->initDefinition($type);
            //set it up
            $this->lock = $type;
            $def->setup($this);
            $this->lock = '';
            //save in cahce
            $cache->add($def, $this);
            //return it
            return $def;
        } else {
            //raw definition
            //check preconditions
            $def = null;
            // THIS BELOW IS COMMENTED OUT BECAUSE WE DON'T HAVE A WAY OF ACCESSING THE SHAPE WITH A CONSTANT
            // if ($optimized) {

            //     if (!$this->def->defaults[$type . '.Definition']) {
            //         //fatally error out if definition ID is not set
            //         throw new \Exception("Cannot retrieve raw version without specifying type definition id");
            //     }
            // }

            if (C\contains_key($this->definitions, $type)) {
                $def = $this->definitions[$type];
                if ($def->setup && !$optimized) {
                    throw new \Exception("Cannot retrieve raw definition after it has already been setup");
                }
                if ($def->optimized === null) {
                    throw new \Exception("Optimization status of definition is unknown");
                    
                }
                if ($def->optimized !== $optimized) {
                    $msg = $optimized ? "optimized" : "unoptimized";
                    $extra = $this->chatty ?
                        " (this backtrace is for the first inconsistent call, which was for a $msg raw definition)"
                        : "";
                    throw new \Exception(
                        "Inconsistent use of optimized and unoptimized raw definition retrievals" . $extra
                    );
                }
            }
            // check if definition was in memory
            if ($def) {
                if ($def->setup) {
                    return null;
                } else {
                    return $def;
                }
            }
            // if ($optimized) {
            //     $def = $cache->get($this);
            //     if ($def) {
            //         $this->definitions[$type] = $def;
            //         return null;
            //     }
            // }
            //check invariants for creation
            // if (!$optimized) {
            //     if ($this->get($type . '.DefinitionID')) {
            //         echo "Useless DefinitionID declaration";
            //     }
            // }
            // initialize it
            $def = $this->initDefinition($type);
            $def->optimized = $optimized;
            return $def;
        }
        throw new \Exception("something seriously wrong");
    }

    //Initialize a definition
    private function initDefinition(string $type): HTMLPurifier_Definition {
        //quick checks failed, create the object
        if ($type == 'HTML') {
            $def = new Definition\HTMLPurifier_HTMLDefinition();
        } else {
            throw new \Exception("Definition of $type type not supported");
        }
        $this->definitions[$type] = $def;
        return $def;
    }

    /**
    * Finalizes configuration only if auto finalize is on and not
    * already finalized
    */

    public function autoFinalize(): void {
        if ($this->autoFinalize) {
            $this->finalize();
        } else {
            $this->plist->squash(true);
        }
    }

    /**
    * Finalizes a configuration object, prohibiting further change
    */
    public function finalize(): void {
        $this->finalized = true;
    }

}
