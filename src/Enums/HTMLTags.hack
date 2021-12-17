namespace HTMLPurifier\Enums;

enum HtmlTags: string {

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
