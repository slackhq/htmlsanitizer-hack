/* Created by Nikita Ashok on 07/21/2020 */

namespace HTMLPurifier\AttrDef\URI;
use namespace HTMLPurifier;
/**
 * Validates an IPv4 address
 * @author Feyd @ forums.devnetwork.net (public domain)
 */
class HTMLPurifier_AttrDef_URI_IPv4 extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * IPv4 regex, protected so that IPv6 can reuse it.
	 * @type string
	 */
	protected string $ip4 = '';

	/**
	 * @param string $aIP
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $aIP,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		if (!$this->ip4) {
			$this->_loadRegex();
		}

		if (\preg_match('#^'.$this->ip4.'$#s', $aIP)) {
			return $aIP;
		}
		return '';
	}

	/**
	 * Lazy load function to prevent regex from being stuffed in
	 * cache.
	 */
	protected function _loadRegex(): void {
		$oct = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])'; // 0-255
		$this->ip4 = "(?:{$oct}\\.{$oct}\\.{$oct}\\.{$oct})";
	}
}
