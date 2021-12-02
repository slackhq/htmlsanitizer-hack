/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\URI;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str, Vec};

/**
 * Validates an IPv6 address.
 * @author Feyd @ forums.devnetwork.net (public domain)
 * @note This function requires brackets to have been removed from address
 *       in URI.
 */
class HTMLPurifier_AttrDef_URI_IPv6 extends HTMLPurifier_AttrDef_URI_IPv4 {

	/**
	 * @param string $aIP
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string
	 */
	public function validate(
		string $aIP,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		if (!$this->ip4) {
			$this->_loadRegex();
		}

		$original = $aIP;

		$hex = '[0-9a-fA-F]';
		$blk = '(?:'.$hex.'{1,4})';
		$pre = '(?:/(?:12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))'; // /0 - /128
		$find = vec[];
		//      prefix check
		if (Str\search($aIP, '/') is nonnull) {
			if (\preg_match_with_matches('#'.$pre.'$#s', $aIP, inout $find)) {
				$aIP = Str\slice($aIP, 0, 0 - Str\length($find[0]));
				$find = vec[];
			} else {
				return '';
			}
		}

		//      IPv4-compatiblity check
		if (\preg_match_with_matches('#(?<=:'.')'.$this->ip4.'$#s', $aIP, inout $find)) {
			$aIP = Str\slice($aIP, 0, 0 - Str\length($find[0]));
			$ip = Str\split($find[0], '.');
			$dechex_ip = vec[];
			foreach ($ip as $i) {
				$hex_ip = \dechex((int)$i);
				$dechex_ip[] = $hex_ip;
			}
			$ip = $dechex_ip;
			$aIP .= $ip[0].$ip[1].':'.$ip[2].$ip[3];
			$find = vec[];
			$ip = vec[];
		}

		//      compression check
		$aIP = Str\split($aIP, '::');
		$c = C\count($aIP);
		if ($c > 2) {
			return '';
		} elseif ($c == 2) {
			list($first, $second) = $aIP;
			$first = Str\split($first, ':');
			$second = Str\split($second, ':');

			if (C\count($first) + C\count($second) > 8) {
				return '';
			}

			while (C\count($first) < 8) {
				$first[] = '0';
			}

			\array_splice(inout $first, 8 - C\count($second), 8, $second);
			$aIP = $first;
			$first = vec[];
			$second = vec[];
		} else {
			$aIP = Str\split($aIP[0], ':');
		}
		if (!($aIP is vec<_>)) {
			throw new \Exception('aIP needs to be a vec');
		}
		$c = C\count($aIP);

		if ($c != 8) {
			return '';
		}

		//      All the pieces should be 16-bit hex strings. Are they?
		foreach ($aIP as $piece) {
			if ($piece is string && !\preg_match('#^[0-9a-fA-F]{4}$#s', Str\format('%04s', $piece))) {
				return '';
			}
		}
		return $original;
	}
}
