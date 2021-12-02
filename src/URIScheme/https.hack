// created by Nikita Ashok on 07/21/20;
namespace HTMLPurifier\URIScheme;
/**
 * Validates https (Secure HTTP) according to http scheme.
 */
class HTMLPurifier_URIScheme_https extends HTMLPurifier_URIScheme_http {
	/**
	 * @type int
	 */
	public int $default_port = 443;
	/**
	 * @type bool
	 */
	public bool $secure = true;
}
