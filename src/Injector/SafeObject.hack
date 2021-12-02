/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;
use Facebook\TypeAssert;

/**
 * Adds important param elements to inside of object in order to make
 * things safe.
 */
class HTMLPurifier_Injector_SafeObject extends HTMLPurifier\HTMLPurifier_Injector {
	/**
	 * @type string
	 */
	public string $name = 'SafeObject';

	/**
	 * @type array
	 */
	public dict<string, vec<string>> $needed = dict['object' => vec[], 'param' => vec[]];

	/**
	 * @type array
	 */
	protected vec<HTMLPurifier\HTMLPurifier_Token> $objectStack = vec[];

	/**
	 * @type array
	 */
	protected vec<dict<string, mixed>> $paramStack = vec[];

	/**
	 * Keep this synchronized with AttrTransform/SafeParam.php.
	 * @type array
	 */
	protected dict<string, string> $addParam = dict[
		'allowScriptAccess' => 'never',
		'allowNetworking' => 'internal',
	];

	/**
	 * These are all lower-case keys.
	 * @type array
	 */
	protected dict<string, bool> $allowedParam = dict[
		'wmode' => true,
		'movie' => true,
		'flashvars' => true,
		'src' => true,
		'allowfullscreen' => true, // if omitted, assume to be 'false'
	];

	public function __construct(): void {
		throw new \Exception(
			"SafeObject is not allowed for the time being. If you are seeing this, please change your AutoFormat configuration.",
		);
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function prepare(
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		return parent::prepare($config, $context);
	}

	public function handleElement(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		if (!($token is Token\HTMLPurifier_Token_Tag || $token is Token\HTMLPurifier_Token_Text)) {
			throw new \Exception("Handle Element needs a token with a name in SafeObject.hack");
		}
		if ($token->name == 'object') {
			$this->objectStack[] = $token;
			$this->paramStack[] = dict[];
			$new = vec[$token];
			foreach ($this->addParam as $name => $value) {
				$new[] = new Token\HTMLPurifier_Token_Empty('param', dict['name' => $name, 'value' => $value]);
			}
			return $new;
		} elseif ($token->name == 'param') {
			$nest = C\count($this->currentNesting) - 1;
			$nestToken = $this->currentNesting[$nest];
			if (!($nestToken is Token\HTMLPurifier_Token_Tag || $nestToken is Token\HTMLPurifier_Token_Text)) {
				throw new \Exception("Handle Element needs a node with a name in the elseif in SafeObject.hack");
			}

			if ($token is Token\HTMLPurifier_Token_Tag && $nest >= 0 && $nestToken->name === 'object') {
				$i = C\count($this->objectStack) - 1;
				if (!C\contains_key($token->attr, 'name')) {
					return false;
				}
				$n = (string)$token->attr['name'];
				// We need this fix because YouTube doesn't supply a data
				// attribute, which we need if a type is specified. This is
				// *very* Flash specific.
				$objectStackToken = TypeAssert\matches<Token\HTMLPurifier_Token_Tag>($this->objectStack[$i]);
				if (
					!C\contains_key($objectStackToken->attr, 'data') &&
					($token->attr['name'] == 'movie' || $token->attr['name'] == 'src')
				) {
					$objectStackToken->attr['data'] = $token->attr['value'];
					$this->objectStack[$i] = $objectStackToken;
				}
				// Check if the parameter is the correct value but has not
				// already been added
				if (
					!C\contains_key($this->paramStack[$i], $n) &&
					C\contains_key($this->addParam, $n) &&
					$token->attr['name'] === $this->addParam[$n]
				) {
					// keep token, and add to param stack
					$this->paramStack[$i][$n] = true;
					return $token;
				} elseif (C\contains_key($this->allowedParam, Str\lowercase($n))) {
					// keep token, don't do anything to it
					// (could possibly check for duplicates here)
					// Note: In principle, parameters should be case sensitive.
					// But it seems they are not really; so accept any case.
					return $token;
				} else {
					return false;
				}
			} else {
				// not directly inside an object, DENY!
				return false;
			}
		} else {
			return $token;
		}
	}

	public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		// This is the WRONG way of handling the object and param stacks;
		// we should be inserting them directly on the relevant object tokens
		// so that the global stack handling handles it.
		if (
			($token is Token\HTMLPurifier_Token_Tag || $token is Token\HTMLPurifier_Token_Text) &&
			$token->name == 'object'
		) {
			$objectStackLength = C\count($this->objectStack);
			Vec\drop($this->objectStack, $objectStackLength - 1);
			$paramStackLength = C\count($this->paramStack);
			Vec\drop($this->paramStack, $paramStackLength - 1);
		}
		return $token;
	}

	<<__Override>>
	public function handleText(HTMLPurifier\HTMLPurifier_Token $token): void {
	}
}
