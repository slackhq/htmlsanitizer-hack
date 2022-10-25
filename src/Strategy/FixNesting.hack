//Created by Nikita Ashok on 6/18/20.
namespace HTMLPurifier\Strategy;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Definition, Node};
use namespace Facebook\TypeAssert;
use namespace HH\Lib\{C, Vec};

/**
 * Takes a well formed list of tokens and fixes their nesting.
 *
 * HTML elements dictate which elements are allowed to be their children,
 * for example, you can't have a p tag in a span tag.  Other elements have
 * much more rigorous definitions: tables, for instance, require a specific
 * order for their elements.  There are also constraints not expressible by
 * document type definitions, such as the chameleon nature of ins/del
 * tags and global child exclusions.
 *
 * The first major objective of this strategy is to iterate through all
 * the nodes and determine whether or not their children conform to the
 * element's definition.  If they do not, the child definition may
 * optionally supply an amended list of elements that is valid or
 * require that the entire node be deleted (and the previous node
 * rescanned).
 *
 * The second objective is to ensure that explicitly excluded elements of
 * an element do not appear in its children.  Code that accomplishes this
 * task is pervasive through the strategy, though the two are distinct tasks
 * and could, theoretically, be seperated (although it's not recommended).
 *
 * @note Whether or not unrecognized children are silently dropped or
 *       translated into text depends on the child definitions.
 *
 * @todo Enable nodes to be bubbled out of the structure.  This is
 *       easier with our new algorithm.
 */
class HTMLPurifier_Strategy_FixNesting extends HTMLPurifier\HTMLPurifier_Strategy {

	/**
	 * @param HTMLPurifier_Token[] $tokens
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return array|HTMLPurifier_Token[]
	 */
	public function stackVal(
		HTMLPurifier\HTMLPurifier_Node $node,
		bool $desc,
		vec<string> $exclude,
		int $index,
	): shape('top_node' => HTMLPurifier\HTMLPurifier_Node, 'desc' => bool, 'exclude' => vec<string>, 'ix' => int) {
		return shape('top_node' => $node, 'desc' => $desc, 'exclude' => $exclude, 'ix' => $index);
	}

	public function execute(
		vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<HTMLPurifier\HTMLPurifier_Token> {

		//####################################################################//
		// Pre-processing

		// O(n) pass to convert to a tree, so that we can efficiently
		// refer to substrings
		$top_node = HTMLPurifier\HTMLPurifier_Arborize::arborize($tokens, $config, $context);

		// get a copy of the HTML definition
		$definition = TypeAssert\instance_of(
			Definition\HTMLPurifier_HTMLDefinition::class,
			$config->getHTMLDefinition(),
		);

		$excludes_enabled = !$config->def->defaults['Core.DisableExcludes'];

		// setup the context variable 'IsInline', for chameleon processing
		// is 'false' when we are not inline, 'true' when it must always
		// be inline, and an integer when it is inline for a certain
		// branch of the document tree

		// RAISED AN ERROR INFO_PARENT_DEF == NULL $elementdef_infoparent = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_ElementDef::class, $definition->info_parent_def);
		// THIS REFS NULL $is_inline = $elementdef_infoparent->descendants_are_inline;
		// THIS REFS NULL $context->register('IsInline', $is_inline);

		// setup error collector
		$e = $context->get('ErrorCollector', true);

		//####################################################################//
		// Loop initialization

		// stack that contains all elements that are excluded
		// it is organized by parent elements, similar to $stack,
		// but it is only populated when an element with exclusions is
		// processed, i.e. there won't be empty exclusions.
		// THIS REFS SOMETHING THAT RAISED AN ERROR $exclude_stack = vec[$elementdef_infoparent->excludes];

		// variable that contains the start token while we are processing
		// nodes. This enables error reporting to do its job
		$top_node = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_Node::class, $top_node);
		$node = $top_node;
		// dummy token
		list($token, $d) = $node->toTokenPair();
		$context->register('CurrentNode', $node);
		$context->register('CurrentToken', $token);

		//####################################################################//
		// Loop

		// We need to implement a post-order traversal iteratively, to
		// avoid running into stack space limits.  This is pretty tricky
		// to reason about, so we just manually stack-ify the recursive
		// variant:
		//
		//  function f($node) {
		//      foreach ($node->children as $child) {
		//          f($child);
		//      }
		//      validate($node);
		//  }
		//
		// Thus, we will represent a stack frame as array($node,
		// $is_inline, stack of children)
		// e.g. array_reverse($node->children) - already processed
		// children.

		$parent_def = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_ElementDef::class, $definition->info_parent_def);
		// $stack = array(
		//     array($top_node,
		//           $parent_def->descendants_are_inline,
		//           $parent_def->excludes, // exclusions
		//           0)
		//     );
		$stack = new \SplStack();
		$firstStackVal = $this->stackVal($top_node, $parent_def->descendants_are_inline, $parent_def->excludes, 0);
		$stack->push($firstStackVal);

		while (!$stack->isEmpty()) {
			$stackItem = $stack->pop();
			$node = $stackItem['top_node'];
			$is_inline = $stackItem['desc'];
			$excludes = $stackItem['exclude'];
			$ix = $stackItem['ix'];
			// recursive call
			$go = false;
			if ($stack->isEmpty()) {
				$def = $definition->info_parent_def;
			} else if ($node is Node\HTMLPurifier_Node_Element || $node is Node\HTMLPurifier_Node_Text) {
				$def = $definition->info[$node->name];
			} else {
				$def = null;
			}

			//$def = $stack->isEmpty() ? $definition->info_parent_def : $definition->info[$node->name];
			while (
				$node is Node\HTMLPurifier_Node_Element &&
				($ix < C\count($node->children)) &&
				$node->children[$ix] is nonnull
			) {
				$child = $node->children[$ix];
				$ix += 1;
				if ($child is Node\HTMLPurifier_Node_Element) {
					$go = true;
					$stack->push($this->stackVal($node, $is_inline, $excludes, $ix));
					$child_top_node = $child;
					$child_desc = $is_inline || ($def && $def->descendants_are_inline);
					$def = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_ElementDef::class, $def);
					$child_exclude = ($def && $def->excludes is null)
						? $excludes
						: Vec\concat($excludes, $def->excludes);
					// $stack[] = array($child,
					//     // ToDo: I don't think it matters if it's def or
					//     // child_def, but double check this...
					//     $is_inline || $def->descendants_are_inline,
					//     !$def->excludes ? $excludes
					//                           : array_merge($excludes, $def->excludes),
					//     0);
					$stack->push($this->stackVal($child_top_node, $child_desc, $child_exclude, 0));
					break;
				}
			}
			;
			if ($go) continue;
			list($token, $d) = $node->toTokenPair();
			// base case

			if (
				$excludes_enabled &&
				($node is Node\HTMLPurifier_Node_Element || $node is Node\HTMLPurifier_Node_Text) &&
				C\contains($excludes, $node->name)
			) {
				$node->dead = true;
				// if ($e) $e->send(E_ERROR, 'Strategy_FixNesting: Node excluded');
				echo "Strategy_FixNesting Node excluded";
			} else {
				// XXX I suppose it would be slightly more efficient to
				// avoid the allocation here and have children
				// strategies handle it
				$children = vec[];
				if ($node is Node\HTMLPurifier_Node_Element) {
					foreach ($node->children as $child) {
						if (!$child->dead) $children[] = $child;
					}
				}
				$def = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_ElementDef::class, $def);
				$child = TypeAssert\instance_of(HTMLPurifier\HTMLPurifier_ChildDef::class, $def->child);
				$result = $child->validateChildren($children, $config, $context);
				$check = $result[0];
				$elems = $result[1];
				if ($node is Node\HTMLPurifier_Node_Element) {
					if ($check === true && C\is_empty($elems)) {
						// nop
						$node->children = $children;
					} else if ($check === false && C\is_empty($elems)) {
						$node->dead = true;
						// if ($e) $e->send(E_ERROR, 'Strategy_FixNesting: Node removed');
					} else {
						$node->children = TypeAssert\matches<vec<HTMLPurifier\HTMLPurifier_Node>>($elems);
						// if ($e) {
						//     // XXX This will miss mutations of internal nodes. Perhaps defer to the child validators
						//     if (empty($result) && !empty($children)) {
						//         // $e->send(E_ERROR, 'Strategy_FixNesting: Node contents removed');
						//     } else if ($result != $children) {
						//         // $e->send(E_WARNING, 'Strategy_FixNesting: Node reorganized');
						//     }
						// }

					}
				}
			}
		}

		//####################################################################//
		// Post-processing

		// remove context variables
		$context->destroy('IsInline');
		$context->destroy('CurrentNode');
		$context->destroy('CurrentToken');

		//####################################################################//
		// Return

		return HTMLPurifier\HTMLPurifier_Arborize::flatten($node, $config, $context);
	}
}
