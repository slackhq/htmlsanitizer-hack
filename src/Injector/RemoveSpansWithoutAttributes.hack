/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Injector that removes spans with no attributes
 */
class HTMLPurifier_Injector_RemoveSpansWithoutAttributes extends HTMLPurifier\HTMLPurifier_Injector {
	public string $name = 'RemoveSpansWithoutAttributes';

	public dict<string, vec<string>> $needed = dict['span' => vec[]];

	/**
	 * @type HTMLPurifier_AttrValidator
	 */
	private ?HTMLPurifier\HTMLPurifier_AttrValidator $attrValidator;

	/**
	 * Used by AttrValidator.
	 * @type HTMLPurifier_Config
	 */
	private ?HTMLPurifier\HTMLPurifier_Config $config;

	/**
	 * @type HTMLPurifier_Context
	 */
	private ?HTMLPurifier\HTMLPurifier_Context $context;

	public function __construct(): void {
		throw new \Exception(
			"RemoveSpansWithoutAttributes is not allowed for the time being. If you are seeing this, please change your AutoFormat configuration.",
		);
	}

	public function prepare(
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$this->attrValidator = new HTMLPurifier\HTMLPurifier_AttrValidator();
		$this->config = $config;
		$this->context = $context;
		return parent::prepare($config, $context);
	}

	/**
	 * @param HTMLPurifier_Token $token
	 */
	public function handleElement(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		if (!($token is Token\HTMLPurifier_Token_Start) || $token->name !== 'span') {
			return $token;
		}

		// We need to validate the attributes now since this doesn't normally
		// happen until after MakeWellFormed. If all the attributes are removed
		// the span needs to be removed too.
		$attrValidator = $this->attrValidator;
		if ($attrValidator is null) {
			throw new \Exception("AttrValidator needs to be nonnull in RemoveSpansWithoutAttributes");
		}
		$config = $this->config;
		if ($config is null) {
			throw new \Exception("Config needs to be nonnull in RemoveSpansWithoutAttributes");
		}
		$context = $this->context;
		if ($context is null) {
			throw new \Exception("Context needs to be nonnull in RemoveSpansWithoutAttributes");
		}
		$attrValidator->validateToken($token, $config, $context);
		$this->attrValidator = $attrValidator;
		$token->armor[] = 'ValidateAttributes';

		if (!C\is_empty($token->attr)) {
			return $token;
		}

		$i = 0;
		$nesting = 0;
		$current = $token;
		while ($this->forwardUntilEndToken(inout $i, inout $current, inout $nesting)) {
		}

		if ($current is Token\HTMLPurifier_Token_End && $current->name === 'span') {
			// Mark closing span tag for deletion
			$current->markForDeletion = true;
			// Delete open span tag
			return false;
		}
		return $token;
	}

	/**
	 * @param HTMLPurifier_Token $token
	 */
	public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		if ($token->markForDeletion) {
			return false;
		} else {
			return $token;
		}
	}

	<<__Override>>
	public function handleText(HTMLPurifier\HTMLPurifier_Token $token): void {
	}
}
