/* Created by Jacob Polacek on 06/29/2020 */

namespace HTMLPurifier;
use namespace HH\Lib\C;

/**
 * Parses a URI into the components and fragment identifier as specified
 * by RFC 3986.
 */
class HTMLPurifier_URIParser {

	/**
	 * Instance of HTMLPurifier_PercentEncoder to do normalization with.
	 */
	protected HTMLPurifier_PercentEncoder $percentEncoder;

	public function __construct() {
		$this->percentEncoder = new HTMLPurifier_PercentEncoder();
	}

	/**
	 * Parses a URI.
	 * @param $uri string URI to parse
	 * @return HTMLPurifier_URI representation of URI. This representation has
	 *         not been validated yet and may not conform to RFC.
	 */
	public function parse(string $uri): HTMLPurifier_URI {
		$uri = $this->percentEncoder->normalize($uri);

		// Regexp is as per Appendix B.
		// Note that ["<>] are an addition to the RFC's recommended
		// characters, because they represent external delimeters.
		$r_URI = '!'.
			'(([a-zA-Z0-9\.\+\-]+):)?'. // 2. Scheme
			'(//([^/?#"<>]*))?'. // 4. Authority
			'([^?#"<>]*)'. // 5. Path
			'(\?([^#"<>]*))?'. // 7. Query
			'(#([^"<>]*))?'. // 8. Fragment
			'!';

		$matches = vec[];
		$result = \preg_match_with_matches($r_URI, $uri, inout $matches);

		if (!$result) throw new \Exception("REALLY invalid URI\n"); // *really* invalid URI

		// seperate out parts
		$scheme = (1 < C\count($matches)) ? $matches[2] : '';
		$authority = (3 < C\count($matches)) ? $matches[4] : null;
		$path = $matches[5]; // always present, can be empty
		$query = (6 < C\count($matches)) ? $matches[7] : '';
		$fragment = (8 < C\count($matches)) ? $matches[9] : '';

		// further parse authority
		if ($authority is nonnull) {
			$r_authority = "/^((.+?)@)?(\[[^\]]+\]|[^:]*)(:(\d*))?/";
			$matches = vec[];
			\preg_match_with_matches($r_authority, $authority, inout $matches);
			$userinfo = (1 < C\count($matches)) ? $matches[2] : '';
			$host = (3 < C\count($matches)) ? $matches[3] : '';
			$port = (4 < C\count($matches)) ? (int)$matches[5] : 0;
		} else {
			$port = 0;
			$host = '';
			$userinfo = '';
		}

		return new HTMLPurifier_URI($scheme, $userinfo, $host, $port, $path, $query, $fragment);
	}

}
