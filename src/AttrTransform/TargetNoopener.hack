/* Created by Chenkai Gao on 11/16/2020 */
namespace HTMLPurifier\AttrTransform;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
// must be called POST validation

/**
 * Adds rel="noopener" to any links which target a different window
 * than the current one.  This is used to prevent malicious websites
 * from silently replacing the original window, which could be used
 * to do phishing.
 * This transform is controlled by %HTML.TargetNoopener.
 */
class HTMLPurifier_AttrTransform_TargetNoopener extends HTMLPurifier\HTMLPurifier_AttrTransform {
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
		if (isset($attr['rel']) && $attr['rel'] is string) {
			$rels = Str\split((string)$attr['rel'], ' ');
		} else {
			$rels = vec<string>[];
		}
		if (isset($attr['target']) && !C\contains($rels, 'noopener')) {
			$rels[] = 'noopener';
		}
		if (!C\is_empty($rels) || isset($attr['rel'])) {
			$attr['rel'] = Str\join($rels, ' ');
		}

		return $attr;
	}
}
