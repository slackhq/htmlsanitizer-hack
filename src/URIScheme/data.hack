/* Created by Jacob Polacek on 07/22/2020 */

namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

/**
 * Implements data: URI for base64 encoded images supported by GD.
 */
class HTMLPurifier_URIScheme_data extends HTMLPurifier\HTMLPurifier_URIScheme {
	/**
	 * @type bool
	 */
	public bool $browsable = true;

	/**
	 * @type array
	 */
	public dict<string, bool> $allowed_types = dict[
		// you better write validation code for other types if you
		// decide to allow them
		'image/jpeg' => true,
		'image/gif' => true,
		'image/png' => true,
	];

	// this is actually irrelevant since we only write out the path
	// component
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
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): bool {
		$result = Str\split($uri->path, ',', 2);
		$is_base64 = false;
		$charset = null;
		$content_type = null;
		if (C\count($result) == 2) {
			list($metadata, $data) = $result;
			// do some legwork on the metadata
			$metas = Str\split($metadata, ';');
			while (!C\is_empty($metas)) {
				$cur = \array_shift(inout $metas);
				if ($cur == 'base64') {
					$is_base64 = true;
					break;
				}
				if (Str\slice($cur, 0, 8) == 'charset=') {
					// doesn't match if there are arbitrary spaces, but
					// whatever dude
					if ($charset is nonnull) {
						continue;
					} // garbage
					$charset = Str\slice($cur, 8); // not used
				} else {
					if ($content_type is nonnull) {
						continue;
					} // garbage
					$content_type = $cur;
				}
			}
		} else {
			$data = $result[0];
		}
		if ($content_type is nonnull && !C\contains_key($this->allowed_types, $content_type)) {
			return false;
		}
		if ($charset is nonnull) {
			// error; we don't allow plaintext stuff
			$charset = null;
		}
		$data = \rawurldecode($data);
		if ($is_base64) {
			$raw_data = \base64_decode($data);
		} else {
			$raw_data = $data;
		}
		if (Str\length($raw_data) < 12) {
			// error; exif_imagetype throws exception with small files,
			// and this likely indicates a corrupt URI/failed parse anyway
			return false;
		}
		// XXX probably want to refactor this into a general mechanism
		// for filtering arbitrary content types
		if (\function_exists('sys_get_temp_dir')) {
			$file = \tempnam(\sys_get_temp_dir(), "");
		} else {
			$file = \tempnam("/tmp", "");
		}
		\file_put_contents($file, $raw_data);
		if (\function_exists('exif_imagetype')) {
			$image_code = \exif_imagetype($file);
			\unlink($file);
		} elseif (\function_exists('getimagesize')) {
			\set_error_handler(vec[$this, 'muteErrorHandler']);
			$__unused = null;
			$info = \getimagesize($file, inout $__unused);
			\restore_error_handler();
			\unlink($file);
			if ($info == false) {
				return false;
			}
			$image_code = $info[2];
		} else {
			throw new \Error("could not find exif_imagetype or getimagesize functions", \E_USER_ERROR);
		}
		$real_content_type = \image_type_to_mime_type($image_code);
		if ($real_content_type != $content_type) {
			// we're nice guys; if the content type is something else we
			// support, change it over
			if (!C\contains_key($this->allowed_types, $real_content_type)) {
				return false;
			}
			$content_type = $real_content_type;
		}
		// ok, it's kosher, rewrite what we need
		$uri->userinfo = '';
		$uri->host = '';
		$uri->port = 0;
		$uri->fragment = '';
		$uri->query = '';
		$uri->path = (string)$content_type.";base64,".\base64_encode($raw_data);
		return true;
	}

	/**
	 * @param int $errno
	 * @param string $errstr
	 */
	public function muteErrorHandler(int $errno, string $errstr): void {
	}
}
