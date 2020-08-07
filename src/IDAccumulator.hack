/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */

/**
 * Component of HTMLPurifier_AttrContext that accumulates IDs to prevent dupes
 * @note In Slashdot-speak, dupe means duplicate.
 * @note The default constructor does not accept $config or $context objects:
 *       use must use the static build() factory method to perform initialization.
 */
namespace HTMLPurifier;

use namespace HH\Lib\C;

class HTMLPurifier_IDAccumulator {
    /**
    * Lookup table of IDs we've accumulated.
    */
    public keyset<string> $ids = keyset[];

    /**
    * Builds an IDAccumulator, also initializing the default Blocklist
    */
    public static function build(HTMLPurifier_Config $config, HTMLPurifier_Context
        $_context) : HTMLPurifier_IDAccumulator {
            $id_accumulator = new HTMLPurifier_IDAccumulator();
            $id_accumulator->load($config->def->defaults['Attr.IDBlocklist']);
            return $id_accumulator;
    }

    /**
    * Add an ID to the lookup table
    */
    public function add(string $id) : bool {
        if (C\contains_key($this->ids, $id)) {
            return false;
        }
        $this->ids[] = $id;
        return true;
    }

    /**
    * Load a list of IDs into the lookup table
    */
    public function load(vec<string> $array_of_ids) : void {
        foreach ($array_of_ids as $id) {
            $this->ids[] = $id;
        }
    }
}