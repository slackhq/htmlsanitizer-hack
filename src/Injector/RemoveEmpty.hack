/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

class HTMLPurifier_Injector_RemoveEmpty extends HTMLPurifier\HTMLPurifier_Injector {
	public string $name = "RemoveEmpty";

	/**
	 * @type HTMLPurifier_Context
	 */
	private ?HTMLPurifier\HTMLPurifier_Context $context;

	/**
	 * @type HTMLPurifier_Config
	 */
	private ?HTMLPurifier\HTMLPurifier_Config $config;

	/**
	 * @type HTMLPurifier_AttrValidator
	 */
	private ?HTMLPurifier\HTMLPurifier_AttrValidator $attrValidator;

	/**
	 * @type bool
	 */
	private bool $removeNbsp = false;

	/**
	 * @type bool
	 */
	private dict<string, bool> $removeNbspExceptions = dict[];

	/**
	 * Cached contents of %AutoFormat.RemoveEmpty.Predicate
	 * @type array
	 */
	private dict<string, vec<string>> $exclude = dict[];

	/**
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return void
	 */
	public function prepare(
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		parent::prepare($config, $context);
		$this->config = $config;
		$this->context = $context;
		$this->removeNbsp = $config->def->defaults['AutoFormat.RemoveEmpty.RemoveNbsp'];
		$this->removeNbspExceptions = $config->def->defaults['AutoFormat.RemoveEmpty.RemoveNbsp.Exceptions'];
		$this->exclude = $config->def->defaults['AutoFormat.RemoveEmpty.Predicate'];
		foreach ($this->exclude as $key => $attrs) {
			if ($attrs is string) {
				// HACK, see HTMLPurifier/Printer/ConfigForm.php
				$this->exclude[$key] = Str\split($attrs, ';');
			}
		}
		$this->attrValidator = new HTMLPurifier\HTMLPurifier_AttrValidator();
		return '';
	}

	/**
	 * @param HTMLPurifier_Token $token
	 */
	public function handleElement(HTMLPurifier\HTMLPurifier_Token $token): mixed {
		if (!$token is Token\HTMLPurifier_Token_Start) {
			return $token;
		}
		$next = false;
		$deleted = 1; // the current tag
		$zipper = $this->inputZipper;
		if ($zipper is null) {
			throw new \Exception("Zipper needs to be nonnull in RemoveEmpty");
		}
		$i = C\count($zipper->back) - 1;
		while ($i >= 0) {
			$next = $zipper->back[$i];
			if ($next is Token\HTMLPurifier_Token_Text) {
				if ($next->is_whitespace) {
					$i--;
					$deleted++;
					continue;
				}
				if ($this->removeNbsp && !C\contains_key($this->removeNbspExceptions, $token->name)) {
					$plain = Str\replace("\xC2\xA0", "", $next->data);
					$isWsOrNbsp = $plain === '' || \ctype_space($plain);
					if ($isWsOrNbsp) {
						$i--;
						$deleted++;
						continue;
					}
				}
			}
			break;
		}
		if (!$next || ($next is Token\HTMLPurifier_Token_End && $next->name == $token->name)) {
			$attrValidator = $this->attrValidator;
			if ($attrValidator is null) {
				throw new \Exception("AttrValidator needs to be nonnull in RemoveEmpty");
			}
			$config = $this->config;
			if ($config is null) {
				throw new \Exception("Config needs to be nonnull in RemoveEmpty");
			}
			$context = $this->context;
			if ($context is null) {
				throw new \Exception("Context needs to be nonnull in RemoveEmpty");
			}
			$attrValidator->validateToken($token, $config, $context);
			$this->attrValidator = $attrValidator;
			$token->armor[] = 'ValidateAttributes';
			if (C\contains_key($this->exclude, $token->name)) {
				$r = true;
				foreach ($this->exclude[$token->name] as $elem) {
					if (!C\contains_key($token->attr, $elem)) $r = false;
				}
				if ($r) {
					$this->inputZipper = $zipper;
					return $token;
				}
			}
			if (C\contains_key($token->attr, 'id') || C\contains_key($token->attr, 'name')) {
				$this->inputZipper = $zipper;
				return $token;
			}
			$token = $deleted + 1;
			$b = 0;
			$c = C\count($zipper->front);
			while ($b < $c) {
				$prev = $zipper->front[$b];
				if ($prev is Token\HTMLPurifier_Token_Text && $prev->is_whitespace) {
					$b++;
					continue;
				}
				break;
			}
			// This is safe because we removed the token that triggered this.
			$this->rewindOffset($b + $deleted);
			$this->inputZipper = $zipper;
			return $token;
		} else {
			return $token;
		}
	}

	<<__Override>>
	public function handleText(HTMLPurifier\HTMLPurifier_Token $token): void {
	}

	<<__Override>>
	public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token): void {
	}
}
