namespace HTMLPurifier\Enums;

/**
 * The HtmlTags enums are meant to be added to policies when a developer
 * would like to allow the corresponding tag to remain in HTML.
 *
 * For example, if a developer has an empty policy, and adds HtmlTags::B
 * via one of the addTag functions defined in src/Policy.hack, their 
 * policy will then permit the presence of <b> tags in the clean HTML.
 *
 * Please note that this list of HTML Tags is incomplete. In order for a
 * tag to be used, it must also be defined in the HTMLDefinition info 
 * property (found in src/Definition/HTMLDefinition). The following tags
 * have been dropped from HtmlTags as attempting to add them to a policy
 * would result in a thrown error:
 * 		HtmlTags::HTML,
 * 		HtmlTags::BASE,
 * 		HtmlTags::HEAD,
 * 		HtmlTags::LINK,
 * 		HtmlTags::META,
 * 		HtmlTags::STYLE,
 * 		HtmlTags::TITLE,
 * 		HtmlTags::BODY,
 * 		HtmlTags::FIGURE,
 * 		HtmlTags::DATA,
 * 		HtmlTags::RB,
 * 		HtmlTags::RP,
 * 		HtmlTags::RT,
 * 		HtmlTags::RTC,
 * 		HtmlTags::RUBY,
 * 		HtmlTags::TIME,
 * 		HtmlTags::AREA,
 * 		HtmlTags::MAP,
 * 		HtmlTags::VIDEO,
 * 		HtmlTags::APPLET,
 * 		HtmlTags::EMBED,
 * 		HtmlTags::NOEMBED,
 * 		HtmlTags::OBJECT,
 * 		HtmlTags::PARAM,
 * 		HtmlTags::CANVAS,
 * 		HtmlTags::NOSCRIPT,
 * 		HtmlTags::SCRIPT,
 * 		HtmlTags::BUTTON,
 * 		HtmlTags::DATALIST,
 * 		HtmlTags::FIELDSET,
 * 		HtmlTags::FORM,
 * 		HtmlTags::INPUT,
 * 		HtmlTags::LABEL,
 * 		HtmlTags::LEGEND,
 * 		HtmlTags::METER,
 * 		HtmlTags::OPTGROUP,
 * 		HtmlTags::OPTION,
 * 		HtmlTags::OUTPUT,
 * 		HtmlTags::SELECT,
 * 		HtmlTags::TEXTAREA,
 * 		HtmlTags::DETAILS,
 * 		HtmlTags::MENUITEM,
 * 		HtmlTags::CONTENT,
 * 		HtmlTags::ELEMENT,
 * 		HtmlTags::SHADOW,
 * 		HtmlTags::SLOT,
 * 		HtmlTags::TEMPLATE,
 * 		HtmlTags::BGSOUND,
 * 		HtmlTags::BLINK,
 * 		HtmlTags::COMMAND,
 * 		HtmlTags::FRAME,
 * 		HtmlTags::FRAMESET,
 * 		HtmlTags::IMAGE,
 * 		HtmlTags::ISINDEX,
 * 		HtmlTags::KEYGEN,
 * 		HtmlTags::LISTING,
 * 		HtmlTags::MARQUEE,
 * 		HtmlTags::MULTICOL,
 * 		HtmlTags::NEXTID,
 * 		HtmlTags::NOBR,
 * 		HtmlTags::NOFRAMES,
 * 		HtmlTags::PLAINTEXT,
 * 		HtmlTags::SPACER,
 * 		HtmlTags::XMP,
 */

enum HtmlTags: string {
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
	DFN = "dfn";
	EM = "em";
	I = "i";
	KBD = "kbd";
	MARK = "mark";
	Q = "q";
	S = "s";
	SAMP = "samp";
	SMALL = "small";
	SPAN = "span";
	STRONG = "strong";
	SUB = "sub";
	SUP = "sup";
	TT = "tt";
	U = "u";
	VAR = "var";
	WBR = "wbr";

	//Image and multimedia
	AUDIO = "audio";
	IMG = "img";
	TRACK = "track";

	//Embedded content
	IFRAME = "iframe";
	PICTURE = "picture";
	SOURCE = "source";

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
	PROGRESS = "progress";
	TEXTAREA = "textarea";

	//Interactive elements
	DIALOG = "dialog";
	MENU = "menu";
	SUMMARY = "summary";

	//Obsolete and deprecated elements
	ACRONYM = "acronym";
	BASEFONT = "basefont";
	BIG = "big";
	CENTER = "center";
	FONT = "font";
	STRIKE = "strike";
}
