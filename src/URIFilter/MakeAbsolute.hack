/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Definition;
use namespace Facebook\TypeAssert;
use namespace HH\Lib\{C, Str, Vec};

// does not support network paths

class HTMLPurifier_URIFilter_MakeAbsolute extends HTMLPurifier\HTMLPurifier_URIFilter {
	/**
	 * @type string
	 */
	public string $name = 'MakeAbsolute';

	/**
	 * @type HTMLPurifier\HTMLPurifier_URI
	 */
	protected HTMLPurifier\HTMLPurifier_URI $base;

	/**
	 * @type array
	 */
	protected vec<string> $basePathStack = vec[];

	public function __construct(): void {
		$this->base = new HTMLPurifier\HTMLPurifier_URI();
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool
	 */
	public function prepare(HTMLPurifier\HTMLPurifier_Config $config): bool {
		$def = TypeAssert\instance_of(Definition\HTMLPurifier_URIDefinition::class, $config->getURIDefinition());
		if ($def is null) {
			throw new \Error("URI is null in MakeAbsolute URI filter.");
		}
		if ($def->base is null) {
			throw new \Error(
				'URI.MakeAbsolute is being ignored due to lack of '.'value for URI.Base configuration',
				\E_USER_WARNING,
			);
		}
		$this->base = $def->base;
		$this->base->fragment = ''; // fragment is invalid for base URI
		$stack = Str\split($this->base->path, '/');
		$stack = Vec\take($stack, C\count($stack) - 1); // discard last segment
		$stack = $this->_collapseStack($stack); // do pre-parsing
		$this->basePathStack = $stack;
		return true;
	}

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function filter(
		inout HTMLPurifier\HTMLPurifier_URI $uri,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): bool {
		if ($this->base is null) {
			return true;
		} // abort early
		if (
			$uri->path === '' && $uri->scheme === '' && $uri->host === '' && $uri->query === '' && $uri->fragment === ''
		) {
			// reference to current document
			$uri = clone $this->base;
			return true;
		}
		if ($uri->scheme !== '') {
			// absolute URI already: don't change
			if ($uri->host !== '') {
				return true;
			}
			$scheme_obj = $uri->getSchemeObj($config, $context);
			if (!$scheme_obj) {
				// scheme not recognized
				return false;
			}
			if (!$scheme_obj->hierarchical) {
				// non-hierarchal URI with explicit scheme, don't change
				return true;
			}
			// special case: had a scheme but always is hierarchical and had no authority
		}
		if ($uri->host !== '') {
			// network path, don't bother
			return true;
		}
		if ($uri->path === '' && $this->base is nonnull) {
			$uri->path = $this->base->path;
		} else if ($uri->path[0] !== '/') {
			// relative path, needs more complicated processing
			$stack = Str\split($uri->path, '/');
			$new_stack = Vec\concat($this->basePathStack, $stack);
			if ($new_stack[0] !== '' && $this->base is nonnull && $this->base->host is nonnull) {
				\array_unshift(inout $new_stack, '');
			}
			$new_stack = $this->_collapseStack($new_stack);
			$uri->path = Str\join($new_stack, '/');
		} else {
			// absolute path, but still we should collapse
			$uri->path = Str\join($this->_collapseStack(Str\split($uri->path, '/')), '/');
		}
		// re-combine
		if ($this->base is nonnull) {
			$uri->scheme = $this->base->scheme;
			if ($uri->userinfo === '') {
				$uri->userinfo = $this->base->userinfo;
			}
			if ($uri->host === '') {
				$uri->host = $this->base->host;
			}
			if ($uri->port === 0) {
				$uri->port = $this->base->port;
			}
		}
		return true;
	}

	/**
	 * Resolve dots and double-dots in a path stack
	 * @param vec $stack
	 * @return vec
	 */
	private function _collapseStack(vec<string> $stack): vec<string> {
		$result = vec[];
		$is_folder = false;
		for ($i = 0; $i < C\count($stack); $i++) {
			$is_folder = false;
			// absorb an internally duplicated slash
			if ($stack[$i] == '' && $i && $i + 1 < C\count($stack)) {
				continue;
			}
			if ($stack[$i] == '..') {
				if (!C\is_empty($result)) {
					$segment = C\lastx($result);
					$result = Vec\take($result, C\count($result) - 1);
					if ($segment === '' && C\is_empty($result)) {
						// error case: attempted to back out too far:
						// restore the leading slash
						$result[] = '';
					} else if ($segment === '..') {
						$result[] = '..'; // cannot remove .. with ..
					}
				} else {
					// relative path, preserve the double-dots
					$result[] = '..';
				}
				$is_folder = true;
				continue;
			}
			if ($stack[$i] == '.') {
				// silently absorb
				$is_folder = true;
				continue;
			}
			$result[] = $stack[$i];
		}
		if ($is_folder) {
			$result[] = '';
		}
		return $result;
	}
}
