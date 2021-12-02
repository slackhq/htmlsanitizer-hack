/* Created by Jacob Polacek oc 06/29/2020 */

namespace HTMLPurifier;
use namespace HTMLPurifier\URIScheme;
use namespace HH\Lib\C;
use namespace Facebook\TypeSpec;

/**
 * Registry for retrieving specific URI scheme validator objects.
 */
class HTMLPurifier_URISchemeRegistry {

	/**
	 * Retrieve sole instance of the registry.
	 * @param HTMLPurifier_URISchemeRegistry $prototype Optional prototype to overload sole instance with,
	 *                   or bool true to reset to default registry.
	 * @return HTMLPurifier_URISchemeRegistry
	 * @note Pass a registry object $prototype with a compatible interface and
	 *       the function will copy it and return it all further times.
	 */
	public static function instance(?HTMLPurifier_URISchemeRegistry $prototype = null): HTMLPurifier_URISchemeRegistry {
		$instance = null;
		if ($prototype !== null) {
			$instance = $prototype;
		} elseif ($instance === null || $prototype == true) {
			$instance = new HTMLPurifier_URISchemeRegistry();
		}
		return $instance;
	}

	/**
	 * Cache of retrieved schemes.
	 */
	protected dict<string, HTMLPurifier_URIScheme> $schemes = dict[];

	/**
	 * Retrieves a scheme validator object
	 * @param string $scheme String scheme name like http or mailto
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return HTMLPurifier_URIScheme
	 */
	public function getScheme(
		string $scheme,
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
	): ?HTMLPurifier_URIScheme {
		if (!$config) {
			$config = HTMLPurifier_Config::createDefault();
		}

		// important, otherwise attacker could include arbitrary file
		$allowed_schemes = $config->def->defaults['URI.AllowedSchemes'];
		if (!$config->def->defaults['URI.OverrideAllowedSchemes'] && !C\contains($allowed_schemes, $scheme)) {
			echo "Doing nothing... atttacker may be trying to include arbitrary file.\n";
			throw new \Exception();
		}

		if (C\contains_key($this->schemes, $scheme)) {
			return $this->schemes[$scheme];
		}
		if (!C\contains($allowed_schemes, $scheme)) {
			return null;
		}

		// $class = 'HTMLPurifier_URIScheme_' . $scheme;
		// if (!\class_exists($class)) {
		//     echo "Class does not exist.\n";
		//     throw new \Exception();
		// }
		switch ($scheme) {
			case ("https"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_https();
				break;
			case ("http"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_http();
				break;
			case ("nntp"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_nntp();
				break;
			case ("news"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_news();
				break;
			case ("tel"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_tel();
				break;
			case ("mailto"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_mailto();
				break;
			case ("file"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_file();
				break;
			case ("ftp"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_ftp();
				break;
			case ("data"):
				$this->schemes[$scheme] = new URIScheme\HTMLPurifier_URIScheme_data();
				break;
		}
		return $this->schemes[$scheme];
	}

	/**
	 * Registers a custom scheme to the cache, bypassing reflection.
	 * @param string $scheme Scheme name
	 * @param HTMLPurifier_URIScheme $scheme_obj
	 */
	public function register(string $scheme, HTMLPurifier_URIScheme $scheme_obj): void {
		$this->schemes[$scheme] = $scheme_obj;
	}
}
