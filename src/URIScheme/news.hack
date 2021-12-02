/* Created by Jacob Polacek on 07/22/2020 */

namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;

/**
 * Validates news (Usenet) as defined by generic RFC 1738
 */
class HTMLPurifier_URIScheme_news extends HTMLPurifier\HTMLPurifier_URIScheme {
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
		$uri->query = '';
		// typecode check needed on path
		return true;
	}
}
