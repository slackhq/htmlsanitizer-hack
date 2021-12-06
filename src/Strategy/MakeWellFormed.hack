/* Created by Jacob Polacek on 6/16/2020 */

namespace HTMLPurifier\Strategy;

use HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Definition, Injector, Token};
use namespace Facebook\TypeAssert;

/**
* Takes tokens makes them well-formed (balance end tags, etc.)
*
* Specification of the armor attributes this strategy uses:
*
*      - MakeWellFormed_TagClosedError: This armor field is used to
*        suppress tag closed errors for certain tokens [TagClosedSuppress],
*        in particular, if a tag was generated automatically by HTML
*        Purifier, we may rely on our infrastructure to close it for us
*        and shouldn't report an error to the user [TagClosedAuto].
*/
class HTMLPurifier_Strategy_MakeWellFormed extends HTMLPurifier\HTMLPurifier_Strategy {
	/**
	* Array stream of tokens being processed
	*/
	protected vec<HTMLPurifier\HTMLPurifier_Token> $tokens = vec[];

	/**
	* Current token
	*/
	protected ?HTMLPurifier\HTMLPurifier_Token $token;

	/**
	* Zipper managing the true state
	*/
	protected ?HTMLPurifier\HTMLPurifier_Zipper<HTMLPurifier\HTMLPurifier_Token> $zipper;

	/**
	* Current nesting of elements
	* @note I would like some discussion on the type of this
	* the PHP docstring just says it's an array - but of what?
	*/
	protected vec<HTMLPurifier\HTMLPurifier_Token> $stack = vec[];

	/**
	* Injectors active in this stream processing
	*/
	protected vec<HTMLPurifier\HTMLPurifier_Injector> $injectors = vec[];

	/**
	* Current instance of HTMLPurifier_Config
	*/
	protected ?HTMLPurifier\HTMLPurifier_Config $config;

	/**
	* Current instance of HTMLPurifier_Context
	*/
	protected ?HTMLPurifier\HTMLPurifier_Context $context;

	public function execute(
		vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<HTMLPurifier\HTMLPurifier_Token> {
		$definition = TypeAssert\instance_of(
			Definition\HTMLPurifier_HTMLDefinition::class,
			$config->getHTMLDefinition(),
		);

		// local variables
		$generator = new HTMLPurifier\HTMLPurifier_Generator($config, $context);
		$escape_invalid_tags = $config->def->defaults['Core.EscapeInvalidTags'];
		// used for autoclose early abortion
		// $global_parent_allowed_elements = $definition->info_parent_def->child->getAllowedElements($config);
		$e = $context->get('ErrorCollector', true);
		$i = false; // injector index
		$tuple = HTMLPurifier\HTMLPurifier_Zipper::fromArray($tokens);
		$zipper = $tuple[0];
		$token = $tuple[1];
		if (!$token) {
			return vec[];
		}
		$reprocess = false;
		$stack = vec[];

		// member variables
		$this->stack = $stack;
		$this->tokens = $tokens;
		$this->token = $token;
		$this->zipper = $zipper;
		$this->config = $config;
		$this->context = $context;

		// context variables
		$context->register('CurrentNesting', $stack);
		$context->register('InputZipper', $zipper);
		$context->register('CurrentToken', $token);

		// -- begin INJECTOR --

		$this->injectors = vec[];

		$injectors = $config->getBatch('AutoFormat');
		$def_injectors = $definition->info_injector;
		$custom_injectors = TypeAssert\matches<vec<HTMLPurifier\HTMLPurifier_Injector>>($injectors['Custom']);
		unset($injectors['Custom']); // special case
		foreach ($injectors as $injector => $b) {
			// XXX: Fix with a legitimate lookup table of enabled filters
			if (Str\search($injector, '.') is nonnull) {
				continue;
			}
			if (!$b) {
				continue;
			}

			switch ($injector) {
				case ("AutoParagraph"):
					$this->injectors[] = new Injector\HTMLPurifier_Injector_AutoParagraph();
					break;
				case ("DisplayLinkURI"):
					$this->injectors[] = new Injector\HTMLPurifier_Injector_DisplayLinkURI();
					break;
				case ("Linkify"):
					$this->injectors[] = new Injector\HTMLPurifier_Injector_Linkify();
					break;
				case ("PurifierLinkify"):
					$this->injectors[] = new Injector\HTMLPurifier_Injector_PurifierLinkify();
					break;
				case ("RemoveEmpty"):
					$this->injectors[] = new Injector\HTMLPurifier_Injector_RemoveEmpty();
					break;
				default:
					throw new \Exception(
						"$injector is not allowed for the time being. If you are seeing this, please change your AutoFormat configuration.",
					);
			}
		}
		foreach ($def_injectors as $injector) {
			// assumed to be objects
			$this->injectors[] = $injector;
		}
		foreach ($custom_injectors as $injector) {
			$this->injectors[] = $injector;
		}

		// give the injectors references to the definition and context
		// variables for performance reasons
		foreach ($this->injectors as $ix => $injector) {
			$error = $injector->prepare($config, $context);
			if (!$error) {
				continue;
			}
			$injectors = $this->injectors;
			\array_splice(inout $injectors, $ix, 1); // rm the injector
			$this->injectors = TypeAssert\matches<vec<HTMLPurifier\HTMLPurifier_Injector>>($injectors);
			throw new \Error("Cannot enable {$injector->name} injector because $error is not allowed", \E_USER_WARNING);
		}

		// -- end INJECTOR --

		// a note on reprocessing:
		//      In order to reduce code duplication, whenever some code needs
		//      to make HTML changes in order to make things "correct", the
		//      new HTML gets sent through the purifier, regardless of its
		//      status. This means that if we add a start token, because it
		//      was totally necessary, we don't have to update nesting; we just
		//      punt ($reprocess = true; continue;) and it does that for us.

		// isset is in loop because $tokens size changes during loop exec
		// only increment if we don't need to reprocess
		while (true) {
			// check for a rewind
			if ($i is int) {
				// possibility: disable rewinding if the current token has a
				// rewind set on it already. This would offer protection from
				// infinite loop, but might hinder some advanced rewinding.
				$rewind_offset = $this->injectors[$i]->getRewindOffset();
				if ($rewind_offset is int) {
					for ($j = 0; $j < $rewind_offset; $j++) {
						if (C\is_empty($zipper->front)) break;
						$token = $zipper->prev($token);
						// indicate that other injectors should not process this token,
						// but we need to reprocess it.  See Note [Injector skips]
						if ($token is null) {
							throw new \Exception(
								"Token should not be null at this point - check injector implementation",
							);
						}
						$first_part = Vec\slice($token->skip, 0, $i);
						$second_part = Vec\slice($token->skip, $i + 1);
						$token->skip = Vec\concat($first_part, $second_part);
						$token->rewind = $i;
						if ($token is Token\HTMLPurifier_Token_Start) {
							$stack_length = C\count($this->stack);
							$this->stack = Vec\take($this->stack, $stack_length - 1);
						} elseif ($token is Token\HTMLPurifier_Token_End && $token->start is nonnull) {
							$this->stack[] = $token->start;

						}
					}
				}
				$i = false;
			}
			if ($token is null) {
				// kill processing if stack is empty
				if (C\count($this->stack) == 0) {
					break;
				}

				// peek
				$top_nesting = C\last($this->stack);

				// send error [TagClosedSuppress]
				// if ($e && !isset($top_nesting->armor['MakeWellFormed_TagClosedError'])) {
				//     $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag closed by document end', $top_nesting);
				// }

				// append, don't splice, since this is the end
				// I'm not sure what type I should make the stack
				// If I just make it HTMLPurifier_Token, then name's not always there
				if ($top_nesting is Token\HTMLPurifier_Token_Tag || $top_nesting is Token\HTMLPurifier_Token_Text) {
					$token = new Token\HTMLPurifier_Token_End($top_nesting->name);
					$this->token = $token;
				}

				// punt!
				$reprocess = false;
				continue;
			}

			// quick-check: if it's not a tag, no need to process
			if (!($token is Token\HTMLPurifier_Token_Tag)) {
				if ($token is Token\HTMLPurifier_Token_Text) {
					foreach ($this->injectors as $i => $injector) {
						if (C\contains_key($token->skip, $i)) {
							// See Note [Injector skips]
							continue;
						}
						if ($token->rewind is nonnull && $token->rewind !== $i) {
							continue;
						}
						$r = $token;
						$r_mixed = $injector->handleText($r);
						if ($r_mixed is nonnull) {
							$token = $this->processToken($r_mixed, $i, $injector);
						} else {
							$token = $this->processToken($r, $i, $injector);
						}
						$reprocess = true;
						break;
					}
				}
				// another possibility is a comment
				if ($reprocess) {
					$reprocess = false;
				} else {
					$token = $zipper->next($token);
					$this->token = $token;
				}
				continue;
			}

			if ($token is Token\HTMLPurifier_Token_Tag || $token is Token\HTMLPurifier_Token_Text) {
				if (C\contains_key($definition->info, $token->name)) {
					$child = TypeAssert\instance_of(
						HTMLPurifier\HTMLPurifier_ChildDef::class,
						$definition->info[$token->name]->child,
					);
					$type = $child->type;
				} else {
					$type = 'false'; // Type is unknown, treat accordingly
				}
			} else {
				$type = 'false';
			}
			// quick tag checks: anything that's *not* an end tag
			$ok = false;
			if ($type === 'empty' && $token is Token\HTMLPurifier_Token_Start) {
				// claims to be a start tag but is empty
				$token = new Token\HTMLPurifier_Token_Empty(
					$token->name,
					$token->attr,
					$token->line,
					$token->col,
					$token->armor,
				);
				$this->token = $token;
				$ok = true;
			} elseif ($type && $type !== 'empty' && $token is Token\HTMLPurifier_Token_Empty) {
				// claims to be empty but really is a start tag
				// NB: this assignment is required
				$old_token = $token;
				$token = new Token\HTMLPurifier_Token_End($token->name);
				$this->token = $token;
				$token = $this->insertBefore(
					new Token\HTMLPurifier_Token_Start(
						$old_token->name,
						$old_token->attr,
						$old_token->line,
						$old_token->col,
						$old_token->armor,
					),
				);
				$this->token = $token;
				// punt (since we had to modify the input stream in a non-trivial way)
				$reprocess = false;
				continue;
			} elseif ($token is Token\HTMLPurifier_Token_Empty) {
				// real empty token
				$ok = true;
			} elseif ($token is Token\HTMLPurifier_Token_Start) {
				$ok = true;
			}

			if ($ok) {
				foreach ($this->injectors as $i => $injector) {
					if (C\contains_key($token->skip, $i)) {
						// See Note [Injector skips]
						continue;
					}
					if ($token->rewind is nonnull && $token->rewind !== $i) {
						continue;
					}
					$r = $token;
					$r_mixed = $injector->handleElement($r);
					if ($r_mixed is nonnull) {
						$token = $this->processToken($r_mixed, $i, $injector);
					} else {
						$token = $this->processToken($r, $i, $injector);
					}
					$reprocess = true;
					break;
				}
				if (!$reprocess) {
					// ah, nothing interesting happened; do normal processing
					if ($token is Token\HTMLPurifier_Token_Start) {
						$this->stack[] = $token;
						if ($i is int) {
							$this->injectors[$i]->currentNesting[] = $token;
						}
					} elseif ($token is Token\HTMLPurifier_Token_End) {
						throw new \Exception(
							'Improper handling of end tag in start code; possible error in MakeWellFormed',
						);
					}
				}
				if ($reprocess) {
					$reprocess = false;
				} else {
					$token = $zipper->next($token);
					$this->token = $token;
				}
				continue;
			}

			// sanity check: we should be dealing with a closing tag
			if (!($token is Token\HTMLPurifier_Token_End)) {
				throw new \Exception('Unaccounted for tag token in input stream, bug in HTML Purifier');
			}

			// make sure that we have something open
			if (C\count($this->stack) == 0) {
				if ($escape_invalid_tags) {
					if ($e) {
						throw new \Exception('Strategy_MakeWellFormed: Unnecessary end tag to text');
					}
					$token = new Token\HTMLPurifier_Token_Text($generator->generateFromToken($token));
					$this->token = $token;
				} else {
					if ($e) {
						throw new \Exception('Strategy_MakeWellFormed: Unnecessary end tag removed');
					}
					$token = $this->remove();
					$this->token = $token;
				}
				$reprocess = false;
				continue;
			}

			// first, check for the simplest case: everything closes neatly.
			// Eventually, everything passes through here; if there are problems
			// we modify the input stream accordingly and then punt, so that
			// the tokens get processed again.
			$current_parent = C\lastx($this->stack);
			$this->stack = Vec\take($this->stack, C\count($this->stack) - 1);
			if (
				($current_parent is Token\HTMLPurifier_Token_Tag || $current_parent is Token\HTMLPurifier_Token_Text) &&
				$current_parent->name == $token->name
			) {
				$token->start = $current_parent;
				foreach ($this->injectors as $i => $injector) {
					if (C\contains_key($token->skip, $i)) {
						// See Note [Injector skips]
						continue;
					}
					if ($token->rewind is nonnull && $token->rewind !== $i) {
						continue;
					}
					$r = $token;
					$r_mixed = $injector->handleEnd($r);
					if ($r_mixed is nonnull) {
						$token = $this->processToken($r_mixed, $i, $injector);
					} else {
						$token = $this->processToken($r, $i, $injector);
					}
					$this->stack[] = $current_parent;
					$reprocess = true;
					break;
				}
				if ($reprocess) {
					$reprocess = false;
				} else {
					$token = $zipper->next($token);
				}
				continue;
			}
			$this->stack[] = $current_parent;

			// okay, so now we're trying to close the wrong tag

			// scroll back the entire nest, trying to find our tag
			// (feature could be to specify how far you'd like to go)
			$size = C\count($this->stack);
			// -2 because -1 is the last element, but we already checked that
			$skipped_tags = vec[];
			for ($j = $size - 2; $j >= 0; $j--) {
				$stack_token = $this->stack[$j];
				if (
					($stack_token is Token\HTMLPurifier_Token_Tag || $stack_token is Token\HTMLPurifier_Token_Text) &&
					$stack_token->name == $token->name
				) {
					$skipped_tags = Vec\slice($this->stack, $j);
					break;
				}
			}

			// we didn't find the tag, so remove
			$skipped_tags_count = C\count($skipped_tags);
			if ($skipped_tags_count == 0) {
				if ($escape_invalid_tags) {
					if ($e) {
						throw new \Exception('Strategy_MakeWellFormed: Stray end tag to text');
					}
					$token = new Token\HTMLPurifier_Token_Text($generator->generateFromToken($token));
					$this->token = $token;
				} else {
					if ($e) {
						throw new \Exception('Strategy_MakeWellFormed: Stray end tag removed');
					}
					$token = $this->remove();
					$this->token = $token;
				}
				$reprocess = false;
				continue;
			}

			// do errors, in REVERSE $j order: a,b,c with </a></b></c>
			if ($e) {
				for ($j = $skipped_tags_count - 1; $j > 0; $j--) {
					// notice we exclude $j == 0, i.e. the current ending tag, from
					// the errors... [TagClosedSuppress]
					$skipped_tag_armor = $skipped_tags[$j]->armor;
					if ($skipped_tag_armor && !C\contains($skipped_tag_armor, 'MakeWellFormed_TagClosedError')) {
						// $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag closed by element end', $skipped_tags[$j]);
						echo 'Strategy_MakeWellFormed: Tag closed by element end';
					}
				}
			}

			// insert tags, in FORWARD $j order: c,b,a with </a></b></c>
			$replace = vec[$token];
			for ($j = 1; $j < $skipped_tags_count; $j++) {
				// ...as well as from the insertions
				$skipped_tag = $skipped_tags[$j];
				if ($skipped_tag is Token\HTMLPurifier_Token_Tag || $skipped_tag is Token\HTMLPurifier_Token_Text) {
					$new_token = new Token\HTMLPurifier_Token_End($skipped_tag->name);
					$new_token->start = $skipped_tag;
					$reversed_replace = Vec\reverse($replace);
					$reversed_replace[] = $new_token;
					$replace = Vec\reverse($reversed_replace);
					if (isset($definition->info[$new_token->name]) && $definition->info[$new_token->name]->formatting) {
						// [TagClosedAuto]
						$element = clone $skipped_tag;
						$element->carryover = true;
						$element->armor[] = 'MakeWellFormed_TagClosedError';
						$replace[] = $element;
					}
				}
			}
			// $token = $this->processToken($replace);
			$reprocess = false;
			continue;
		}

		$context->destroy('CurrentToken');
		$context->destroy('CurrentNesting');
		$context->destroy('InputZipper');

		// resetting back to initialized vals
		$this->injectors = vec[];
		$this->stack = vec[];
		$this->tokens = vec[];
		return $zipper->toArray($token);
	}

	/**
	 * Processes arbitrary token values for complicated substitution patterns.
	 * In general:
	 *
	 * If $token is an array, it is a list of tokens to substitute for the
	 * current token. These tokens then get individually processed. If there
	 * is a leading integer in the list, that integer determines how many
	 * tokens from the stream should be removed.
	 *
	 * If $token is a regular token, it is swapped with the current token.
	 *
	 * If $token is false, the current token is deleted.
	 *
	 * If $token is an integer, that number of tokens (with the first token
	 * being the current one) will be deleted.
	 *
	 * @param HTMLPurifier_Token|array|int|bool $token Token substitution value
	 * @param HTMLPurifier_Injector|int $injector Injector that performed the substitution; default is if
	 *        this is not an injector related operation.
	 * @throws HTMLPurifier_Exception
	 */
	protected function processToken(
		mixed $token,
		int $i,
		HTMLPurifier\HTMLPurifier_Injector $injector,
	): ?HTMLPurifier\HTMLPurifier_Token {
		// Zend OpCache miscompiles $token = array($token), so
		// avoid this pattern.  See: https://github.com/ezyang/htmlpurifier/issues/108
		// normalize forms of token

		if (\is_object($token)) {
			$tmp = $token;
			$token = vec[1, $tmp];
		}
		if ($token is int) {
			$tmp = $token;
			$token = vec[$tmp];
		}
		if ($token === false) {
			$token = vec[1];
		}
		if (!($token is vec<_>)) {
			throw new \Exception('Invalid token type from injector');
		}
		if (!($token[0] is int)) {
			\array_unshift(inout $token, 1);
		}
		if ($token[0] === 0) {
			throw new \Exception('Deleting zero tokens is not valid');
		}

		// $token is now an array with the following form:
		// array(number nodes to delete, new node 1, new node 2, ...)

		$delete = \array_shift(inout $token);
		$zipper = $this->zipper;
		if ($zipper is null) {
			throw new \Exception("Zipper should not be null in processToken in MakeWellFormed");
		}
		$thisToken = $this->token;
		if ($thisToken is null) {
			throw new \Exception("This token should not be null in processToken in MakeWellFormed");
		}
		list($old, $r) = $zipper->splice($thisToken, $delete, $token);
		$this->zipper = $zipper;
		$this->token = $thisToken;

		if ($injector is nonnull) {
			// See Note [Injector skips]
			// Determine appropriate skips.  Here's what the code does:
			//  *If* we deleted one or more tokens, copy the skips
			//  of those tokens into the skips of the new tokens (in $token).
			//  Also, mark the newly inserted tokens as having come from
			//  $injector.
			$old0 = $old[0];
			$oldskip = $old0 is nonnull ? $old0->skip : vec[];
			foreach ($token as $object) {
				$object->skip = $oldskip;
				$skip_len = C\count($object->skip);
				if ($i < $skip_len) {
					$object->skip[$i] = true;
				} else {
					$object->skip[] = true;
				}
			}
		}

		return $r;
	}

	/**
	* Inserts a token before the current token. Cursor now points to
	* this token.  You must reprocess after this.
	* @param HTMLPurifier_Token $token
	*/
	private function insertBefore(HTMLPurifier\HTMLPurifier_Token $token): ?HTMLPurifier\HTMLPurifier_Token {
		// NB not $this->zipper->insertBefore(), due to positioning
		// differences
		if ($this->zipper is nonnull && $this->token is nonnull) {
			$splice = $this->zipper->splice($this->token, 0, vec[$token]);
			return $splice[1];
		} else {
			return null;
		}
	}

	// /**
	//  * Removes current token. Cursor now points to new token occupying previously
	//  * occupied space.  You must reprocess after this.
	//  */
	private function remove(): ?HTMLPurifier\HTMLPurifier_Token {
		if ($this->zipper is null) {
			throw new \Exception("Zipper can't be null");
		}
		return $this->zipper->delete();
	}

}
