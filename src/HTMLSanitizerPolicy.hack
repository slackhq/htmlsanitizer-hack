namespace HTMLPurifier;
use namespace HH\Lib\C;
// use namespace HTMLPurifier\Enums;
use type HTMLPurifier\Enums\{HtmlTags, HtmlAttributes};

type html_input_t = shape(
	'dirty_html' => string,
	'policy' => HTMLSanitizerPolicy,
);

/*
* Default policy constant. This is the list of default allowed tags and
* attributes when calling `HTMLSanitizerPolicy::fromEmpty()`
 */
const dict<HtmlTags, keyset<HtmlAttributes>> HTML_SANITIZER_DEFAULT_POLICY = dict[
	HtmlTags::P => keyset[],
	HtmlTags::B => keyset[],
	HtmlTags::I => keyset[],
];

final class HTMLSanitizerException extends \Exception {}

/**
 * HTMLSanitizerPolicy lets you define allowlist policy settings for html purifier
 */

final class HTMLSanitizerPolicy {

	private dict<HtmlTags, keyset<HtmlAttributes>> $html_purifier_policy = dict[];

	/**
	 * Construct policy class from set of predefined policy allowlist
	 *
	 * @param html_purifier_policy_from_t $policyFrom select from predefined policy
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function __construct(dict<HtmlTags, keyset<HtmlAttributes>> $policy) {
		foreach ($policy as $allowed_tag => $allowed_attributes) {
			$this->addAllowedTagWithAttributes($allowed_tag, $allowed_attributes);
		}
	}

	/**
	 * Use the default allowlist policy.
	 *
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public static function fromDefault(): HTMLSanitizerPolicy {
		$html_purifier_policy = HTML_SANITIZER_DEFAULT_POLICY;
		return new HTMLSanitizerPolicy($html_purifier_policy);
	}

	/**
	 * Use the empty allowlist policy.
	 *
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public static function fromEmpty(): HTMLSanitizerPolicy {
		return new HTMLSanitizerPolicy(dict[]);
	}

	/**
	 * Add a single allowed tag to the allowlist. This only allows the tag with
	 * any default safe attributes that the library sets.
	 *
	 * @param HtmlTags $tag
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTag(HtmlTags $allowed_tag): HTMLSanitizerPolicy {
		// Skip if we already have the same tag in the policy
		if (!C\contains_key($this->html_purifier_policy, $allowed_tag)) {
			$this->html_purifier_policy[$allowed_tag] = keyset[];
		} else {
			throw new HTMLSanitizerException("html tag \"$allowed_tag\" already exist in the policy");
		}
		return $this;
	}

	/**
	 * Add multiple allowed tags to the allowlist. This only allows the tags with
	 * any default safe attributes that the library sets.
	 *
	 * @param keyset<HtmlTags> $allowed_tags
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTags(keyset<HtmlTags> $allowed_tags): HTMLSanitizerPolicy {
		foreach ($allowed_tags as $allowed_tag) {
			$this->addAllowedTag($allowed_tag);
		}
		return $this;
	}

	/**
	 * Add a tag with allowed attributes to the allowlist
	 *
	 * @param keyset<HtmlTags> $allowed_tags
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTagWithAttributes(
		HtmlTags $tag,
		keyset<HtmlAttributes> $attributes,
	): HTMLSanitizerPolicy {
		$this->addAllowedTag($tag);
		foreach ($attributes as $attribute) {
			$this->html_purifier_policy[$tag][] = $attribute;
		}
		return $this;
	}

	public function addAllowedTagsWithAttributes(
		dict<HtmlTags, keyset<HtmlAttributes>> $allowed_tags,
	): HTMLSanitizerPolicy {
		foreach ($allowed_tags as $tag => $attributes) {
			$this->addAllowedTagWithAttributes($tag, $attributes);
		}
		return $this;
	}

	/**
	 * This function maps the object from $html_purifier_policy to the Policy
	 * object in htmlpurifier-hack.
	 * @return Policy object for htmlpurifier-hack
	 */
	public function constructPolicy(): HTMLPurifier_Policy {
		/**
		* Do series of loop on each keys and items in $html_purifier_policy to map
		* and populate the Policy object. The loop also converts the tags and
		* attributes type to string as used by the Policy object
		*/
		$allowed_tags_attributes = dict[];
		foreach ($this->html_purifier_policy as $tag => $attributes) {
			$list_attributes = vec[];
			foreach ($attributes as $attribute) {
				$list_attributes[] = (string)$attribute;
			}
			$allowed_tags_attributes[(string)$tag] = $list_attributes;
		}
		$policy_message = new HTMLPurifier_Policy($allowed_tags_attributes);
		return $policy_message;
	}

}
