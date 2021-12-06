/* Created by Jacob Polacek on 6/17/2020 */

namespace HTMLPurifier\Strategy;
use HH\Lib\{C, Str};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;
use namespace HTMLPurifier\Definition;
use Facebook\{TypeAssert, TypeCoerce, TypeSpec};

/**
 * Removes all unrecognized tags from the list of tokens.
 *
 * This strategy iterates through all the tokens and removes unrecognized
 * tokens. If a token is not recognized but a TagTransform is defined for
 * that element, the element will be transformed accordingly.
 */
class HTMLPurifier_Strategy_RemoveForeignElements extends HTMLPurifier\HTMLPurifier_Strategy {

	/**
	 * @param HTMLPurifier_Token[] $tokens
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return array|HTMLPurifier_Token[]
	 */
	public function execute(
		vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<HTMLPurifier\HTMLPurifier_Token> {
		$definition = TypeAssert\instance_of(
			Definition\HTMLPurifier_HTMLDefinition::class,
			$config->getHTMLDefinition(),
		);
		$generator = new HTMLPurifier\HTMLPurifier_Generator($config, $context);
		$result = vec[];

		$escape_invalid_tags = $config->def->defaults['Core.EscapeInvalidTags'];
		$remove_invalid_img = $config->def->defaults['Core.RemoveInvalidImg'];

		// currently only used to determine if comments should be kept
		$trusted = $config->def->defaults['HTML.Trusted'];
		$comment_lookup = $config->def->defaults['HTML.AllowedComments'];
		$comment_regexp = $config->def->defaults['HTML.AllowedCommentsRegexp'];
		$check_comments = $comment_lookup !== vec<string>[] || $comment_regexp is nonnull;

		$remove_script_contents = $config->def->defaults['Core.RemoveScriptContents'];
		$hidden_elements = $config->def->defaults['Core.HiddenElements'];

		// remove script contents compatibility
		if ($remove_script_contents === true) {
			$hidden_elements['script'] = true;
		} elseif ($remove_script_contents === false && isset($hidden_elements['script'])) {
			unset($hidden_elements['script']);
		}

		$attr_validator = new HTMLPurifier\HTMLPurifier_AttrValidator();

		// removes tokens until it reaches a closing tag with its value
		$remove_until = false;

		// converts comments into text tokens when this is equal to a tag name
		$textify_comments = false;

		$token = false;
		$context->register('CurrentToken', $token);

		$e = false;
		if ($config->def->defaults['Core.CollectErrors']) {
			$e = $context->get('ErrorCollector');
		}

		foreach ($tokens as $token) {
			$context->register('CurrentToken', $token);
			if ($remove_until) {
				// This $token->name !== $remove_until is always true...
				if (!($token is Token\HTMLPurifier_Token_Tag)) {
					continue;
				}
			}
			if ($token is Token\HTMLPurifier_Token_Tag) {
				// DEFINITION CALL

				// before any processing, try to transform the element
				// if (isset($definition->info_tag_transform[$token->name])) {
				//     $original_name = $token->name;
				//     // there is a transformation for this tag
				//     // DEFINITION CALL
				//     $token = $definition->
				//         info_tag_transform[$token->name]->transform($token, $config, $context);
				//     if ($e) {
				//         echo 'Strategy_RemoveForeignElements: Tag transform' . $original_name;
				//     }
				// }

				if (C\contains_key($definition->info, $token->name) && $definition->info[$token->name]) {
					// mostly everything's good, but
					// we need to make sure required attributes are in order
					if (
						($token is Token\HTMLPurifier_Token_Start || $token is Token\HTMLPurifier_Token_Empty) &&
						$definition->info[$token->name]->required_attr &&
						($token->name != 'img' || $remove_invalid_img) // ensure config option still works
					) {
						$attr_validator->validateToken($token, $config, $context);
						$ok = true;
						foreach ($definition->info[$token->name]->required_attr as $name) {
							if (!C\contains_key($token->attr, $name)) {
								$ok = false;
								break;
							}
						}
						if (!$ok) {
							if ($e) {
								echo 'Strategy_RemoveForeignElements: Missing required attribute';
							}
							continue;
						}
						if ($token->armor is nonnull) {
							$token->armor[] = "ValidateAttributes";
							$context->register('CurrentToken', $token);
						}
					}

					if (isset($hidden_elements[$token->name]) && $token is Token\HTMLPurifier_Token_Start) {
						$textify_comments = $token->name;
					} elseif ($token->name === $textify_comments && $token is Token\HTMLPurifier_Token_End) {
						$textify_comments = false;
					}

				} elseif ($escape_invalid_tags) {
					// invalid tag, generate HTML representation and insert in
					if ($e) {
						echo 'Strategy_RemoveForeignElements: Foreign element to text';
					}
					$token = new Token\HTMLPurifier_Token_Text($generator->generateFromToken($token));
					$context->register('CurrentToken', $token);
				} else {
					// check if we need to destroy all of the tag's children
					// CAN BE GENERICIZED
					if (isset($hidden_elements[$token->name])) {
						if ($token is Token\HTMLPurifier_Token_Start) {
							$remove_until = $token->name;
						} elseif ($token is Token\HTMLPurifier_Token_Empty) {
							// do nothing: we're still looking
						} else {
							$remove_until = false;
						}
						if ($e) {
							echo 'Strategy_RemoveForeignElements: Foreign meta element removed';
						}
					} else {
						if ($e) {
							echo 'Strategy_RemoveForeignElements: Foreign element removed';
						}
					}
					continue;
				}
			} elseif ($token is Token\HTMLPurifier_Token_Comment) {
				// textify comments in script tags when they are allowed
				if ($textify_comments !== false) {
					$data = $token->data;
					$token = new Token\HTMLPurifier_Token_Text($data);
					$context->register('CurrentToken', $token);
				} elseif ($trusted || $check_comments) {
					// always cleanup comments
					$trailing_hyphen = false;
					if ($e) {
						// perform check whether or not there's a trailing hyphen iff length > 0
						if (Str\length($token->data) && Str\slice($token->data, -1) == '-') {
							$trailing_hyphen = true;
						}
					}
					$token->data = Str\trim_right($token->data, '-');
					$context->register('CurrentToken', $token);
					$found_double_hyphen = false;
					while (Str\search($token->data, '--') is nonnull) {
						$found_double_hyphen = true;
						$token->data = Str\replace('--', '-', $token->data);
						$context->register('CurrentToken', $token);
					}
					if (
						$trusted ||
						C\contains($comment_lookup, Str\trim($token->data)) ||
						($comment_regexp is nonnull && \preg_match($comment_regexp, Str\trim($token->data)))
					) {
						// OK good
						if ($e) {
							if ($trailing_hyphen) {
								echo 'Strategy_RemoveForeignElements: Trailing hyphen in comment removed';
							}
							if ($found_double_hyphen) {
								echo 'Strategy_RemoveForeignElements: Hyphens in comment collapsed';
							}
						}
					} else {
						if ($e) {
							echo 'Strategy_RemoveForeignElements: Comment removed';
						}
						continue;
					}
				} else {
					// strip comments
					if ($e) {
						echo 'Strategy_RemoveForeignElements: Comment removed';
					}
					continue;
				}
			} elseif ($token is Token\HTMLPurifier_Token_Text) {
			} else {
				continue;
			}
			$result[] = $token;
		}
		if ($remove_until && $e) {
			// we removed tokens until the end, throw error
			throw new \Error('Strategy_RemoveForeignElements: Token removed to end');
		}
		$context->destroy('CurrentToken');
		return $result;
	}
}
