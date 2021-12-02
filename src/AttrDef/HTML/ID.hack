/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates the HTML attribute ID.
 * @warning Even though this is the id processor, it
 *          will ignore the directive Attr:IDBlocklist, since it will only
 *          go according to the ID accumulator. Since the accumulator is
 *          automatically generated, it will have already absorbed the
 *          Blocklist. If you're hacking around, make sure you use load()!
 */

class HTMLPurifier_AttrDef_HTML_ID extends HTMLPurifier\HTMLPurifier_AttrDef {

	// selector is NOT a valid thing to use for IDREFs, because IDREFs
	// *must* target IDs that exist, whereas selector #ids do not.

	/**
	 * Determines whether or not we're validating an ID in a CSS
	 * selector context.
	 * @type bool
	 */
	protected bool $selector;

	/**
	 * @param bool $selector
	 */
	public function __construct(bool $selector = false) {
		$this->selector = $selector;
	}

	/**
	 * @param string $id
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $id,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		if (!$this->selector && !$config->def->defaults['Attr.EnableID']) {
			return '';
		}

		$id = Str\trim($id); // trim it first

		if ($id === '') {
			return $id;
		}

		$prefix = $config->def->defaults['Attr.IDPrefix'];
		if ($prefix !== '') {
			$prefix .= $config->def->defaults['Attr.IDPrefixLocal'];
			// prevent re-appending the prefix
			if (Str\search($id, $prefix) !== 0) {
				$id = $prefix.$id;
			}
		} elseif ($config->def->defaults['Attr.IDPrefixLocal'] !== '') {
			// trigger_error(
			//     '%Attr.IDPrefixLocal cannot be used unless ' .
			//     '%Attr.IDPrefix is set',
			//     E_USER_WARNING
			// );
			throw new \Exception('%Attr.IDPrefixLocal cannot be used unless '.'%Attr.IDPrefix is set');
		}

		if (!$this->selector) {
			$id_accumulator = $context->get('IDAccumulator');
			if ($id_accumulator is HTMLPurifier\HTMLPurifier_IDAccumulator && $id_accumulator->ids[$id]) {
				return '';
			}
		}

		// we purposely avoid using regex, hopefully this is faster

		if ($config->def->defaults['Attr.ID.HTML5'] === true) {
			if (\preg_match('/[\t\n\x0b\x0c ]/', $id)) {
				return '';
			}
		} else {
			if (\ctype_alpha($id)) {
				// OK
			} else {
				if (!\ctype_alpha($id[0])) {
					return '';
				}
				// primitive style of regexps, I suppose
				$trim = Str\trim($id, 'A..Za..z0..9:-._');
				if ($trim !== '') {
					return '';
				}
			}
		}

		$regexp = $config->def->defaults['Attr.IDBlocklistRegexp'];
		if ($regexp && \preg_match($regexp, $id)) {
			return '';
		}

		if (!$this->selector) {
			$id_accumulator = $context->get('IDAccumulator');
			if ($id_accumulator is HTMLPurifier\HTMLPurifier_IDAccumulator) {
				$id_accumulator->add($id);
			}
		}

		// if no change was made to the ID, return the result
		// else, return the new id if stripping whitespace made it
		//     valid, or return false.
		return $id;
	}
}
