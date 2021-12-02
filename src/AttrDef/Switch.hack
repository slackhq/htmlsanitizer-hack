// Created by Nikita Ashok on 7/8/20;
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Decorator that, depending on a token, switches between two definitions.
 */
class HTMLPurifier_AttrDef_Switch extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * @type string
	 */
	protected string $tag;

	/**
	 * @type HTMLPurifier_AttrDef
	 */
	protected HTMLPurifier\HTMLPurifier_AttrDef $withTag;

	/**
	 * @type HTMLPurifier_AttrDef
	 */
	protected HTMLPurifier\HTMLPurifier_AttrDef $withoutTag;

	/**
	 * @param string $tag Tag name to switch upon
	 * @param HTMLPurifier_AttrDef $with_tag Call if token matches tag
	 * @param HTMLPurifier_AttrDef $without_tag Call if token doesn't match, or there is no token
	 */
	public function __construct(
		string $tag,
		HTMLPurifier\HTMLPurifier_AttrDef $with_tag,
		HTMLPurifier\HTMLPurifier_AttrDef $without_tag,
	) {
		$this->tag = $tag;
		$this->withTag = $with_tag;
		$this->withoutTag = $without_tag;
	}

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
		$token = $context->get('CurrentToken', true);
		if (
			!$token ||
			(
				($token is Token\HTMLPurifier_Token_Text || $token is Token\HTMLPurifier_Token_Tag) &&
				$token->name !== $this->tag
			)
		) {
			return $this->withoutTag->validate($string, $config, $context);
		} else {
			return $this->withTag->validate($string, $config, $context);
		}
	}
}
