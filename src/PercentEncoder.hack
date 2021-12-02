/* Created by Jacob Polacek on 06/29/2020 */

namespace HTMLPurifier;
use namespace HH\Lib\{C, Str, Vec};

/**
 * Class that handles operations involving percent-encoding in URIs.
 *
 * @warning
 *      Be careful when reusing instances of PercentEncoder. The object
 *      you use for normalize() SHOULD NOT be used for encode(), or
 *      vice-versa.
 */
class HTMLPurifier_PercentEncoder {

	/**
	 * Reserved characters to preserve when using encode().
	 */
	protected keyset<int> $preserve = keyset[];

	/**
	 * String of characters that should be preserved while using encode().
	 * @param bool $preserve
	 */
	public function __construct(string $preserve = ''): void {
		// unreserved letters, ought to const-ify
		for ($i = 48; $i <= 57; $i++) { // digits
			$this->preserve[] = $i;
		}
		for ($i = 65; $i <= 90; $i++) { // upper-case
			$this->preserve[] = $i;
		}
		for ($i = 97; $i <= 122; $i++) { // lower-case
			$this->preserve[] = $i;
		}
		$this->preserve[] = 45; // Dash         -
		$this->preserve[] = 46; // Period       .
		$this->preserve[] = 95; // Underscore   _
		$this->preserve[] = 126; // Tilde        ~

		// extra letters not to escape

		if ($preserve !== '') {
			$c = Str\length($preserve);
			for ($i = 0; $i < $c; $i++) {
				$this->preserve[] = \ord($preserve[$i]);
			}
		}
	}

	/**
	 * Our replacement for urlencode, it encodes all non-reserved characters,
	 * as well as any extra characters that were instructed to be preserved.
	 * @note
	 *      Assumes that the string has already been normalized, making any
	 *      and all percent escape sequences valid. Percents will not be
	 *      re-escaped, regardless of their status in $preserve
	 * @param string $string String to be encoded
	 * @return string Encoded string.
	 */
	public function encode(string $string): string {
		$ret = '';
		for ($i = 0, $c = Str\length($string); $i < $c; $i++) {
			$int = \ord($string[$i]);
			if ($string[$i] !== '%' && !isset($this->preserve[$int])) {
				$ret .= '%'.\sprintf('%02X', $int);
			} else {
				$ret .= $string[$i];
			}
		}
		return $ret;
	}

	/**
	 * Fix up percent-encoding by decoding unreserved characters and normalizing.
	 * @warning This function is affected by $preserve, even though the
	 *          usual desired behavior is for this not to preserve those
	 *          characters. Be careful when reusing instances of PercentEncoder!
	 * @param string $string String to normalize
	 * @return string
	 */
	public function normalize(string $string): string {
		if ($string === '') {
			return '';
		}
		// These next three lines replace $parts = explode('%', $string); $ret = array_shift($parts);
		$parts = Str\split($string, '%');
		$ret = C\firstx($parts);
		$parts = Vec\drop($parts, 1);

		foreach ($parts as $part) {
			$length = Str\length($part);
			if ($length < 2) {
				$ret .= '%25'.$part;
				continue;
			}
			$encoding = Str\slice($part, 0, 2);
			$text = Str\slice($part, 2);
			if (!\ctype_xdigit($encoding)) {
				$ret .= '%25'.$part;
				continue;
			}
			$int = \hexdec($encoding);
			if (isset($this->preserve[$int])) {
				$ret .= \chr($int).$text;
				continue;
			}
			$encoding = Str\uppercase($encoding);
			$ret .= '%'.$encoding.$text;
		}
		return $ret;
	}
}
