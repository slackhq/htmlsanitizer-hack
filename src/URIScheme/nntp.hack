/* Created by Jacob Polacek on 07/22/2020 */

namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;

/**
 * Validates nntp (Network News Transfer Protocol) as defined by generic RFC 1738
 */
class HTMLPurifier_URIScheme_nntp extends HTMLPurifier\HTMLPurifier_URIScheme {
	/**
	 * @type int
	 */
	public int $default_port = 119;

	/**
	 * @type bool
	 */
	public bool $browsable = false;

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
		$uri->query = '';
		return true;
	}
}
