/* Created by Jacob Polacek on 6/17/2020 */

namespace HTMLPurifier\Strategy;
use namespace HTMLPurifier;

/**
 * Core strategy composed of the big four strategies.
 */
class HTMLPurifier_Strategy_Core extends HTMLPurifier_Strategy_Composite {
	public function __construct() {
		$this->strategies[] = new HTMLPurifier_Strategy_RemoveForeignElements();
		$this->strategies[] = new HTMLPurifier_Strategy_MakeWellFormed();
		$this->strategies[] = new HTMLPurifier_Strategy_FixNesting();
		$this->strategies[] = new HTMLPurifier_Strategy_ValidateAttributes();
	}
}
