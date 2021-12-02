/* Created by Jacob Polacek on 06/29/2020 */

namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validator for the components of a URI for a specific scheme
 */
abstract class HTMLPurifier_URIScheme {

	/**
	 * Scheme's default port (integer). If an explicit port number is
	 * specified that coincides with the default port, it will be
	 * elided.
	 */
	public int $default_port = 0;

	/**
	 * Whether or not URIs of this scheme are locatable by a browser
	 * http and ftp are accessible, while mailto and news are not.
	 */
	public bool $browsable = false;

	/**
	 * Whether or not data transmitted over this scheme is encrypted.
	 * https is secure, http is not.
	 */
	public bool $secure = false;

	/**
	 * Whether or not the URI always uses <hier_part>, resolves edge cases
	 * with making relative URIs absolute
	 */
	public bool $hierarchical = false;

	/**
	 * Whether or not the URI may omit a hostname when the scheme is
	 * explicitly specified, ala file:///path/to/file. As of writing,
	 * 'file' is the only scheme that browsers support his properly.
	 */
	public bool $may_omit_host = false;

	/**
	 * Validates the components of a URI for a specific scheme.
	 */
	abstract public function doValidate(
		inout HTMLPurifier_URI $uri,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): bool;

	/**
	 * Public interface for validating components of a URI.  Performs a
	 * bunch of default actions. Don't overload this method.
	 */
	public function validate(HTMLPurifier_URI $uri, HTMLPurifier_Config $config, HTMLPurifier_Context $context): bool {
		if ($this->default_port === $uri->port) {
			$uri->port = 0;
		}
		// kludge: browsers do funny things when the scheme but not the
		// authority is set
		if (
			!$this->may_omit_host &&
				// if the scheme is present, a missing host is always in error
				($uri->scheme is nonnull && ($uri->host === '' || $uri->host is null)) ||
			// if the scheme is not present, a *blank* host is in error,
			// since this translates into '///path' which most browsers
			// interpret as being 'http://path'.
			($uri->scheme is null && $uri->host === '')
		) {
			do {
				if ($uri->scheme is null) {
					if ($uri->path is nonnull && Str\slice($uri->path, 0, 2) !== '//') {
						$uri->host = '';
						break;
					}
					// URI is '////path', so we cannot nullify the
					// host to preserve semantics.  Try expanding the
					// hostname instead (fall through)
				}
				// first see if we can manually insert a hostname
				$host = $config->def->defaults['URI.Host'];
				if ($host is nonnull && $host is string) {
					$uri->host = $host;
				} else {
					// we can't do anything sensible, reject the URL.
					return false;
				}
			} while (false);
		}
		return $this->doValidate(inout $uri, $config, $context);
	}
}
