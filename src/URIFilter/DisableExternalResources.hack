/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;

class HTMLPurifier_URIFilter_DisableExternalResources extends HTMLPurifier_URIFilter_DisableExternal {
	/**
	 * @type string
	 */
	public string $name = 'DisableExternalResources';

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	<<__Override>>
	public function filter(
		inout HTMLPurifier\HTMLPurifier_URI $uri,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): bool {
		if (!(bool)$context->get('EmbeddedURI', true)) {
			return true;
		}
		return parent::filter(inout $uri, $config, $context);
	}
}
