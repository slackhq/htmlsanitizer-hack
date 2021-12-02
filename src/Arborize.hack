// Created by Nikita Ashok on 6/18/20.
namespace HTMLPurifier;
use namespace HH\Lib\C;
use namespace Facebook\TypeAssert;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Node, Token};
/**
 * Converts a stream of HTMLPurifier_Token into an HTMLPurifier_Node,
 * and back again.
 *
 * @note This transformation is not an equivalence.  We mutate the input
 * token stream to make it so; see all [MUT] markers in code.
 */
class HTMLPurifier_Arborize {
	public static function arborize(
		vec<HTMLPurifier_Token> $tokens,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): ?HTMLPurifier_Node {
		$definition = TypeAssert\instance_of(
			Definition\HTMLPurifier_HTMLDefinition::class,
			$config->getHTMLDefinition(),
		);
		$parent = new Token\HTMLPurifier_Token_Start($definition->info_parent);
		$stack = new \SplStack<HTMLPurifier_Node>();
		$stack->push($parent->toNode());
		foreach ($tokens as $token) {
			$token->skip = vec[]; // [MUT]
			$token->carryover = false; // [MUT]
			if ($token is Token\HTMLPurifier_Token_End) {
				$token->start = null; // [MUT]
				$r = $stack->pop();
				//assert($r->name === $token->name);
				//assert(empty($token->attr));
				if ($r is Node\HTMLPurifier_Node_Element) {
					$r->endCol = $token->col;
					$r->endLine = $token->line;
					$r->endArmor = $token->armor;
				}
				continue;
			}
			$node = $token->toNode();
			//peek
			$last_node = TypeAssert\instance_of(Node\HTMLPurifier_Node_Element::class, $stack->pop());
			$stack->push($last_node);
			$last_node->children[] = $node;
			if ($token is Token\HTMLPurifier_Token_Start) {
				$stack->push($node);
			}
		}
		//assert(count($stack) == 1);
		return $stack->pop();
	}

	public static function flatten(
		HTMLPurifier_Node $node,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): vec<HTMLPurifier_Token> {
		$level = 0;
		$first_queue = new \SplQueue<HTMLPurifier_Node>();
		// $first_vec = vec[$node];
		$first_queue->push($node);
		$nodes = dict[$level => $first_queue];
		$closingTokens = dict[];
		$tokens = vec[];
		do {
			while (!$nodes[$level]->isEmpty()) {
				$node = $nodes[$level]->dequeue(); // FIFO
				list($start, $end) = $node->toTokenPair();
				if ($level > 0) {
					$tokens[] = $start;
				}
				if ($end !== NULL) {
					if (C\contains_key($closingTokens, $level)) {
						$closingTokens[$level]->push($end);
					} else {
						$close_stack = new \SplStack();
						$close_stack->push($end);
						$closingTokens[$level] = $close_stack;
					}
				}
				if ($node is Node\HTMLPurifier_Node_Element) {
					$level++;
					$nodes[$level] = new \SplQueue<HTMLPurifier_Node>();
					foreach ($node->children as $childNode) {
						$nodes[$level]->push($childNode);
					}
				}
			}
			$level--;
			if ($level && C\contains_key($closingTokens, $level)) {
				while (!$closingTokens[$level]->isEmpty()) {
					$tokens[] = $closingTokens[$level]->pop();
				}
			}
		} while ($level > 0);
		return $tokens;
	}
}
