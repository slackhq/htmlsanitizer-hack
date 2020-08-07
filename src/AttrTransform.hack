/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\C;

/**
 * Processes an entire attribute array for corrections needing multiple values.
 *
 * Note that the child classes have not been implemented as the configurations do
 * not process entire attribute arrays
 */
abstract class HTMLPurifier_AttrTransform {
    // Makes changes to the attributes dependent on multiple values.
    abstract public function transform(dict<string, mixed> $attr, HTMLPurifier_Config $config, HTMLPurifier_Context $context): dict<string, mixed>;

    // Prepends CSS properties to the style attribute, creating the attribute if it doesn't exist.
    public function prependCSS(inout dict<string, mixed> $attr, string $css): void {
        //Leaving attribute dictionary value as mixed for now until we get more clarity on the type
        $attr['style'] = C\contains_key($attr, 'style') ? $attr['style'] : null;
        $attr['style'] = $css . (string)$attr['style'];
    }

    // Retrieves and removes an attribute.
    public function confiscateAttr(inout dict<string, mixed> $attr, mixed $key): mixed {
        if (!C\contains($attr, $key)) {
            return null;
        }
        $value = $attr[(string)$key];
        unset($attr[(string)$key]);
        return $value;
    }
}
