/* Created by Nikita Ashok on 07/21/2020 */

namespace HTMLPurifier\AttrDef\URI;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Primitive email validation class based on the regexp found at
 * http://www.regular-expressions.info/email.html
 */
class HTMLPurifier_AttrDef_URI_Email_SimpleCheck extends HTMLPurifier_AttrDef_URI_Email {

	/**
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		// no support for named mailboxes i.e. "Bob <bob@example.com>"
		// that needs more percent encoding to be done
		if ($string == '') {
			return '';
		}
		$string = Str\trim($string);
		$result = \preg_match('/^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i', $string);
		if ($result) {
			return $string;
		}
		return '';
	}
}
