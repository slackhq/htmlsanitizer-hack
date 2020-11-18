/* Created by Chenkai Gao on 11/16/2020 */
namespace HTMLPurifier\AttrTransform;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
// must be called POST validation

/**
 * Adds rel="noreferrer" to any links which target a different window
 * than the current one.  This is used to prevent malicious websites
 * from silently replacing the original window, which could be used
 * to do phishing.
 * This transform is controlled by %HTML.TargetNoreferrer.
 */
class HTMLPurifier_AttrTransform_TargetNoreferrer extends HTMLPurifier\HTMLPurifier_AttrTransform {
	/**
	* @param dic<string, string> $attr
	* @param HTMLPurifier_Config $config
	* @param HTMLPurifier_Context $context
	* @return dict<string, string>
	 */
	public function transform(
		dict<string, string> $attr,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): dict<string, string> {
		if (!$config->def->defaults['HTML.TargetNoreferrer']) {
			# This transform is turned off in the configuration
			return $attr;
		}
		if (C\contains_key($attr, 'rel')) {
			$rels = Str\split($attr['rel'], ' ');
		} else {
			$rels = vec<string>[];
		}
		if (C\contains_key($attr, 'target') && !C\contains($rels, 'noreferrer')) {
			$rels[] = 'noreferrer';
		}
		if (!C\is_empty($rels) || C\contains_key($attr, 'rel')) {
			$attr['rel'] = Str\join($rels, ' ');
		}

		return $attr;
	}
}
