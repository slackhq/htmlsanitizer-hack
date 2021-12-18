//created by Nikita Ashok on 07/20/2020;
/* Holds the policy for specifying allowed elements and attributes. */

namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

use type HTMLPurifier\Enums\{HtmlTags, HtmlAttributes};

type html_input_t = shape(
	'dirty_html' => string,
	'policy' => HTMLPurifier_Policy,
);

/*
* Default policy constant. This is the list of default allowed tags and
* attributes when calling `HTMLPurifier_Policy::fromEmpty()`
 */
const dict<HtmlTags, keyset<HtmlAttributes>> HTML_SANITIZER_DEFAULT_POLICY = dict[
	HtmlTags::P => keyset[],
	HtmlTags::B => keyset[],
	HtmlTags::I => keyset[],
];

final class HTMLSanitizerException extends \Exception {}

class HTMLPurifier_Policy {
	// public dict<string, vec<string>> $allowed_tags_attributes = dict[];

	private dict<HtmlTags, keyset<HtmlAttributes>> $html_purifier_policy = dict[];

	/**
	 * Construct policy class from set of predefined policy allowlist
	 *
	 * @param html_purifier_policy_from_t $policyFrom select from predefined policy
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public function __construct(dict<HtmlTags, keyset<HtmlAttributes>> $policy) {
		foreach ($policy as $allowed_tag => $allowed_attributes) {
			$this->addAllowedTagWithAttributes($allowed_tag, $allowed_attributes);
		}
	}

	/**
	 * Use the default allowlist policy.
	 *
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public static function fromDefault(): HTMLPurifier_Policy {
		$html_purifier_policy = HTML_SANITIZER_DEFAULT_POLICY;
		return new HTMLPurifier_Policy($html_purifier_policy);
	}

	/**
	 * Use the empty allowlist policy.
	 *
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public static function fromEmpty(): HTMLPurifier_Policy {
		return new HTMLPurifier_Policy(dict[]);
	}

	/**
	 * Add a single allowed tag to the allowlist. This only allows the tag with
	 * any default safe attributes that the library sets.
	 *
	 * @param HtmlTags $tag
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public function addAllowedTag(HtmlTags $allowed_tag): HTMLPurifier_Policy {
		// Skip if we already have the same tag in the policy
		if (!C\contains_key($this->html_purifier_policy, $allowed_tag)) {
			$this->html_purifier_policy[$allowed_tag] = keyset[];
		} else {
			throw new HTMLSanitizerException("html tag \"(string)$allowed_tag\" already exist in the policy");
		}
		return $this;
	}

	/**
	 * Add multiple allowed tags to the allowlist. This only allows the tags with
	 * any default safe attributes that the library sets.
	 *
	 * @param keyset<HtmlTags> $allowed_tags
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public function addAllowedTags(keyset<HtmlTags> $allowed_tags): HTMLPurifier_Policy {
		foreach ($allowed_tags as $allowed_tag) {
			$this->addAllowedTag($allowed_tag);
		}
		return $this;
	}

	/**
	 * Add a tag with allowed attributes to the allowlist
	 *
	 * @param keyset<HtmlTags> $allowed_tags
	 * @return HTMLPurifier_Policy the current HTMLPurifier_Policy object
	 */
	public function addAllowedTagWithAttributes(
		HtmlTags $tag,
		keyset<HtmlAttributes> $attributes,
	): HTMLPurifier_Policy {
		$this->addAllowedTag($tag);
		foreach ($attributes as $attribute) {
			$this->html_purifier_policy[$tag][] = $attribute;
		}
		return $this;
	}

	public function addAllowedTagsWithAttributes(
		dict<HtmlTags, keyset<HtmlAttributes>> $allowed_tags,
	): HTMLPurifier_Policy {
		foreach ($allowed_tags as $tag => $attributes) {
			$this->addAllowedTagWithAttributes($tag, $attributes);
		}
		return $this;
	}

	public function configPolicy(HTMLPurifier_Config $config): HTMLPurifier_Config {
		$html_allowed = "";
		/* Get Tags and Attributes from policy objects and convert it to htmlpurifier html allowed config
		 * format: element1[attr1|attr2],element2.... 
		 */
		$allowedTagsAttributes = $this->html_purifier_policy;
		if (!C\is_empty($allowedTagsAttributes)) {
			foreach ($allowedTagsAttributes as $tag => $list_attrb) {
				$html_allowed = $html_allowed.",".(string)$tag;
				if (!C\is_empty($list_attrb)) {
					$a_attributes = vec[];
					foreach ($list_attrb as $attrb) {
						$a_attributes[] = (string)$attrb;
					}
					$s_attribute = Str\join($a_attributes, "|");
					if ($s_attribute !== "")
						$html_allowed = $html_allowed."[".$s_attribute."]";
				}
			}
			if ($html_allowed !== "") {
				$html_allowed = Str\slice($html_allowed, 1);
			}
		}
		$config->def->defaults['HTML.Allowed'] = $html_allowed;
		return $config;
	}
}
