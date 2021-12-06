/* Created by Jacob Polacek on 06/29/2020 */

namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef\URI;
use namespace HH\Lib\Str;
use namespace Facebook\TypeAssert;

/**
 * HTML Purifier's internal representation of a URI.
 * @note
 *      Internal data-structures are completely escaped. If the data needs
 *      to be used in a non-URI context (which is very unlikely), be sure
 *      to decode it first. The URI may not necessarily be well-formed until
 *      validate() is called.
 */
class HTMLPurifier_URI {
	public string $scheme;

	public string $userinfo;

	public string $host;

	public int $port;

	public string $path;

	public string $query;

	public string $fragment;

	/**
	 * @param string $scheme
	 * @param string $userinfo
	 * @param string $host
	 * @param int $port
	 * @param string $path
	 * @param string $query
	 * @param string $fragment
	 * @note Automatically normalizes scheme and port
	 */
	public function __construct(
		string $scheme = '',
		string $userinfo = '',
		string $host = '',
		int $port = 0,
		string $path = '',
		string $query = '',
		string $fragment = '',
	): void {
		$this->scheme = ($scheme is null) ? $scheme : Str\lowercase($scheme);
		$this->userinfo = $userinfo;
		$this->host = $host;
		$this->port = $port;
		$this->path = $path;
		$this->query = $query;
		$this->fragment = $fragment;
	}

	/**
	 * Retrieves a scheme object corresponding to the URI's scheme/default
	 */
	public function getSchemeObj(HTMLPurifier_Config $config, HTMLPurifier_Context $context): ?HTMLPurifier_URIScheme {
		$registry = HTMLPurifier_URISchemeRegistry::instance();
		if ($this->scheme !== '') {
			$scheme_obj = $registry->getScheme($this->scheme, $config, $context);
			if (!$scheme_obj) {
				return null;
			} // invalid scheme, clean it out
		} else {
			// no scheme: retrieve the default one
			$def = $config->getURIDefinition();
			$scheme_obj = $def->getDefaultScheme($config, $context);
			if (!$scheme_obj) {
				if ($def is nonnull && $def->defaultScheme is nonnull) {
					// something funky happened to the default scheme object
					throw new \Error(
						'Default scheme object "'.$def->defaultScheme.'" was not readable',
						\E_USER_WARNING,
					);
				} // suppress error if it's null
				return null;
			}
		}
		return $scheme_obj;
	}

	/**
	 * Generic validation method applicable for all schemes. May modify
	 * this URI in order to get it into a compliant form.
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool True if validation/filtering succeeds, false if failure
	 */
	public function validate(HTMLPurifier_Config $config, HTMLPurifier_Context $context): bool {
		// ABNF definitions from RFC 3986
		$chars_sub_delims = '!$&\'()*+,;=';
		$chars_gen_delims = ':/?#[]@';
		$chars_pchar = $chars_sub_delims.':@';

		// validate host
		if ($this->host !== '') {
			$host_def = new URI\HTMLPurifier_AttrDef_URI_Host();
			$this->host = $host_def->validate($this->host, $config, $context);
		}

		// validate scheme
		// NOTE: It's not appropriate to check whether or not this
		// scheme is in our registry, since a URIFilter may convert a
		// URI that we don't allow into one we do.  So instead, we just
		// check if the scheme can be dropped because there is no host
		// and it is our default scheme.
		if ($this->scheme !== '' && $this->host === '') {
			// support for relative paths is pretty abysmal when the
			// scheme is present, so axe it when possible
			$def = $config->getURIDefinition();
			if ($def->defaultScheme === $this->scheme) {
				$this->scheme = '';
			}
		}

		// validate username
		if ($this->userinfo !== '') {
			$encoder = new HTMLPurifier_PercentEncoder($chars_sub_delims.':');
			$this->userinfo = $encoder->encode($this->userinfo);
		}

		// validate port
		if ($this->port !== 0) {
			if ($this->port < 1 || $this->port > 65535) {
				$this->port = 0;
			}
		}

		// validate path
		$segments_encoder = new HTMLPurifier_PercentEncoder($chars_pchar.'/');
		if ($this->host && $this->path is nonnull) { // this catches $this->host === ''
			// path-abempty (hier and relative)
			// http://www.example.com/my/path
			// //www.example.com/my/path (looks odd, but works, and
			//                            recognized by most browsers)
			// (this set is valid or invalid on a scheme by scheme
			// basis, so we'll deal with it later)
			// file:///my/path
			// ///my/path
			$this->path = $segments_encoder->encode($this->path);
		} elseif ($this->path is nonnull && $this->path !== '') {
			if ($this->path[0] === '/' && $this->path is nonnull) {
				// path-absolute (hier and relative)
				// http:/my/path
				// /my/path
				if (Str\length($this->path) >= 2 && $this->path is nonnull && $this->path[1] === '/') {
					// This could happen if both the host gets stripped
					// out
					// http://my/path
					// //my/path
					$this->path = '';
				} else {
					if ($this->path is nonnull) $this->path = $segments_encoder->encode($this->path);
				}
			} elseif ($this->scheme != '') {
				// path-rootless (hier)
				// http:my/path
				// Short circuit evaluation means we don't need to check nz
				$this->path = $segments_encoder->encode($this->path);
			} else {
				// path-noscheme (relative)
				// my/path
				// (once again, not checking nz)
				$segment_nc_encoder = new HTMLPurifier_PercentEncoder($chars_sub_delims.'@');
				$c = $this->path is nonnull ? Str\search($this->path, '/') : null;
				if ($c is nonnull && $this->path is nonnull) {
					$seg_nc_encode = $segment_nc_encoder->encode(Str\slice($this->path, 0, $c));
					$seg_encode = $this->path is nonnull ? $segments_encoder->encode(Str\slice($this->path, $c)) : null;
					$this->path = $seg_nc_encode.(string)$seg_encode;
				} else {
					if ($this->path is nonnull) $this->path = $segment_nc_encoder->encode($this->path);
				}
			}
		} else {
			// path-empty (hier and relative)
			$this->path = ''; // just to be safe
		}

		// qf = query and fragment
		$qf_encoder = new HTMLPurifier_PercentEncoder($chars_pchar.'/?');

		if ($this->query is nonnull) {
			$this->query = $qf_encoder->encode($this->query);
		}

		if ($this->fragment is nonnull) {
			$this->fragment = $qf_encoder->encode($this->fragment);
		}
		return true;
	}

	/**
	 * Convert URI back to string
	 * @return string URI appropriate for output
	 */
	public function toString(): string {
		// reconstruct authority
		$authority = null;
		// there is a rendering difference between a null authority
		// (http:foo-bar) and an empty string authority
		// (http:///foo-bar).
		if ($this->host is nonnull) {
			$authority = '';
			if ($this->userinfo !== '') {
				$authority .= $this->userinfo.'@';
			}
			$authority .= $this->host;
			if ($this->port !== 0) {
				$authority .= ':'.$this->port;
			}
		}

		// Reconstruct the result
		// One might wonder about parsing quirks from browsers after
		// this reconstruction.  Unfortunately, parsing behavior depends
		// on what *scheme* was employed (file:///foo is handled *very*
		// differently than http:///foo), so unfortunately we have to
		// defer to the schemes to do the right thing.
		$result = '';
		if ($this->scheme !== '') {
			$result .= $this->scheme.':';
		}
		if ($authority !== '') {
			$result .= '//'.(string)$authority;
		}
		$result .= $this->path;
		if ($this->query !== '') {
			$result .= '?'.$this->query;
		}
		if ($this->fragment !== '') {
			$result .= '#'.$this->fragment;
		}

		return $result;
	}

	/**
	 * Returns true if this URL might be considered a 'local' URL given
	 * the current context.  This is true when the host is null, or
	 * when it matches the host supplied to the configuration.
	 *
	 * Note that this does not do any scheme checking, so it is mostly
	 * only appropriate for metadata that doesn't care about protocol
	 * security.  isBenign is probably what you actually want.
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function isLocal(HTMLPurifier_Config $config, HTMLPurifier_Context $_context): bool {
		if ($this->host is null) {
			return true;
		}
		$uri_def = TypeAssert\instance_of(Definition\HTMLPurifier_URIDefinition::class, $config->getURIDefinition());
		if ($uri_def is nonnull && $uri_def->host === $this->host) {
			return true;
		}
		return false;
	}

	/**
	 * Returns true if this URL should be considered a 'benign' URL,
	 * that is:
	 *
	 *      - It is a local URL (isLocal), and
	 *      - It has a equal or better level of security
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function isBenign(HTMLPurifier_Config $config, HTMLPurifier_Context $context): bool {
		if (!$this->isLocal($config, $context)) {
			return false;
		}

		$scheme_obj = $this->getSchemeObj($config, $context);
		if (!$scheme_obj) {
			return false;
		} // conservative approach

		$def = TypeAssert\instance_of(Definition\HTMLPurifier_URIDefinition::class, $config->getURIDefinition());
		if ($def is null) {
			throw new \Error("URIDef is null in isBenign");
		}
		$current_scheme_obj = $def->getDefaultScheme($config, $context);
		if ($current_scheme_obj->secure) {
			if (!$scheme_obj->secure) {
				return false;
			}
		}
		return true;
	}
}
