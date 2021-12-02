/* Created by Jacob Polacek on 07/23/2020 */

namespace HTMLPurifier\URIFilter;
use namespace HTMLPurifier;

class HTMLPurifier_URIFilter_DisableResources extends HTMLPurifier\HTMLPurifier_URIFilter {
	/**
	 * @type string
	 */
	public string $name = 'DisableResources';

	/**
	 * @param HTMLPurifier_URI $uri
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	public function filter(
		inout HTMLPurifier\HTMLPurifier_URI $_uri,
		HTMLPurifier\HTMLPurifier_Config $_config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): bool {
		return !(bool)$context->get('EmbeddedURI', true);
	}
}
