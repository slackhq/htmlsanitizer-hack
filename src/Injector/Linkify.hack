/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Injector that converts http, https and ftp text URLs to actual links.
 */
class HTMLPurifier_Injector_Linkify extends HTMLPurifier\HTMLPurifier_Injector {
	/**
	 * @type string
	 */
	public string $name = 'Linkify';

	/**
	 * @type array
	 */
	public dict<string, vec<string>> $needed = dict['a' => vec['href']];

	/**
	 * @param HTMLPurifier_Token $token
	 */
	public function handleText(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		if (!$this->allowsElement('a')) {
			return $token;
		}

		if ($token is Token\HTMLPurifier_Token_Text && !Str\contains($token->data, '://')) {
			// our really quick heuristic failed, abort
			// this may not work so well if we want to match things like
			// "google.com", but then again, most people don't
			return $token;
		}

		// there is/are URL(s). Let's split the string.
		// We use this regex:
		// https://gist.github.com/gruber/249502
		// but with @cscott's backtracking fix and also
		// the Unicode characters un-Unicodified.
		if (!($token is Token\HTMLPurifier_Token_Text)) {
			throw new \Exception("Token should have a data field in handleText in Linkify.hack");
		}
		$bits = \preg_split(
			'/\\b((?:[a-z][\\w\\-]+:(?:\\/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}\\/)(?:[^\\s()<>]|\\((?:[^\\s()<>]|(?:\\([^\\s()<>]+\\)))*\\))+(?:\\((?:[^\\s()<>]|(?:\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:\'".,<>?\x{00ab}\x{00bb}\x{201c}\x{201d}\x{2018}\x{2019}]))/iu',
			$token->data,
			-1,
			\PREG_SPLIT_DELIM_CAPTURE,
		);

		$token = vec[];

		// $i = index
		// $c = count
		// $l = is link
		for ($i = 0, $c = C\count($bits), $l = false; $i < $c; $i++, $l = !$l) {
			if (!$l) {
				if ($bits[$i] === '') {
					continue;
				}
				$token[] = new Token\HTMLPurifier_Token_Text($bits[$i]);
			} else {
				$token[] = new Token\HTMLPurifier_Token_Start('a', dict['href' => $bits[$i]]);
				$token[] = new Token\HTMLPurifier_Token_Text($bits[$i]);
				$token[] = new Token\HTMLPurifier_Token_End('a');
			}
		}
		return $token;
	}

	<<__Override>>
	public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token): void {
	}

	<<__Override>>
	public function handleElement(HTMLPurifier\HTMLPurifier_Token $token): void {
	}
}
