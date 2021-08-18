/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

/**
 * Represents a document type, contains information on which modules need to be loaded.
 */
class HTMLPurifier_Doctype {

    // // Full name of doctype
    // public ?string $name;

    // //  * List of standard modules (string identifiers or literal objects)
    // //  * that this doctype uses
    // public ?vec<string> $modules = vec[];

    // //  List of modules to use for tidying up code
    // public ?vec<string> $tidyModules = vec[];

    // //  Is the language derived from XML (i.e. XHTML)?
    // public ?bool $xml = true;

    // // List of aliases for this doctype
    // public ?vec<string> $aliases = vec[];

    // // Public DTD identifier
    // public ?string $dtdPublic;

    // // System DTD identifier
    // public ?string $dtdSystem;

    # Constructor Paramter Promotion
    public function __construct(
        public string $name = '',
        public bool $xml = true,
        public dict<string, bool> $modules = dict[],
        public dict<string, bool> $tidyModules = dict[],
        public vec<string> $aliases = vec[],
        public string $dtdPublic = '',
        public string $dtdSystem = ''
    ) {}
}
