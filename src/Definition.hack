/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;
use namespace HTMLPurifier\Enums;
/**
* Superclass for definition datatype objects,  implements serialization functions for the class.
*/

abstract class HTMLPurifier_Definition {
    //Has setup been called yet?
    public bool $setup = false;

    //If true, write out the final definition object to the cache.
    public bool $optimized = false;

    //string type, html, css, or uri
    public ?Enums\DefinitionType $type;
    public ?HTMLPurifier_Doctype $doctype;

    abstract protected function doSetup(HTMLPurifier_Config $config): void;

    //Setup function that aborts if already setup
    public function setup(HTMLPurifier_Config $config): void {
        if ($this->setup) {
            return;
        }
        $this->setup = true;
        $this->doSetup($config);
    }
}
