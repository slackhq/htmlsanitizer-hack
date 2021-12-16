namespace HTMLPurifier;
use namespace HH\Lib\C;

enum html_tags_t: string {

	//Main root
	HTML = "html";

	//Document metadata
	BASE = "base";
	HEAD = "head";
	LINK = "link";
	META = "meta";
	STYLE = "style";
	TITLE = "title";

	//Sectioning root
	BODY = "body";

	//Content sectioningSection
	ADDRESS = "address";
	ARTICLE = "article";
	ASIDE = "aside";
	FOOTER = "footer";
	HEADER = "header";
	H1 = "h1";
	H2 = "h2";
	H3 = "h3";
	H4 = "h4";
	H5 = "h5";
	H6 = "h6";
	HGROUP = "hgroup";
	MAIN = "main";
	NAV = "nav";
	SECTION = "section";

	//Text content
	BLOCKQUOTE = "blockquote";
	DD = "dd";
	DIR = "dir";
	DIV = "div";
	DL = "dl";
	DT = "dt";
	FIGCAPTION = "figcaption";
	FIGURE = "figure";
	HR = "hr";
	LI = "li";
	OL = "ol";
	P = "p";
	PRE = "pre";
	UL = "ul";

	//Inline text semantics
	A = "a";
	ABBR = "abbr";
	B = "b";
	BDI = "bdi";
	BDO = "bdo";
	BR = "br";
	CITE = "cite";
	CODE = "code";
	DATA = "data";
	DFN = "dfn";
	EM = "em";
	I = "i";
	KBD = "kbd";
	MARK = "mark";
	Q = "q";
	RB = "rb";
	RP = "rp";
	RT = "rt";
	RTC = "rtc";
	RUBY = "ruby";
	S = "s";
	SAMP = "samp";
	SMALL = "small";
	SPAN = "span";
	STRONG = "strong";
	SUB = "sub";
	SUP = "sup";
	TIME = "time";
	TT = "tt";
	U = "u";
	VAR = "var";
	WBR = "wbr";

	//Image and multimedia
	AREA = "area";
	AUDIO = "audio";
	IMG = "img";
	MAP = "map";
	TRACK = "track";
	VIDEO = "video";

	//Embedded content
	APPLET = "applet";
	EMBED = "embed";
	IFRAME = "iframe";
	NOEMBED = "noembed";
	OBJECT = "object";
	PARAM = "param";
	PICTURE = "picture";
	SOURCE = "source";

	//Scripting
	CANVAS = "canvas";
	NOSCRIPT = "noscript";
	SCRIPT = "script";

	//Demarcating edits
	DEL = "del";
	INS = "ins";

	//Table content
	CAPTION = "caption";
	COL = "col";
	COLGROUP = "colgroup";
	TABLE = "table";
	TBODY = "tbody";
	TD = "td";
	TFOOT = "tfoot";
	TH = "th";
	THEAD = "thead";
	TR = "tr";

	//Forms
	BUTTON = "button";
	DATALIST = "datalist";
	FIELDSET = "fieldset";
	FORM = "form";
	INPUT = "input";
	LABEL = "label";
	LEGEND = "legend";
	METER = "meter";
	OPTGROUP = "optgroup";
	OPTION = "option";
	OUTPUT = "output";
	PROGRESS = "progress";
	SELECT = "select";
	TEXTAREA = "textarea";

	//Interactive elements
	DETAILS = "details";
	DIALOG = "dialog";
	MENU = "menu";
	MENUITEM = "menuitem";
	SUMMARY = "summary";

	//Web Components
	CONTENT = "content";
	ELEMENT = "element";
	SHADOW = "shadow";
	SLOT = "slot";
	TEMPLATE = "template";

	//Obsolete and deprecated elements
	ACRONYM = "acronym";
	BASEFONT = "basefont";
	BGSOUND = "bgsound";
	BIG = "big";
	BLINK = "blink";
	CENTER = "center";
	COMMAND = "command";
	FONT = "font";
	FRAME = "frame";
	FRAMESET = "frameset";
	IMAGE = "image";
	ISINDEX = "isindex";
	KEYGEN = "keygen";
	LISTING = "listing";
	MARQUEE = "marquee";
	MULTICOL = "multicol";
	NEXTID = "nextid";
	NOBR = "nobr";
	NOFRAMES = "noframes";
	PLAINTEXT = "plaintext";
	SPACER = "spacer";
	STRIKE = "strike";
	XMP = "xmp";
}

enum html_attributes_t: string {
	ACCEPT = "accept";
	ACCEPTCHARSET = "accept-charset";
	ACCESSKEY = "accesskey";
	ACTION = "action";
	ALIGN = "align";
	ALLOW = "allow";
	ALLOWFULLSCREEN = 'allowfullscreen';
	ALT = "alt";
	ASYNC = "async";
	AUTOCAPITALIZE = "autocapitalize";
	AUTOCOMPLETE = "autocomplete";
	AUTOFOCUS = "autofocus";
	AUTOPLAY = "autoplay";
	BGCOLOR = "bgcolor";
	BORDER = "border";
	BUFFERED = "buffered";
	CHALLENGE = "challenge";
	CHARSET = "charset";
	CHECKED = "checked";
	CITE = "cite";
	CLASSES = "class"; // cannot be named "CLASS"
	CODE = "code";
	CODEBASE = "codebase";
	COLOR = "color";
	COLS = "cols";
	COLSPAN = "colspan";
	CONTENT = "content";
	CONTENTEDITABLE = "contenteditable";
	CONTEXTMENU = "contextmenu";
	CONTROLS = "controls";
	COORDS = "coords";
	CROSSORIGIN = "crossorigin";
	CSP = "csp";
	DATA = "data";
	DATETIME = "datetime";
	DECODING = "decoding";
	DEFAULT = "default";
	DEFER = "defer";
	DIR = "dir";
	DIRNAME = "dirname";
	DISABLED = "disabled";
	DOWNLOAD = "download";
	DRAGGABLE = "draggable";
	DROPZONE = "dropzone";
	ENCTYPE = "enctype";
	FOR = "for";
	FORM = "form";
	FORMACTION = "formaction";
	HEADERS = "headers";
	HEIGHT = "height";
	HIDDEN = "hidden";
	HIGH = "high";
	HREF = "href";
	HREFLANG = "hreflang";
	HTTPEQUIV = "http-equiv";
	ICON = "icon";
	ID = "id";
	IMPORTANCE = "importance";
	INTEGRITY = "integrity";
	ISMAP = "ismap";
	ITEMPROP = "itemprop";
	KEYTYPE = "keytype";
	KIND = "kind";
	LABEL = "label";
	LANG = "lang";
	LANGUAGE = "language";
	LAZYLOAD = "lazyload";
	LIST = "list";
	LOOP = "loop";
	LOW = "low";
	MANIFEST = "manifest";
	MAX = "max";
	MAXLENGTH = "maxlength";
	MINLENGTH = "minlength";
	MEDIA = "media";
	METHOD = "method";
	MIN = "min";
	MULTIPLE = "multiple";
	MUTED = "muted";
	NAME = "name";
	NOVALIDATE = "novalidate";
	OPEN = "open";
	OPTIMUM = "optimum";
	PATTERN = "pattern";
	PING = "ping";
	PLACEHOLDER = "placeholder";
	POSTER = "poster";
	PRELOAD = "preload";
	RADIOGROUP = "radiogroup";
	READONLY = "readonly";
	REFERRERPOLICY = "referrerpolicy";
	REL = "rel";
	REQUIRED = "required";
	REVERSED = "reversed";
	ROWS = "rows";
	ROWSPAN = "rowspan";
	SANDBOX = "sandbox";
	SCOPE = "scope";
	SCOPED = "scoped";
	SELECTED = "selected";
	SHAPE = "shape";
	SIZE = "size";
	SIZES = "sizes";
	SLOT = "slot";
	SPAN = "span";
	SPELLCHECK = "spellcheck";
	SRC = "src";
	SRCDOC = "srcdoc";
	SRCLANG = "srclang";
	SRCSET = "srcset";
	START = "start";
	STEP = "step";
	STYLE = "style";
	SUMMARY = "summary";
	TABINDEX = "tabindex";
	TARGET = "target";
	TITLE = "title";
	TRANSLATE = "translate";
	TYPE = "type";
	USEMAP = "usemap";
	VALUE = "value";
	WIDTH = "width";
	WRAP = "wrap";
	DATA_CHECKED = "data-checked";
	DATA_CLOG_CLICK = "data-clog-click";
	DATA_CLOG_UI_ELEMENT = "data-clog-ui-element";
	DATA_CLOG_UI_STEP = "data-clog-ui-step";
}

type html_input_t = shape(
	'dirty_html' => string,
	'policy' => HTMLSanitizerPolicy,
);

/*
* Default policy constant. This is the list of default allowed tags and
* attributes when calling `HTMLSanitizerPolicy::fromEmpty()`
 */
const dict<html_tags_t, keyset<html_attributes_t>> HTML_SANITIZER_DEFAULT_POLICY = dict[
	html_tags_t::P => keyset[],
	html_tags_t::B => keyset[],
	html_tags_t::I => keyset[],
];

final class HTMLSanitizerException extends \Exception {}

/**
 * HTMLSanitizerPolicy lets you define allowlist policy settings for html purifier
 */

final class HTMLSanitizerPolicy {

	private dict<html_tags_t, keyset<html_attributes_t>> $html_purifier_policy = dict[];

	/**
	 * Construct policy class from set of predefined policy allowlist
	 *
	 * @param html_purifier_policy_from_t $policyFrom select from predefined policy
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function __construct(dict<html_tags_t, keyset<html_attributes_t>> $policy) {
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
	 * @param html_tags_t $tag
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTag(html_tags_t $allowed_tag): HTMLSanitizerPolicy {
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
	 * @param keyset<html_tags_t> $allowed_tags
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTags(keyset<html_tags_t> $allowed_tags): HTMLSanitizerPolicy {
		foreach ($allowed_tags as $allowed_tag) {
			$this->addAllowedTag($allowed_tag);
		}
		return $this;
	}

	/**
	 * Add a tag with allowed attributes to the allowlist
	 *
	 * @param keyset<html_tags_t> $allowed_tags
	 * @return HTMLSanitizerPolicy the current HTMLSanitizerPolicy object
	 */
	public function addAllowedTagWithAttributes(
		html_tags_t $tag,
		keyset<html_attributes_t> $attributes,
	): HTMLSanitizerPolicy {
		$this->addAllowedTag($tag);
		foreach ($attributes as $attribute) {
			$this->html_purifier_policy[$tag][] = $attribute;
		}
		return $this;
	}

	public function addAllowedTagsWithAttributes(
		dict<html_tags_t, keyset<html_attributes_t>> $allowed_tags,
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
