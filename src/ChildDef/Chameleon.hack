/* Created by Jacob Polacek on 06/26/2020 */

namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;

/**
 * Definition that uses different definitions depending on context.
 *
 * The del and ins tags are notable because they allow different types of
 * elements depending on whether or not they're in a block or inline context.
 * Chameleon allows this behavior to happen by using two different
 * definitions depending on context.  While this somewhat generalized,
 * it is specifically intended for those two tags.
 */
class HTMLPurifier_ChildDef_Chameleon extends HTMLPurifier\HTMLPurifier_ChildDef {

	/**
	 * Instance of the definition object to use when inline. Usually stricter.
	 */
	public HTMLPurifier_ChildDef_Optional $inline;

	/**
	 * Instance of the definition object to use when block.
	 */
	public HTMLPurifier_ChildDef_Optional $block;

	public string $type = 'chameleon';

	/**
	 * @param array $inline List of elements to allow when inline.
	 * @param array $block List of elements to allow when block.
	 */
	public function __construct(HTMLPurifier_ChildDef_Optional $inline, HTMLPurifier_ChildDef_Optional $block) {
		$this->inline = $inline;
		$this->block = $block;
		$this->allow_empty = false;
		$this->elements = $this->block->elements;
	}

	/**
	 * @param HTMLPurifier_Node[] $children
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool
	 */
	<<__Override>>
	public function validateChildren(
		vec<HTMLPurifier\HTMLPurifier_Node> $children,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
		if ($context->get('IsInline') === false) {
			return $this->block->validateChildren($children, $config, $context);
		} else {
			return $this->inline->validateChildren($children, $config, $context);
		}
	}
}
