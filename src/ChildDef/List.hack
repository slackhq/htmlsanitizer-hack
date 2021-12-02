/* Created by Jacob Polacek on 06/30/2020 */

namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Definition, Node};
use namespace HH\Lib\C;

/**
 * Definition for list containers ul and ol.
 *
 * What does this do?  The big thing is to handle ol/ul at the top
 * level of list nodes, which should be handled specially by /folding/
 * them into the previous list node.  We generally shouldn't ever
 * see other disallowed elements, because the autoclose behavior
 * in MakeWellFormed handles it.
 */
class HTMLPurifier_ChildDef_List extends HTMLPurifier\HTMLPurifier_ChildDef {
	public string $type = 'list';

	public dict<string, bool> $elements = dict['li' => true, 'ul' => true, 'ol' => true];

	public bool $allow_empty = false;

	public bool $whitespace = false;
	/**
	 * @param array $children
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return array
	 */
	public function validateChildren(
		vec<HTMLPurifier\HTMLPurifier_Node> $children,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $_context,
	): (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
		// Flag for subclasses
		$this->whitespace = false;

		// if there are no tokens, delete parent node
		if (C\count($children) == 0) {
			return tuple(false, vec[]);
		}

		// if li is n   ot allowed, delete parent node
		$html_def = $config->getHTMLDefinition();
		if (
			$html_def is nonnull &&
			$html_def is Definition\HTMLPurifier_HTMLDefinition &&
			!C\contains_key($html_def->info, 'li')
		) {
			throw new \Error("Cannot allow ul/ol without allowing li", \E_USER_WARNING);
		}

		// the new set of children
		$result = vec[];

		// a little sanity check to make sure it's not ALL whitespace
		$all_whitespace = true;

		$current_li = null;

		foreach ($children as $node) {
			if (
				($node is Node\HTMLPurifier_Node_Text || $node is Node\HTMLPurifier_Node_Comment) &&
				$node->is_whitespace
			) {
				$result[] = $node;
				continue;
			}
			$all_whitespace = false; // phew, we're not talking about whitespace

			if (
				($node is Node\HTMLPurifier_Node_Text || $node is Node\HTMLPurifier_Node_Element) &&
				$node->name === 'li'
			) {
				// good
				$current_li = $node;
				$result[] = $node;
			} else {
				// we want to tuck this into the previous li
				// Invariant: we expect the node to be ol/ul
				// ToDo: Make this more robust in the case of not ol/ul
				// by distinguishing between existing li and li created
				// to handle non-list elements; non-list elements should
				// not be appended to an existing li; only li created
				// for non-list. This distinction is not currently made.
				if ($current_li === null) {
					$current_li = new Node\HTMLPurifier_Node_Element('li');
					$result[] = $current_li;
					$current_li->children[] = $node;
					$current_li->empty = false; // XXX fascinating! Check for this error elsewhere ToDo
				}
			}
		}
		if (C\is_empty($result)) {
			return tuple(false, vec[]);
		}
		if ($all_whitespace) {
			return tuple(false, vec[]);
		}
		return tuple(true, $result);
	}
}
