/* Created by Chenkai Gao on 11/16/2020 */
namespace HTMLPurifier\AttrTransform;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
// must be called POST validation

/**
 * Adds target="blank" to all outbound links.  This transform is
 * only attached if Attr.TargetBlank is TRUE.  This works regardless
 * of whether or not Attr.AllowedFrameTargets
 */
class HTMLPurifier_AttrTransform_TargetBlank extends HTMLPurifier\HTMLPurifier_AttrTransform {
	/**
	 * @type HTMLPurifier_URIParser
	 */
	private HTMLPurifier\HTMLPurifier_URIParser $parser;

	public function __construct() {
		$this->parser = new HTMLPurifier\HTMLPurifier_URIParser();
	}

	/**
	* @param dic<string, mixed> $attr
	* @param HTMLPurifier_Config $config
	* @param HTMLPurifier_Context $context
	* @return dict<string, mixed>
	 */
	public function transform(
		dict<string, mixed> $attr,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): dict<string, mixed> {
		if (!isset($attr['href'])) {
			return $attr;
		}

		// XXX Kind of inefficient
		$url = $this->parser->parse((string)$attr['href']);
		$scheme = $url->getSchemeObj($config, $context);

		if ($scheme is nonnull && $scheme->browsable && !$url->isBenign($config, $context)) {
			$attr['target'] = '_blank';
		}
		return $attr;
	}
}
