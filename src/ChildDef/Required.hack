//created by Nikita Ashok on 6/24;
namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;
use namespace HH\Lib\{C, Vec};

/**
 * Definition that allows a set of elements, but disallows empty children.
 */
class HTMLPurifier_ChildDef_Required extends HTMLPurifier\HTMLPurifier_ChildDef {
	/**
	 * Lookup table of allowed elements.
	 * @type array
	 */
	public dict<string, bool> $elements = dict[
		"abbr" => true,
		"acronym" => true,
		"cite" => true,
		"dfn" => true,
		"kbd" => true,
		"q" => true,
		"samp" => true,
		"var" => true,
		"em" => true,
		"strong" => true,
		"code" => true,
		"span" => true,
		"br" => true,
		"a" => true,
		"sub" => true,
		"sup" => true,
		"b" => true,
		"big" => true,
		"i" => true,
		"small" => true,
		"tt" => true,
		"del" => true,
		"ins" => true,
		"bdo" => true,
		"img" => true,
		"script" => true,
		"noscript" => true,
		"object" => true,
		"basefont" => true,
		"font" => true,
		"s" => true,
		"strike" => true,
		"u" => true,
		"iframe" => true,
		"input" => true,
		"select" => true,
		"textarea" => true,
		"button" => true,
		"label" => true,
		"#PCDATA" => true,
		"h1" => true,
		"h2" => true,
		"h3" => true,
		"h4" => true,
		"p" => true,
		"ul" => true,
		"li" => true,
		"aside" => true,
		"ol" => true,
	];

	/**
	 * Whether or not the last passed node was all whitespace.
	 * @type bool
	 */
	protected bool $whitespace = false;

	/**
	 * @param array|string $elements List of allowed element names (lowercase).
	 */
	public function __construct(dict<string, bool> $elements = dict[]) {
		// if (is_string($elements)) {
		//     $elements = str_replace(' ', '', $elements);
		//     $elements = explode('|', $elements);
		// }
		if (!C\is_empty($elements)) {
			$this->elements = $elements;
		}
	}

	/**
	 * @type bool
	 */
	public bool $allow_empty = false;

	/**
	 * @type string
	 */
	public string $type = 'required';

	/**
	 * @param array $children
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return array
	 */
	public function validateChildren(
		vec<HTMLPurifier\HTMLPurifier_Node> $children,
		HTMLPurifier\HTMLPurifier_Config $_config,
		HTMLPurifier\HTMLPurifier_Context $_context,
	): (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
		// Flag for subclasses
		$this->whitespace = false;

		// if there are no tokens, delete parent node
		if (C\count($children) == 0) {
			return tuple(false, vec[]);
		}

		// the new set of children
		$result = vec[];

		// whether or not parsed character data is allowed
		// this controls whether or not we silently drop a tag
		// or generate escaped HTML from it
		$pcdata_allowed = C\contains_key($this->elements, '#PCDATA');

		// a little sanity check to make sure it's not ALL whitespace
		$all_whitespace = true;

		$stack = \array_reverse($children);
		while (C\count($stack) != 0) {
			$node = C\lastx($stack);
			$stack = Vec\take($stack, C\count($stack) - 1);
			if (
				($node is Node\HTMLPurifier_Node_Comment || $node is Node\HTMLPurifier_Node_Text) &&
				$node->is_whitespace
			) {
				$result[] = $node;
				continue;
			}
			$all_whitespace = false; // phew, we're not talking about whitespace

			if (!C\contains_key($this->elements, $node->name)) {
				// special case text
				// XXX One of these ought to be redundant or something
				if ($pcdata_allowed && $node is Node\HTMLPurifier_Node_Text) {
					$result[] = $node;
					continue;
				}
				// spill the child contents in
				// ToDo: Make configurable
				if ($node is Node\HTMLPurifier_Node_Element) {
					for ($i = C\count($node->children) - 1; $i >= 0; $i--) {
						$stack[] = $node->children[$i];
					}
					continue;
				}
				continue;
			}
			$result[] = $node;
		}
		if (C\is_empty($result)) {
			return tuple(false, vec[]);
		}
		if ($all_whitespace) {
			$this->whitespace = true;
			return tuple(false, vec[]);
		}
		return tuple(true, $result);
	}
}
