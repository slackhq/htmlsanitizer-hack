/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\{C, Dict, Str};
use namespace Facebook\TypeCoerce;

/**
* A UTF-8 specific character encoder that handles cleaning and transforming.
* @note All functions in this class should be static.
*/
class HTMLPurifier_Encoder {
	/** No bugs detected in iconv. */
	const int ICONV_OK = 0;

	/** Iconv truncates output if converting from UTF-8 to another
	 *  character set with //IGNORE, and a non-encodable character is found */
	const int ICONV_TRUNCATES = 1;

	/** Iconv does not support //IGNORE, making it unusable for
	 *  transcoding purposes */
	const int ICONV_UNUSABLE = 2;

	<<__Deprecated('Cannot instantiate encoder, call methods statically')>>
	final public function __construct() {}

	/**
	* Error-handler that mutes errors, alternative to shut-up operator
	* To be honest, I'm not sure when/if this is used
	*/
	public static function muteErrorHandler(): void {
	}

	/**
	* iconv wrapper which mutes errors, but doesn't work around bugs.
	*/
	public static function unsafeIconv(string $in, string $out, string $text): string {
		\set_error_handler(keyset['HTMLPurifier_Encoder', 'muteErrorHandler']);
		$ret = \iconv($in, $out, $text);
		\restore_error_handler();
		return $ret;
	}

	/**
	* iconv wrapper which mutes errors and works around bugs
	*/
	public static function iconv(string $in, string $out, string $text, int $max_chunk_size = 8000): ReturnShape {
		$code = self::testIconvTruncateBug();
		if ($code == self::ICONV_OK) {
			$unsafeIconv_ret = self::unsafeIconv($in, $out, $text);
			if ($unsafeIconv_ret) {
				return shape('val' => $unsafeIconv_ret, 'isValid' => true);
			} else {
				return shape('val' => '', 'isValid' => false);
			}
		} else if ($code == self::ICONV_TRUNCATES) {
			// We can only work around this if the input character set is utf-8
			if ($in == 'utf-8') {
				if ($max_chunk_size < 4) {
					\trigger_error('max_chunck_size is too small', \E_USER_WARNING);
					return shape('val' => '', 'isValid' => false);
				}
				$c = Str\length($text);
				// split into 8000 byte chunks, but be careful to handle multibyte boundaries properly
				if (($c <= $max_chunk_size)) {
					$unsafeIconv_ret = self::unsafeIconv($in, $out, $text);
					if ($unsafeIconv_ret) {
						return shape('val' => $unsafeIconv_ret, 'isValid' => true);
					} else {
						return shape('val' => '', 'isValid' => false);
					}
				}
				$ret = '';
				$i = 0;
				while (true) {
					if ($i + $max_chunk_size >= $c) {
						$ret .= self::unsafeIconv($in, $out, Str\slice($text, $i));
						break;
					}
					// wibble the boundary
					$chunk_size = $max_chunk_size;
					if (0x80 != (0xC0 & \ord($text[$i + $max_chunk_size]))) {
						$chunk_size = $max_chunk_size;
					} else if (0x80 != (0xC0 & \ord($text[$i + $max_chunk_size - 1]))) {
						$chunk_size = $max_chunk_size - 1;
					} else if (0x80 != (0xC0 & \ord($text[$i + $max_chunk_size - 2]))) {
						$chunk_size = $max_chunk_size - 2;
					} else if (0x80 != (0xC0 & \ord($text[$i + $max_chunk_size - 3]))) {
						$chunk_size = $max_chunk_size - 3;
					} else {
						return shape('val' => '', 'isValid' => false);
					}
					$chunk = Str\slice($text, $i, $chunk_size);
					$ret .= self::unsafeIconv($in, $out, $chunk);
					$i += $chunk_size;
				}
				if ($ret) {
					return shape('val' => $ret, 'isValid' => true);
				} else {
					return shape('val' => '', 'isValid' => false);
				}
			} else {
				return shape('val' => '', 'isValid' => false);
			}
		} else {
			return shape('val' => '', 'isValid' => false);
		}
	}

	public static function cleanUTF8(string $str): string {
		// UTF-8 validity is checked since PHP 4.3.5
		// This is an optimization: if the string is already valid UTF-8, no
		// need to do PHP stuff. 99% of the time, this will be the case.
		if (
			\preg_match(
				'/^[\x{9}\x{A}\x{D}\x{20}-\x{7E}\x{A0}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]*$/Du',
				$str,
			)
		) {
			return $str;
		}

		$mState = 0; // cached expected number of octets after the current octet
		// until the beginning of the next UTF8 character sequence
		$mUcs4 = 0; // cached Unicode character
		$mBytes = 1; // cached expected number of octets in the current sequence

		// original code involved an $out that was an array of Unicode
		// codepoints.  Instead of having to convert back into UTF-8, we've
		// decided to directly append valid UTF-8 characters onto a string
		// $out once they're done.  $char accumulates raw bytes, while $mUcs4
		// turns into the Unicode code point, so there's some redundancy.

		$out = '';
		$char = '';

		$len = Str\length($str);
		for ($i = 0; $i < $len; $i++) {
			$in = \ord($str[$i]);
			$char .= $str[$i]; // append byte to char
			if (0 == $mState) {
				// When mState is zero we expect either a US-ASCII character
				// or a multi-octet sequence.
				if (0 == (0x80 & ($in))) {
					// US-ASCII, pass straight through.
					if (
						($in <= 31 || $in == 127) && !($in == 9 || $in == 13 || $in == 10) // save \r\t\n
					) {
						// control characters, remove
					} else {
						$out .= $char;
					}
					// reset
					$char = '';
					$mBytes = 1;
				} else if (0xC0 == (0xE0 & ($in))) {
					// First octet of 2 octet sequence
					$mUcs4 = ($in);
					$mUcs4 = ($mUcs4 & 0x1F) << 6;
					$mState = 1;
					$mBytes = 2;
				} else if (0xE0 == (0xF0 & ($in))) {
					// First octet of 3 octet sequence
					$mUcs4 = ($in);
					$mUcs4 = ($mUcs4 & 0x0F) << 12;
					$mState = 2;
					$mBytes = 3;
				} else if (0xF0 == (0xF8 & ($in))) {
					// First octet of 4 octet sequence
					$mUcs4 = ($in);
					$mUcs4 = ($mUcs4 & 0x07) << 18;
					$mState = 3;
					$mBytes = 4;
				} else if (0xF8 == (0xFC & ($in))) {
					// First octet of 5 octet sequence.
					//
					// This is illegal because the encoded codepoint must be
					// either:
					// (a) not the shortest form or
					// (b) outside the Unicode range of 0-0x10FFFF.
					// Rather than trying to resynchronize, we will carry on
					// until the end of the sequence and let the later error
					// handling code catch it.
					$mUcs4 = ($in);
					$mUcs4 = ($mUcs4 & 0x03) << 24;
					$mState = 4;
					$mBytes = 5;
				} else if (0xFC == (0xFE & ($in))) {
					// First octet of 6 octet sequence, see comments for 5
					// octet sequence.
					$mUcs4 = ($in);
					$mUcs4 = ($mUcs4 & 1) << 30;
					$mState = 5;
					$mBytes = 6;
				} else {
					// Current octet is neither in the US-ASCII range nor a
					// legal first octet of a multi-octet sequence.
					$mState = 0;
					$mUcs4 = 0;
					$mBytes = 1;
					$char = '';
				}
			} else {
				// When mState is non-zero, we expect a continuation of the
				// multi-octet sequence
				if (0x80 == (0xC0 & ($in))) {
					// Legal continuation.
					$shift = ($mState - 1) * 6;
					$tmp = $in;
					$tmp = ($tmp & 0x0000003F) << $shift;
					$mUcs4 |= $tmp;
					--$mState;
					if (0 == $mState) {
						// End of the multi-octet sequence. mUcs4 now contains
						// the final Unicode codepoint to be output

						// Check for illegal sequences and codepoints.

						// From Unicode 3.1, non-shortest form is illegal
						if (
							((2 == $mBytes) && ($mUcs4 < 0x0080)) ||
							((3 == $mBytes) && ($mUcs4 < 0x0800)) ||
							((4 == $mBytes) && ($mUcs4 < 0x10000)) ||
							(4 < $mBytes) ||
							// From Unicode 3.2, surrogate characters = illegal
							(($mUcs4 & 0xFFFFF800) == 0xD800) ||
							// Codepoints outside the Unicode range are illegal
							($mUcs4 > 0x10FFFF)
						) {
							// do nothing
						} else if (
							0xFEFF != $mUcs4 && // omit BOM
							// check for valid Char unicode codepoints
							(
								0x9 == $mUcs4 ||
								0xA == $mUcs4 ||
								0xD == $mUcs4 ||
								(0x20 <= $mUcs4 && 0x7E >= $mUcs4) ||
								// 7F-9F is not strictly prohibited by XML,
								// but it is non-SGML, and thus we don't allow it
								(0xA0 <= $mUcs4 && 0xD7FF >= $mUcs4) ||
								(0xE000 <= $mUcs4 && 0xFFFD >= $mUcs4) ||
								(0x10000 <= $mUcs4 && 0x10FFFF >= $mUcs4)
							)
						) {
							$out .= $char;
						}
						// initialize UTF8 cache (reset)
						$mState = 0;
						$mUcs4 = 0;
						$mBytes = 1;
						$char = '';
					}
				} else {
					// ((0xC0 & (*in) != 0x80) && (mState != 0))
					// Incomplete multi-octet sequence.
					// used to result in complete fail, but we'll reset
					$mState = 0;
					$mUcs4 = 0;
					$mBytes = 1;
					$char = '';
				}
			}
		}
		return $out;
	}

	/**
	* Translates a Unicode codepoint into its corresponding UTF-8 character.
	* @note Based on Feyd's function at
	*       <http://forums.devnetwork.net/viewtopic.php?p=191404#191404>,
	*       which is in public domain.
	* @note While we're going to do code point parsing anyway, a good
	*       optimization would be to refuse to translate code points that
	*       are non-SGML characters.  However, this could lead to duplication.
	* @note This is very similar to the unichr function in
	*       maintenance/generate-entity-file.php (although this is superior,
	*       due to its sanity checks).
	*/

	// +----------+----------+----------+----------+
	// | 33222222 | 22221111 | 111111   |          |
	// | 10987654 | 32109876 | 54321098 | 76543210 | bit
	// +----------+----------+----------+----------+
	// |          |          |          | 0xxxxxxx | 1 byte 0x00000000..0x0000007F
	// |          |          | 110yyyyy | 10xxxxxx | 2 byte 0x00000080..0x000007FF
	// |          | 1110zzzz | 10yyyyyy | 10xxxxxx | 3 byte 0x00000800..0x0000FFFF
	// | 11110www | 10wwzzzz | 10yyyyyy | 10xxxxxx | 4 byte 0x00010000..0x0010FFFF
	// +----------+----------+----------+----------+
	// | 00000000 | 00011111 | 11111111 | 11111111 | Theoretical upper limit of legal scalars: 2097151 (0x001FFFFF)
	// | 00000000 | 00010000 | 11111111 | 11111111 | Defined upper limit of legal scalar codes
	// +----------+----------+----------+----------+
	//
	// @ NOTE FROM JAKE: I'M UNCERTAIN IF THE CHR() FUNCTION IS WORKING IN THE SAME
	// MANNER. I COULDN'T FIND DOCUMENTATION ON IT, SO WE WILL NEED TO RUN TESTS
	// EXTENSIVLEY HERE TO ENSURE THAT IT WORKS PROPERLY
	public static function unichr(int $code): string {
		if ($code > 1114111 || $code < 0 || ($code >= 55296 && $code <= 57343)) {
			// bits are set outside the "valid" range defined by UNICODE 4.1.0
			return '';
		}

		$x = 0;
		$y = 0;
		$z = 0;
		$w = 0;

		if ($code < 128) {
			// regular ASCII character
			$x = $code;
		} else {
			// set up bits for UTF-8
			$x = ($code & 63) | 128;
			if ($code < 2048) {
				$y = (($code & 2047) >> 6) | 192;
			} else {
				$y = (($code & 4032) >> 6) | 128;
				if ($code < 65536) {
					$z = (($code >> 12) & 15) | 224;
				} else {
					$z = (($code >> 12) & 63) | 128;
					$w = (($code >> 18) & 7) | 240;
				}
			}
		}
		// set up the actual character
		$ret = '';
		if ($w) {
			$ret .= \chr($w);
		}
		if ($z) {
			$ret .= \chr($z);
		}
		if ($y) {
			$ret .= \chr($y);
		}
		$ret .= \chr($x);

		return $ret;
	}

	public static function iconvAvailable(): bool {
		// statics are not permitted in Hack. Making a class with a single static is the work around
		// I beleive this to be what Scott was referring to in #help-hacklang
		if (StaticIconv::$iconv_bool is null) {
			StaticIconv::$iconv_bool = \function_exists('iconv') &&
				self::testIconvTruncateBug() != self::ICONV_UNUSABLE;
		}
		return StaticIconv::$iconv_bool;
	}

	/**
	* Convert a string to UTF-8 based on configuration
	*/
	public static function convertToUTF8(
		string $str,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): string {
		$encoding = $config->def->defaults['Core.Encoding'];
		if ($encoding === 'utf-8') {
			return $str;
		}
		if (StaticIconv::$iconv_bool is null) {
			StaticIconv::$iconv_bool = self::iconvAvailable();
		}
		if (StaticIconv::$iconv_bool && !$config->def->defaults['Test.ForceNoIconv']) {
			// unaffected by bugs, since UTF-8 support all characters
			$str = self::unsafeIconv($encoding, 'utf-8//IGNORE', $str);
			if ($str === '') {
				// $encoding is not a valid encoding
				throw new \Exception('Invalid encoding '.$encoding, \E_USER_ERROR);
			}
			// If the string is bjorked by Shift_JIS or a similar encoding
			// that doesn't support all of ASCII, convert the naughty
			// characters to their true byte-wise ASCII/UTF-8 equivalents.
			$str = Str\replace_every($str, self::testEncodingSupportsASCII($encoding));
			return $str;
		} else if ($encoding === 'iso-8859-1') {
			$str = \utf8_encode($str);
			return $str;
		}
		if (HTMLPurifier_Encoder::testIconvTruncateBug() == self::ICONV_OK) {
			throw new \Exception('Encoding not supported, please install iconv', \E_USER_ERROR);
		} else {
			throw new \Exception(
				'You have a buggy version of iconv, see https://bugs.php.net/bug.php?id=48147 '.
				'and http://sourceware.org/bugzilla/show_bug.cgi?id=13541',
				\E_USER_ERROR,
			);
		}
	}

	/**
	* Converts a string from UTF-8 based on configuration.
	* @note Currently, this is a lossy conversion, with unexpressable
	*       characters being omitted.
	*/
	public static function convertFromUTF8(
		string $str,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): string {
		$encoding = $config->def->defaults['Core.Encoding'];
		$escape = $config->def->defaults['Core.EscapeNonASCIICharacters'];
		if ($escape) {
			$str = self::convertToASCIIDumbLossless($str);
		}
		if ($encoding === 'utf-8') {
			return $str;
		}
		if (StaticIconv::$iconv_bool is null) {
			StaticIconv::$iconv_bool = self::iconvAvailable();
		}
		if (StaticIconv::$iconv_bool && !$config->def->defaults['Test.ForceNoIconv']) {
			// Undo our previous fix in convertToUTF8, otherwise iconv will barf
			$ascii_fix = self::testEncodingSupportsASCII($encoding);
			if (!$escape && C\count($ascii_fix)) {
				$clear_fix = dict[];
				foreach ($ascii_fix as $utf8 => $native) {
					$clear_fix[$utf8] = '';
				}
				$str = Str\replace_every($str, $clear_fix);
			}
			$str = Str\replace_every($str, Dict\flip($ascii_fix));
			// Normal stuff
			$str_shape = self::iconv('utf-8', $encoding.'//IGNORE', $str);
			if ($str_shape['isValid']) {
				return $str_shape['val'];
			}
		} else if ($encoding === 'iso-8859-1') {
			$str = \utf8_decode($str);
			return $str;
		}
		throw new \Exception('Encoding not supported', \E_USER_ERROR);
		// You might be tempted to assume that the ASCII representation
		// might be OK, however, this is *not* universally true over all
		// encodings.  So we take the conservative route here, rather
		// than forcibly turn on %Core.EscapeNonASCIICharacters
	}

	/**
	* Lossless (character-wise) conversion of HTML to ASCII
	* @warning Adapted from MediaWiki, claiming fair use: this is a common
	*       algorithm. If you disagree with this license fudgery,
	*       implement it yourself.
	* @note Uses decimal numeric entities since they are best supported.
	* @note This is a DUMB function: it has no concept of keeping
	*       character entities that the projected character encoding
	*       can allow. We could possibly implement a smart version
	*       but that would require it to also know which Unicode
	*       codepoints the charset supported (not an easy task).
	* @note Sort of with cleanUTF8() but it assumes that $str is
	*       well-formed UTF-8
	*/
	public static function convertToASCIIDumbLossless(string $str): string {
		$bytesleft = 0;
		$result = '';
		$working = 0;
		$len = Str\length($str);
		for ($i = 0; $i < $len; $i++) {
			$bytevalue = \ord($str[$i]);
			if ($bytevalue <= 0x7F) { //0xxx xxxx
				$result .= \chr($bytevalue);
				$bytesleft = 0;
			} else if ($bytevalue <= 0xBF) { //10xx xxxx
				$working = $working << 6;
				$working += ($bytevalue & 0x3F);
				$bytesleft--;
				if ($bytesleft <= 0) {
					$result .= "&#".$working.";";
				}
			} else if ($bytevalue <= 0xDF) { //110x xxxx
				$working = $bytevalue & 0x1F;
				$bytesleft = 1;
			} else if ($bytevalue <= 0xEF) { //1110 xxxx
				$working = $bytevalue & 0x0F;
				$bytesleft = 2;
			} else { //1111 0xxx
				$working = $bytevalue & 0x07;
				$bytesleft = 3;
			}
		}
		return $result;
	}

	/**
	 * glibc iconv has a known bug where it doesn't handle the magic
	 * //IGNORE stanza correctly.  In particular, rather than ignore
	 * characters, it will return an EILSEQ after consuming some number
	 * of characters, and expect you to restart iconv as if it were
	 * an E2BIG.  Old versions of PHP did not respect the errno, and
	 * returned the fragment, so as a result you would see iconv
	 * mysteriously truncating output. We can work around this by
	 * manually chopping our input into segments of about 8000
	 * characters, as long as PHP ignores the error code.  If PHP starts
	 * paying attention to the error code, iconv becomes unusable.
	 */
	public static function testIconvTruncateBug(): int {
		if (StaticCode::$code is null) {
			// better not use iconv, otherwise infinite loop!
			$unsafe_iconv = self::unsafeIconv('utf-8', 'ascii//IGNORE', "\xCE\xB1".Str\repeat('a', 9000));
			$count = Str\length($unsafe_iconv);
			if ($unsafe_iconv === '') {
				StaticCode::$code = self::ICONV_UNUSABLE;
			} else if ($count < 9000) {
				StaticCode::$code = self::ICONV_TRUNCATES;
			} else if ($count > 9000) {
				\trigger_error(
					'Your copy of iconv is extremely buggy. Please notify HTML Purifier maintainers: '.
					'include your iconv version as per phpversion()',
					\E_USER_ERROR,
				);
			} else {
				StaticCode::$code = self::ICONV_OK;
			}
		}
		return TypeCoerce\int(StaticCode::$code);
	}

	/**
	 * This expensive function tests whether or not a given character
	 * encoding supports ASCII. 7/8-bit encodings like Shift_JIS will
	 * fail this test, and require special processing. Variable width
	 * encodings shouldn't ever fail.
	 *
	 * @param string $encoding Encoding name to test, as per iconv format
	 * @param bool $bypass Whether or not to bypass the precompiled arrays.
	 * @return Array of UTF-8 characters to their corresponding ASCII,
	 *      which can be used to "undo" any overzealous iconv action.
	 */
	public static function testEncodingSupportsASCII(string $encoding, bool $bypass = false): dict<string, string> {
		// All calls to iconv here are unsafe, proof by case analysis:
		// If ICONV_OK, no difference.
		// If ICONV_TRUNCATE, all calls involve one character inputs,
		// so bug is not triggered.
		// If ICONV_UNUSABLE, this call is irrelevant

		if (!$bypass) {
			if (isset(StaticEncodings::$encodings[$encoding])) {
				return StaticEncodings::$encodings[$encoding];
			}
			$lower_cas_encoding = Str\lowercase($encoding);
			switch ($lower_cas_encoding) {
				case 'shift_jis':
					return dict["\xC2\xA5" => '\\', "\xE2\x80\xBE" => '~'];
				case 'johab':
					return dict["\xE2\x82\xA9" => '\\'];
			}
			if (Str\search($lower_cas_encoding, 'iso-8859-') === 0) {
				return dict[];
			}
		}
		$ret = dict[];
		if (self::unsafeIconv('UTF-8', $encoding, 'a') === '') {
			// this is the case where we have an unusable iconv, might as well trigger error?
			\trigger_error('The encoding leads to an unsafe iconv', \E_USER_WARNING);
			return dict[]; // I need to return something - in the PHP false is return
		}
		for ($i = 0x20; $i <= 0x7E; $i++) { // all printable ASCII chars
			$c = \chr($i); // UTF-8 char
			$r = self::unsafeIconv('UTF-8', "$encoding//IGNORE", $c); // initial conversion
			if (
				$r === '' ||
				// This line is needed for iconv implementations that do not
				// omit characters that do not exist in the target character set
				($r === $c && self::unsafeIconv($encoding, 'UTF-8//IGNORE', $r) !== $c)
			) {
				// Reverse engineer: what's the UTF-8 equiv of this byte
				// sequence? This assumes that there's no variable width
				// encoding that doesn't support ASCII.
				$ret[self::unsafeIconv($encoding, 'UTF-8//IGNORE', $c)] = $c;
			}
		}
		StaticEncodings::$encodings[$encoding] = $ret;
		return $ret;
	}
}

abstract final class StaticIconv {
	public static ?bool $iconv_bool = null;
}

abstract final class StaticCode {
	public static ?int $code = null;
}

abstract final class StaticEncodings {
	public static dict<string, dict<string, string>> $encodings = dict[];
}

type ReturnShape = shape('val' => string, 'isValid' => bool);
