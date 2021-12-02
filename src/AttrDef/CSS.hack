// Created by Nikita Ashok on 7/7/20;
namespace HTMLPurifier\AttrDef;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Definition;
use namespace Facebook\TypeAssert;
use namespace HH\Lib\Str;

/**
 * Validates the HTML attribute style, otherwise known as CSS.
 * @note We don't implement the whole CSS specification, so it might be
 *       difficult to reuse this component in the context of validating
 *       actual stylesheet declarations.
 * @note If we were really serious about validating the CSS, we would
 *       tokenize the styles and then parse the tokens. Obviously, we
 *       are not doing that. Doing that could seriously harm performance,
 *       but would make these components a lot more viable for a CSS
 *       filtering solution.
 */

class HTMLPurifier_AttrDef_CSS extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * @param string $css
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return bool|string
	 */
	public function validate(
		string $css,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$css = $this->parseCDATA($css);

		$definition = TypeAssert\instance_of(Definition\HTMLPurifier_CSSDefinition::class, $config->getCSSDefinition());
		$allow_duplicates = $config->def->defaults["CSS.AllowDuplicates"];

		// According to the CSS2.1 spec, the places where a
		// non-delimiting semicolon can appear are in strings
		// escape sequences.   So here is some dumb hack to
		// handle quotes.
		$len = Str\length($css);
		$accum = "";
		$declarations = vec[];
		$quoted = false;
		for ($i = 0; $i < $len; $i++) {
			$c = \strcspn($css, ";'\"", $i);
			$accum .= Str\slice($css, $i, $c);
			$i += $c;
			if ($i == $len) break;
			$d = $css[$i];
			if ($quoted) {
				$accum .= $d;
				if ($d == $quoted) {
					$quoted = false;
				}
			} else {
				if ($d == ";") {
					$declarations[] = $accum;
					$accum = "";
				} else {
					$accum .= $d;
					$quoted = $d;
				}
			}
		}
		if ($accum !== "") $declarations[] = $accum;

		$propvalues = dict[];
		$new_declarations = '';

		/**
		 * Name of the current CSS property being validated.
		 */
		$property = false;
		$context->register('CurrentCSSProperty', $property);

		foreach ($declarations as $declaration) {
			if (!$declaration) {
				continue;
			}
			if (!Str\search($declaration, ':')) {
				continue;
			}
			list($property, $value) = Str\split($declaration, ':', 2);
			$property = Str\trim($property);
			$value = Str\trim($value);
			$ok = false;
			do {
				if (isset($definition->info[$property])) {
					$ok = true;
					break;
				}
				if (\ctype_lower($property)) {
					break;
				}
				$property = Str\lowercase($property);
				if (isset($definition->info[$property])) {
					$ok = true;
					break;
				}
			} while (0);
			if (!$ok) {
				continue;
			}
			// inefficient call, since the validator will do this again
			if (Str\lowercase(Str\trim($value)) !== 'inherit') {
				// inherit works for everything (but only on the base property)
				$result = $definition->info[$property]->validate($value, $config, $context);
			} else {
				$result = 'inherit';
			}
			if ($result === '') {
				continue;
			}
			if ($allow_duplicates) {
				$new_declarations .= "$property:$result;";
			} else {
				$propvalues[$property] = $result;
			}
		}

		$context->destroy('CurrentCSSProperty');

		// procedure does not write the new CSS simultaneously, so it's
		// slightly inefficient, but it's the only way of getting rid of
		// duplicates. Perhaps config to optimize it, but not now.

		foreach ($propvalues as $prop => $value) {
			$new_declarations .= "$prop:$value;";
		}

		return $new_declarations ? $new_declarations : '';

	}

}

// vim: et sw=4 sts=4
