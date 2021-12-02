/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

/**
 * Defines allowed child nodes and validates nodes against it.
 */
abstract class HTMLPurifier_ChildDef {
	// Type of child definition, usually right-most part of class name lowercase
	// Used occasionally in terms of context.
	public string $type;

	// Indicates whether or not an empty array of children is okay

	//This is necessary for redundant checking when changes affecting a child node may cause a parent node to now be disallowed.
	public bool $allow_empty;

	// Lookup array of all elements that this definition could possibly allow.
	public dict<string, bool> $elements = dict[];

	//Get lookup of tag names that should not close this element automatically.
	// All other elements will do so.
	public function getAllowedElements(HTMLPurifier_Config $_config): dict<string, bool> {
		return $this->elements;
	}

	//Validates nodes according to definition and returns modification.
	// Return type: bool|array - true to leave nodes as it, false to remove parent node, array of replacement children
	abstract public function validateChildren(
		vec<HTMLPurifier_Node> $children,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): (bool, vec<HTMLPurifier_Node>);
}
