// Created by Nikita Ashok ok 6/18/20.
namespace HTMLPurifier\Strategy;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;
use namespace HH\Lib\C;
/**
 * Validate all attributes in the tokens.
 */

class HTMLPurifier_Strategy_ValidateAttributes extends HTMLPurifier\HTMLPurifier_Strategy {

	/**
	 * @param HTMLPurifier_Token[] $tokens
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return HTMLPurifier_Token[]
	 */
	public function execute(
		vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<HTMLPurifier\HTMLPurifier_Token> {
		// setup validator
		$validator = new HTMLPurifier\HTMLPurifier_AttrValidator();

		$token = false;
		$context->register('CurrentToken', $token);

		foreach ($tokens as $_key => $token) {
			// Had to add this in here because PHP was automatically updating with the ref in register 
			$context->register('CurrentToken', $token);
			// only process tokens that have attributes,
			//   namely start and empty tags
			if (!$token is Token\HTMLPurifier_Token_Start && !$token is Token\HTMLPurifier_Token_Empty) {
				continue;
			}

			// skip tokens that are armored
			if (C\contains($token->armor, 'ValidateAttributes')) {
				continue;
			}

			// note that we have no facilities here for removing tokens
			$validator->validateToken($token, $config, $context);
		}
		$context->destroy('CurrentToken');
		return $tokens;
	}
}

// vim: et sw=4 sts=4
