/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */

namespace HTMLPurifier;
use namespace HTMLPurifier\Definition;
use namespace HH\Lib\C;
use namespace Facebook\TypeAssert;

/**
* Injects tokens into the document while parsing for well-formedness.
* This enables "formatter-like" functionality such as auto-paragraphing,
* smiley-ification and linkification to take place.
*
* A note on how handlers create changes; this is done by assigning a new
* value to the $token reference. These values can take a variety of forms and
* are best described HTMLPurifier_Strategy_MakeWellFormed->processToken()
* documentation.
*/
abstract class HTMLPurifier_Injector {

	/**
	* Advisory name of injector, this is for friendly error messages.
	*/
	public string $name;

	protected ?Definition\HTMLPurifier_HTMLDefinition $htmlDefinition;

	/**
	 * Reference to CurrentNesting variable in Context. This is an array
	 * list of tokens that we are currently "inside"
	 */
	public vec<HTMLPurifier_Token> $currentNesting = vec[];

	/**
	 * Reference to current token.
	 */
	protected ?HTMLPurifier_Token $currentToken;

	/**
	 * Reference to InputZipper variable in Context.
	 */
	protected ?HTMLPurifier_Zipper<HTMLPurifier_Token> $inputZipper;

	/**
	 * Array of elements and attributes this injector creates and therefore
	 * need to be allowed by the definition. Takes form of
	 * array('element' => array('attr', 'attr2'), 'element2')
	 */
	public dict<string, vec<string>> $needed = dict[];

	/**
	 * Number of elements to rewind backwards (relative).
	 */
	protected ?int $rewindOffset;

	/**
	 * Rewind to a spot to re-perform processing. This is useful if you
	 * deleted a node, and now need to see if this change affected any
	 * earlier nodes. Rewinding does not affect other injectors, and can
	 * result in infinite loops if not used carefully.
	 * @param int $offset
	 * @warning HTML Purifier will prevent you from fast-forwarding with this
	 *          function.
	 */
	public function rewindOffset(int $offset): void {
		$this->rewindOffset = $offset;
	}

	/**
	 * Retrieves rewind offset, and then unsets it.
	 * @return bool|int
	 */
	public function getRewindOffset(): ?int {
		$r = $this->rewindOffset;
		$this->rewindOffset = null;
		return $r;
	}

	/**
	 * Prepares the injector by giving it the config and context objects:
	 * this allows references to important variables to be made within
	 * the injector. This function also checks if the HTML environment
	 * will work with the Injector (see checkNeeded()).
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
	 */
	public function prepare(HTMLPurifier_Config $config, HTMLPurifier_Context $context): string {
		$def = $config->getHTMLDefinition();
		if (!($def is Definition\HTMLPurifier_HTMLDefinition)) {
			throw new \Exception("Def is not an HTMLDefinition in Injector.hack");
		}
		$this->htmlDefinition = $def;
		// Even though this might fail, some unit tests ignore this and
		// still test checkNeeded, so be careful. Maybe get rid of that
		// dependency.
		$result = $this->checkNeeded($config);
		if ($result !== '') {
			return $result;
		}
		$this->currentNesting = TypeAssert\matches<vec<HTMLPurifier_Token>>($context->get('CurrentNesting'));
		$currentToken = TypeAssert\matches<HTMLPurifier_Token>($context->get('CurrentToken'));
		$this->inputZipper = TypeAssert\matches<HTMLPurifier_Zipper<HTMLPurifier_Token>>($context->get('InputZipper'));
		return '';
	}

	/**
	 * This function checks if the HTML environment
	 * will work with the Injector: if p tags are not allowed, the
	 * Auto-Paragraphing injector should not be enabled.
	 * @param HTMLPurifier_Config $config
	 * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
	 */
	public function checkNeeded(HTMLPurifier_Config $config): string {
		$def = TypeAssert\matches<Definition\HTMLPurifier_HTMLDefinition>($config->getHTMLDefinition());
		foreach ($this->needed as $element => $attributes) {
			if (!C\contains_key($def->info, $element)) {
				return $element;
			}
			foreach ($attributes as $name) {
				if (!C\contains_key($def->info[$element]->attr, $name)) {
					return "$element.$name";
				}
			}
		}
		return '';
	}

	/**
	 * Tests if the context node allows a certain element
	 * @param string $name Name of element to test for
	 * @return bool True if element is allowed, false if it is not
	 */
	public function allowsElement(string $name): bool {
		if (!C\is_empty($this->currentNesting)) {
			$parent_token = C\lastx($this->currentNesting);
			if ($parent_token is Token\HTMLPurifier_Token_Tag || $parent_token is Token\HTMLPurifier_Token_Text) {
				if ($parent_token->name is null) {
					throw new \Exception("Parent Token name is null in allowsElement in Injector.");
				} else {
					$def = $this->htmlDefinition;
					if ($def is null) {
						throw new \Exception("HTML Definition is null");
					}
					$parent = $def->info[$parent_token->name];
				}
			} else {
				throw new \Exception("Token is not the right type of token - should have some sort of name");
			}
		} else {
			$def = $this->htmlDefinition;
			if ($def is null) {
				throw new \Exception("HTML Definition is null");
			}
			$parent = $def->info_parent_def;
		}
		if (
			$parent is nonnull &&
			(!C\contains_key($parent->child->elements, $name) || C\contains($parent->excludes, $name))
		) {
			return false;
		}
		// check for exclusion
		if (!C\is_empty($this->currentNesting)) {
			$i = C\count($this->currentNesting) - 2;
			while ($i >= 0) {
				$node = $this->currentNesting[$i];
				if (!($node is Token\HTMLPurifier_Token_Tag || $node is Token\HTMLPurifier_Token_Text)) {
					throw new \Exception('Node should have some name attribute - check typing in Injector.hack');
				}
				$htmlDef = $this->htmlDefinition;
				if ($htmlDef is null) {
					throw new \Exception("HTML Definition is null in Injector");
				}
				$defExclusion = $htmlDef->info[$node->name];
				if (C\contains($defExclusion->excludes, $name)) {
					return false;
				}
				$i--;
			}
		}
		return true;
	}

	/**
	 * Iterator function, which starts with the next token and continues until
	 * you reach the end of the input tokens.
	 * @warning Please prevent previous references from interfering with this
	 *          functions by setting $i = null beforehand!
	 * @param int $i Current integer index variable for inputTokens
	 * @param HTMLPurifier_Token $current Current token variable.
	 *          Do NOT use $token, as that variable is also a reference
	 * @return bool
	 */
	protected function forward(inout int $i, inout HTMLPurifier_Token $current): bool {
		// if ($i === null) {
		//     $i = C\count($this->inputZipper->back) - 1;
		// } else {
		//     $i--;
		// }
		// The above is no longer needed because $i cannot be null
		$i--;
		if ($i < 0) {
			return false;
		}
		$zipper = $this->inputZipper;
		if ($zipper is null) {
			throw new \Exception("Zipper should not be null - set it in injector");
		}
		$current = $zipper->back[$i];
		return true;
	}

	/**
	 * Similar to _forward, but accepts a third parameter $nesting (which
	 * should be initialized at 0) and stops when we hit the end tag
	 * for the node $this->inputIndex starts in.
	 * @param int $i Current integer index variable for inputTokens
	 * @param HTMLPurifier_Token $current Current token variable.
	 *          Do NOT use $token, as that variable is also a reference
	 * @param int $nesting
	 * @return bool
	 */
	protected function forwardUntilEndToken(inout int $i, inout HTMLPurifier_Token $current, inout int $nesting): bool {
		$result = $this->forward(inout $i, inout $current);
		if (!$result) {
			return false;
		}
		if ($current is Token\HTMLPurifier_Token_Start) {
			$nesting++;
		} elseif ($current is Token\HTMLPurifier_Token_End) {
			if ($nesting <= 0) {
				return false;
			}
			$nesting--;
		}
		return true;
	}

	/**
	 * Iterator function, starts with the previous token and continues until
	 * you reach the beginning of input tokens.
	 * @warning Please prevent previous references from interfering with this
	 *          functions by setting $i = null beforehand!
	 * @param int $i Current integer index variable for inputTokens
	 * @param HTMLPurifier_Token $current Current token variable.
	 *          Do NOT use $token, as that variable is also a reference
	 * @return bool
	 */
	protected function backward(inout int $i, inout HTMLPurifier_Token $current): bool {
		// if ($i === null) {
		//     $i = count($this->inputZipper->front) - 1;
		// } else {
		//     $i--;
		// }
		// The above is no longer needed because $i cannot be null
		$i--;
		if ($i < 0) {
			return false;
		}
		$zipper = $this->inputZipper;
		if ($zipper is null) {
			throw new \Exception("Zipper should not be null - set it in injector");
		}
		$current = $zipper->front[$i];
		return true;
	}

	/**
	 * Handler that is called when a text token is processed
	 */
	abstract public function handleText(HTMLPurifier_Token $token): mixed;

	/**
	 * Handler that is called when a start or empty token is processed
	 */
	abstract public function handleElement(HTMLPurifier_Token $token): mixed;

	/**
	 * Handler that is called when an end token is processed
	 */
	abstract public function handleEnd(HTMLPurifier_Token $token): mixed;
}
