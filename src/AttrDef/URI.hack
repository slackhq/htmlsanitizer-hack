/* Created by Jacob Polacek on 06/29/2020 */
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;

/**
 * Validates a URI as defined by RFC 3986.
 * @note Scheme-specific mechanics deferred to HTMLPurifier_URIScheme
 */
class HTMLPurifier_AttrDef_URI extends HTMLPurifier\HTMLPurifier_AttrDef {

	protected HTMLPurifier\HTMLPurifier_URIParser $parser;

	protected bool $embedsResource;

	public function __construct(bool $embeds_resource = false): void {
		$this->parser = new HTMLPurifier\HTMLPurifier_URIParser();
		$this->embedsResource = (bool)$embeds_resource;
	}

	<<__Override>>
	public function make(string $string): HTMLPurifier_AttrDef_URI {
		$embeds = ($string === 'embedded');
		return new HTMLPurifier_AttrDef_URI($embeds);
	}

	/**
	 * @param string $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string
	 */
	<<__Override>>
	public function validate(
		string $uri,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		if ($config->def->defaults['URI.Disable']) {
			throw new \Exception("URI Disabled");
		}

		$uri = $this->parseCDATA($uri);

		// parse the URI
		$uri = $this->parser->parse($uri);
		if ($uri === false) {
			throw new \Exception("URI === false");
		}

		// add embedded flag to context for validators
		$context->register('EmbeddedURI', $this->embedsResource);

		$ok = false;
		do {
			// generic validation
			$result = $uri->validate($config, $context);
			if (!$result) {
				break;
			}

			// chained filtering
			$uri_def = $config->getURIDefinition();
			$result = $uri_def->filter(inout $uri, $config, $context);
			if (!$result) {
				break;
			}

			// scheme-specific validation
			$scheme_obj = $uri->getSchemeObj($config, $context);
			if (!$scheme_obj) {
				break;
			}
			if ($this->embedsResource && !$scheme_obj->browsable) {
				break;
			}
			$result = $scheme_obj->validate($uri, $config, $context);
			if (!$result) {
				break;
			}

			// Post chained filtering
			$result = $uri_def->postFilter(inout $uri, $config, $context);
			if (!$result) {
				break;
			}

			// survived gauntlet
			$ok = true;

		} while (false);

		$context->destroy('EmbeddedURI');
		if (!$ok) {
			return '';
		}
		// back to string
		return $uri->toString();
	}
}
