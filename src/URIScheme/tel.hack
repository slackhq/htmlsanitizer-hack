/* Created by Jacob Polacek on 07/22/2020 */

namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates tel (for phone numbers).
 *
 * The relevant specifications for this protocol are RFC 3966 and RFC 5341,
 * but this class takes a much simpler approach: we normalize phone
 * numbers so that they only include (possibly) a leading plus,
 * and then any number of digits and x'es.
 */

class HTMLPurifier_URIScheme_tel extends HTMLPurifier\HTMLPurifier_URIScheme {
	/**
	 * @type bool
	 */
	public bool $browsable = false;

	/**
	 * @type bool
	 */
	public bool $may_omit_host = true;

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function doValidate(
		inout HTMLPurifier\HTMLPurifier_URI $uri,
		HTMLPurifier\HTMLPurifier_Config $_config,
		HTMLPurifier\HTMLPurifier_Context $_context,
	): bool {
		$uri->userinfo = '';
		$uri->host = '';
		$uri->port = 0;

		// Delete all non-numeric characters, non-x characters
		// from phone number, EXCEPT for a leading plus sign.
		$uri->path = \preg_replace(
			'/(?!^\+)[^\dx]/',
			'',
			// Normalize e(x)tension to lower-case
			Str\replace($uri->path, 'X', 'x'),
		);

		return true;
	}
}
