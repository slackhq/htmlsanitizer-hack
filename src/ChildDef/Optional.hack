//created by Nikita Ashok ok 6/24/20;
namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;

/**
 * Definition that allows a set of elements, and allows no children.
 * @note This is a hack to reuse code from HTMLPurifier_ChildDef_Required,
 *       really, one shouldn't inherit from the other.  Only altered behavior
 *       is to overload a returned false with an array.  Thus, it will never
 *       return false.
 */
class HTMLPurifier_ChildDef_Optional extends HTMLPurifier_ChildDef_Required {
	/**
	 * @type bool
	 */
	public bool $allow_empty = true;

	/**
	 * @type string
	 */
	public string $type = 'optional';

	/**
	 * @param array $children
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return array
	 */
	public function validateChildren(
		vec<HTMLPurifier\HTMLPurifier_Node> $children,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
		$result = parent::validateChildren($children, $config, $context);
		// we assume that $children is not modified
		if ($result[0] === false) {
			if ($children is nonnull) {
				return tuple(true, vec[]);
			} else if ($this->whitespace) {
				return tuple(false, $children);
			} else {
				return tuple(false, vec[]);
			}
		}
		return $result;
	}
}

// vim: et sw=4 sts=4
