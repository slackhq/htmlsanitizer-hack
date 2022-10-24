/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Injector that displays the URL of an anchor instead of linking to it, in addition to showing the text of the link.
 */
class HTMLPurifier_Injector_DisplayLinkURI extends HTMLPurifier\HTMLPurifier_Injector {
	/**
	 * @type string
	 */
	public string $name = 'DisplayLinkURI';

	/**
	 * @type array
	 */
	public dict<string, vec<string>> $needed = dict['a' => vec[]];

	/**
	 * @param HTMLPurifier_Token $token
	 */
	public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		$token_end = $token;
		if (!($token_end is Token\HTMLPurifier_Token_End)) {
			throw new \Exception("Token needs to have a start field in handleEnd in DisplayLinkURI");
		}
		if ($token_end is Token\HTMLPurifier_Token_Tag) {
			$token_end_start = $token_end->start;
			if ($token_end_start is Token\HTMLPurifier_Token_Tag && C\contains_key($token_end_start->attr, 'href')) {
				$url = (string)$token_end_start->attr['href'];
				unset($token_end_start->attr['href']);
				$token_end->start = $token_end_start;
				$token = vec[$token_end, new Token\HTMLPurifier_Token_Text(" ($url)")];
			} else if (!($token_end_start is Token\HTMLPurifier_Token_Tag)) {
				throw new \Exception('Tokens are not the correct types in handleEnd in DisplayLinkURI');
			}
		}
		return $token;
	}

	<<__Override>>
	public function handleText(HTMLPurifier\HTMLPurifier_Token $token): void {
	}

	<<__Override>>
	public function handleElement(HTMLPurifier\HTMLPurifier_Token $token): void {
	}
}
