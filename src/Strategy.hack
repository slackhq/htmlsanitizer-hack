/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
/**
 * Supertype for classes that define a strategy for modifying/purifying tokens.
 *
 * While HTMLPurifier's core purpose is fixing HTML into something proper,
 * strategies provide plug points for extra configuration or even extra
 * features, such as custom tags, custom parsing of text, etc.
 */

namespace HTMLPurifier;

abstract class HTMLPurifier_Strategy {

	/**
	 * Executes the strategy on the tokens.
	 */
	abstract public function execute(
		vec<HTMLPurifier_Token> $tokens,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): vec<HTMLPurifier_Token>;
}
