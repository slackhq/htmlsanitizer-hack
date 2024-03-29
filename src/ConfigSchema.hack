/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

type Defaults = shape(
	"Filter.Custom" => vec<string>, // might need to change string to filter
	"Filter.ExtractStyleBlocks.Escaping" => bool,
	"Filter.ExtractStyleBlocks.Scope" => ?string,
	"Filter.ExtractStyleBlocks.TidyImpl" => ?bool,
	"Filter.ExtractStyleBlocks" => bool,
	"Filter.Youtube" => bool,
	"Core.DirectLexLineNumberSyncInterval" => int,
	"Core.EscapeInvalidChildren" => bool,
	"Core.Language" => string,
	"Core.EnableIDNA" => bool,
	"Core.AggressivelyRemoveScript" => bool,
	"Core.AggressivelyFixLt" => bool,
	"Core.CollectErrors" => bool,
	"Core.LexerImpl" => ?HTMLPurifier_Lexer,
	"Core.EscapeInvalidTags" => bool,
	"Core.RemoveInvalidImg" => bool,
	"Core.Encoding" => string,
	"Core.HiddenElements" => dict<string, bool>,
	"Core.RemoveScriptContents" => bool,
	"Core.RemoveProcessingInstructions" => bool,
	"Core.MaintainLineNumbers" => ?bool,
	"Core.NormalizeNewlines" => bool,
	"Core.ConvertDocumentToFragment" => bool,
	"Core.LegacyEntityDecoder" => bool,
	"Core.AllowParseManyTags" => bool,
	"Core.AllowHostnameUnderscore" => bool,
	"Core.DisableExcludes" => bool,
	"Core.NormalizedNewlines" => bool,
	"Core.EscapeNonASCIICharacters" => bool,
	"Core.ColorKeywords" => dict<string, string>,
	"CSS.AllowedFonts" => dict<string, bool>,
	"Attr.IDBlacklist" => vec<string>,
	"HTML.Trusted" => bool,
	"HTML.AllowedModules" => dict<string, bool>,
	"HTML.CoreModules" => dict<string, bool>,
	"HTML.Allowed" => string,
	"HTML.AllowedComments" => vec<string>,
	"HTML.AllowedElements" => dict<string, bool>,
	"HTML.AllowedAttributes" => dict<string, bool>,
	"HTML.BlockWrapper" => string,
	"HTML.Parent" => string,
	"HTML.Doctype" => string,
	"HTML.XHTML" => bool,
	"HTML.Strict" => bool,
	"HTML.Proprietary" => bool,
	"HTML.SafeObject" => bool,
	"HTML.SafeEmbed" => bool,
	"HTML.SafeScripting" => dict<string, bool>,
	"HTML.SafeIframe" => bool,
	"HTML.Nofollow" => bool,
	"HTML.TargetBlank" => bool,
	"HTML.TargetNoreferrer" => bool,
	"HTML.TargetNoopener" => bool,
	"HTML.CustomDoctype" => string,
	"HTML.AllowedCommentsRegexp" => string,
	"HTML.Attr.Name.UseCDATA" => bool,
	"HTML.DefinitionID" => string,
	"HTML.FlashAllowFullScreen" => bool,
	"HTML.ForbiddenAttributes" => dict<string, bool>,
	"HTML.ForbiddenElements" => dict<string, bool>,
	"HTML.MaxImgLength" => int,
	"HTML.TidyAdd" => dict<string, bool>,
	"HTML.TidyLevel" => string,
	"HTML.TidyRemove" => dict<string, bool>,
	"Cache.DefinitionImpl" => string,
	"Output.CommentScriptContents" => bool,
	"Output.FixInnerHTML" => bool,
	"Output.SortAttr" => bool,
	"Output.FlashCompat" => bool,
	"Output.Newline" => string,
	"Output.TidyFormat" => bool,
	"HTML.DefinitionRev" => int,
	"Cache.SerializerPath" => string,
	"Cache.SerializerPermissions" => int,
	"AutoFormat.AutoParagraph" => bool,
	"AutoFormat.Custom" => vec<HTMLPurifier_Injector>,
	"AutoFormat.DisplayLinkURI" => bool,
	"AutoFormat.Linkify" => bool,
	"AutoFormat.PurifierLinkify.DocURL" => string,
	"AutoFormat.PurifierLinkify" => bool,
	"AutoFormat.RemoveEmpty" => bool,
	"AutoFormat.RemoveEmpty.RemoveNbsp" => bool,
	"AutoFormat.RemoveEmpty.RemoveNbsp.Exceptions" => dict<string, bool>,
	"AutoFormat.RemoveEmpty.Predicate" => dict<string, vec<string>>,
	"AutoFormat.RemoveSpansWithoutAttributes" => bool,
	"Attr.IDBlocklistRegexp" => string,
	"Attr.IDBlocklist" => vec<string>,
	"URI.AllowedSchemes" => vec<string>,
	"URI.OverrideAllowedSchemes" => bool,
	"CSS.AllowDuplicates" => bool,
	"CSS.AllowTricky" => bool,
	"CSS.AllowImportant" => bool,
	"CSS.AllowedProperties" => dict<string, bool>,
	"CSS.ForbiddenProperties" => dict<string, bool>,
	"CSS.Proprietary" => bool,
	"CSS.Trusted" => bool,
	"CSS.DefinitionRev" => int,
	"CSS.MaxImgLength" => string,
	"Attr.EnableID" => bool,
	"Attr.IDPrefixLocal" => string,
	"Attr.IDPrefix" => string,
	"Attr.ID.HTML5" => bool,
	"Attr.IDlocklistRegexp" => string,
	"Attr.AllowedClasses" => dict<string, bool>,
	"Attr.ForbiddenClasses" => dict<string, bool>,
	"Attr.AllowedFrameTargets" => vec<string>,
	"Attr.AllowedRel" => dict<string, bool>,
	"Attr.AllowedRev" => dict<string, bool>,
	"Attr.ClassUseCDATA" => ?bool,
	"Attr.DefaultImageAlt" => string,
	"Attr.DefaultInvalidImage" => string,
	"Attr.DefaultInvalidImageAlt" => string,
	"Attr.DefaultTextDir" => string,
	"URI.Disable" => bool,
	"URI.Host" => string,
	"URI.Base" => string,
	"URI.SafeIframeRegexp" => string,
	"URI.DefaultScheme" => string,
	"URI.DefinitionRev" => int,
	"URI.Munge" => string,
	"URI.MungeResources" => bool,
	"URI.MungeSecretKey" => string,
	"URI.DisableExternal" => bool,
	"URI.DisableExternalResources" => bool,
	"URI.DisableResources" => bool,
	"URI.HostBlocklist" => vec<string>,
	"URI.MakeAbsolute" => bool,
	"URI.DefinitionID" => string,
	"Test.ForceNoIconv" => bool,
);

/**
 * Conifguration definition, defines directives and their defaults.
 */
class HTMLPurifier_ConfigSchema {
	// public dict<string, mixed> $defaults = dict[];
	public Defaults $defaults;

	public HTMLPurifier_PropertyList $defaultPlist;

	protected ?HTMLPurifier_ConfigSchema $singleton;

	public function __construct() {
		$this->defaultPlist = new HTMLPurifier_PropertyList();
		$this->defaults = shape(
			"Filter.Custom" => vec[],
			"Filter.ExtractStyleBlocks.Escaping" => true,
			"Filter.ExtractStyleBlocks.Scope" => null,
			"Filter.ExtractStyleBlocks.TidyImpl" => null,
			"Filter.ExtractStyleBlocks" => false,
			"Filter.Youtube" => false,
			"Core.DirectLexLineNumberSyncInterval" => 0,
			"Core.EscapeInvalidChildren" => false,
			"Core.Language" => 'en',
			"Core.EnableIDNA" => false,
			"Core.AggressivelyRemoveScript" => true,
			"Core.AggressivelyFixLt" => true,
			"Core.CollectErrors" => false,
			"Core.LexerImpl" => null,
			"Core.EscapeInvalidTags" => false,
			"Core.RemoveInvalidImg" => true,
			"Core.Encoding" => 'utf-8',
			"Core.HiddenElements" => dict['script' => true, 'style' => true],
			"Core.RemoveScriptContents" => false,
			"Core.RemoveProcessingInstructions" => false,
			"Core.MaintainLineNumbers" => null,
			"Core.NormalizeNewlines" => true,
			"Core.ConvertDocumentToFragment" => true,
			"Core.LegacyEntityDecoder" => false,
			"Core.AllowHostnameUnderscore" => false,
			"Core.AllowParseManyTags" => false,
			"Core.DisableExcludes" => false,
			"Core.NormalizedNewlines" => true,
			"Core.EscapeNonASCIICharacters" => false,
			"Core.ColorKeywords" => dict[
				"aliceblue" => "#F0F8FF",
				"antiquewhite" => "#FAEBD7",
				"aqua" => "#00FFFF",
				"aquamarine" => "#7FFFD4",
				"azure" => "#F0FFFF",
				"beige" => "#F5F5DC",
				"bisque" => "#FFE4C4",
				"black" => "#000000",
				"blanchedalmond" => "#FFEBCD",
				"blue" => "#0000FF",
				"blueviolet" => "#8A2BE2",
				"brown" => "#A52A2A",
				"burlywood" => "#DEB887",
				"cadetblue" => "#5F9EA0",
				"chartreuse" => "#7FFF00",
				"chocolate" => "#D2691E",
				"coral" => "#FF7F50",
				"cornflowerblue" => "#6495ED",
				"cornsilk" => "#FFF8DC",
				"crimson" => "#DC143C",
				"cyan" => "#00FFFF",
				"darkblue" => "#00008B",
				"darkcyan" => "#008B8B",
				"darkgoldenrod" => "#B8860B",
				"darkgray" => "#A9A9A9",
				"darkgrey" => "#A9A9A9",
				"darkgreen" => "#006400",
				"darkkhaki" => "#BDB76B",
				"darkmagenta" => "#8B008B",
				"darkolivegreen" => "#556B2F",
				"darkorange" => "#FF8C00",
				"darkorchid" => "#9932CC",
				"darkred" => "#8B0000",
				"darksalmon" => "#E9967A",
				"darkseagreen" => "#8FBC8F",
				"darkslateblue" => "#483D8B",
				"darkslategray" => "#2F4F4F",
				"darkslategrey" => "#2F4F4F",
				"darkturquoise" => "#00CED1",
				"darkviolet" => "#9400D3",
				"deeppink" => "#FF1493",
				"deepskyblue" => "#00BFFF",
				"dimgray" => "#696969",
				"dimgrey" => "#696969",
				"dodgerblue" => "#1E90FF",
				"firebrick" => "#B22222",
				"floralwhite" => "#FFFAF0",
				"forestgreen" => "#228B22",
				"fuchsia" => "#FF00FF",
				"gainsboro" => "#DCDCDC",
				"ghostwhite" => "#F8F8FF",
				"gold" => "#FFD700",
				"goldenrod" => "#DAA520",
				"gray" => "#808080",
				"grey" => "#808080",
				"green" => "#008000",
				"greenyellow" => "#ADFF2F",
				"honeydew" => "#F0FFF0",
				"hotpink" => "#FF69B4",
				"indianred" => "#CD5C5C",
				"indigo" => "#4B0082",
				"ivory" => "#FFFFF0",
				"khaki" => "#F0E68C",
				"lavender" => "#E6E6FA",
				"lavenderblush" => "#FFF0F5",
				"lawngreen" => "#7CFC00",
				"lemonchiffon" => "#FFFACD",
				"lightblue" => "#ADD8E6",
				"lightcoral" => "#F08080",
				"lightcyan" => "#E0FFFF",
				"lightgoldenrodyellow" => "#FAFAD2",
				"lightgray" => "#D3D3D3",
				"lightgrey" => "#D3D3D3",
				"lightgreen" => "#90EE90",
				"lightpink" => "#FFB6C1",
				"lightsalmon" => "#FFA07A",
				"lightseagreen" => "#20B2AA",
				"lightskyblue" => "#87CEFA",
				"lightslategray" => "#778899",
				"lightslategrey" => "#778899",
				"lightsteelblue" => "#B0C4DE",
				"lightyellow" => "#FFFFE0",
				"lime" => "#00FF00",
				"limegreen" => "#32CD32",
				"linen" => "#FAF0E6",
				"magenta" => "#FF00FF",
				"maroon" => "#800000",
				"mediumaquamarine" => "#66CDAA",
				"mediumblue" => "#0000CD",
				"mediumorchid" => "#BA55D3",
				"mediumpurple" => "#9370DB",
				"mediumseagreen" => "#3CB371",
				"mediumslateblue" => "#7B68EE",
				"mediumspringgreen" => "#00FA9A",
				"mediumturquoise" => "#48D1CC",
				"mediumvioletred" => "#C71585",
				"midnightblue" => "#191970",
				"mintcream" => "#F5FFFA",
				"mistyrose" => "#FFE4E1",
				"moccasin" => "#FFE4B5",
				"navajowhite" => "#FFDEAD",
				"navy" => "#000080",
				"oldlace" => "#FDF5E6",
				"olive" => "#808000",
				"olivedrab" => "#6B8E23",
				"orange" => "#FFA500",
				"orangered" => "#FF4500",
				"orchid" => "#DA70D6",
				"palegoldenrod" => "#EEE8AA",
				"palegreen" => "#98FB98",
				"paleturquoise" => "#AFEEEE",
				"palevioletred" => "#DB7093",
				"papayawhip" => "#FFEFD5",
				"peachpuff" => "#FFDAB9",
				"peru" => "#CD853F",
				"pink" => "#FFC0CB",
				"plum" => "#DDA0DD",
				"powderblue" => "#B0E0E6",
				"purple" => "#800080",
				"rebeccapurple" => "#663399",
				"red" => "#FF0000",
				"rosybrown" => "#BC8F8F",
				"royalblue" => "#4169E1",
				"saddlebrown" => "#8B4513",
				"salmon" => "#FA8072",
				"sandybrown" => "#F4A460",
				"seagreen" => "#2E8B57",
				"seashell" => "#FFF5EE",
				"sienna" => "#A0522D",
				"silver" => "#C0C0C0",
				"skyblue" => "#87CEEB",
				"slateblue" => "#6A5ACD",
				"slategray" => "#708090",
				"slategrey" => "#708090",
				"snow" => "#FFFAFA",
				"springgreen" => "#00FF7F",
				"steelblue" => "#4682B4",
				"tan" => "#D2B48C",
				"teal" => "#008080",
				"thistle" => "#D8BFD8",
				"tomato" => "#FF6347",
				"turquoise" => "#40E0D0",
				"violet" => "#EE82EE",
				"wheat" => "#F5DEB3",
				"white" => "#FFFFFF",
				"whitesmoke" => "#F5F5F5",
				"yellow" => "#FFFF00",
				"yellowgreen" => "#9ACD32",
			],
			"CSS.AllowedFonts" => dict[],
			"Attr.IDBlacklist" => vec<string>[],
			"HTML.Trusted" => false,
			"HTML.AllowedModules" => dict[],
			"HTML.CoreModules" => dict[
				'Structure' => true,
				'Text' => true,
				'Hypertext' => true,
				'List' => true,
				'NonXMLCommonAttributes' => true,
				'XMLCommonAttributes' => true,
				'CommonAttributes' => true,
			],
			"HTML.Allowed" => '',
			"HTML.AllowedComments" => vec<string>[],
			"HTML.AllowedElements" => dict[],
			"HTML.AllowedAttributes" => dict[],
			"HTML.BlockWrapper" => 'p',
			"HTML.Parent" => 'div',
			"HTML.Doctype" => '',
			"HTML.XHTML" => false,
			"HTML.Strict" => false,
			"HTML.Proprietary" => false,
			"HTML.SafeObject" => false,
			"HTML.SafeEmbed" => false,
			"HTML.SafeScripting" => dict[],
			"HTML.SafeIframe" => false,
			"HTML.Nofollow" => false,
			"HTML.TargetBlank" => false,
			"HTML.TargetNoreferrer" => true,
			"HTML.TargetNoopener" => true,
			"HTML.CustomDoctype" => '',
			"HTML.AllowedCommentsRegexp" => '',
			"HTML.Attr.Name.UseCDATA" => false,
			"HTML.DefinitionID" => '',
			"HTML.FlashAllowFullScreen" => false,
			"HTML.ForbiddenAttributes" => dict[],
			"HTML.ForbiddenElements" => dict[],
			"HTML.MaxImgLength" => 1200,
			"HTML.TidyAdd" => dict[],
			"HTML.TidyLevel" => 'medium',
			"HTML.TidyRemove" => dict[],
			"Cache.DefinitionImpl" => 'Serializer',
			"Output.CommentScriptContents" => true,
			"Output.FixInnerHTML" => true,
			"Output.SortAttr" => false,
			"Output.FlashCompat" => false,
			"Output.Newline" => '',
			"Output.TidyFormat" => false,
			"HTML.DefinitionRev" => 1,
			"Cache.SerializerPath" => '',
			"Cache.SerializerPermissions" => 0,
			"AutoFormat.AutoParagraph" => false,
			"AutoFormat.Custom" => vec[],
			"AutoFormat.DisplayLinkURI" => false,
			"AutoFormat.Linkify" => false,
			"AutoFormat.PurifierLinkify.DocURL" => '#%s',
			"AutoFormat.PurifierLinkify" => false,
			"AutoFormat.RemoveEmpty" => false,
			"AutoFormat.RemoveEmpty.RemoveNbsp" => false,
			"AutoFormat.RemoveEmpty.RemoveNbsp.Exceptions" => dict['td' => true, 'th' => true],
			"AutoFormat.RemoveEmpty.Predicate" => dict[
				'colgroup' => vec[],
				'th' => vec[],
				'td' => vec[],
				'iframe' => vec['src'],
			],
			"AutoFormat.RemoveSpansWithoutAttributes" => false,
			"URI.AllowedSchemes" => vec['http', 'https', 'mailto', 'ftp', 'nntp', 'news', 'tel'],
			"URI.OverrideAllowedSchemes" => true,
			"CSS.AllowDuplicates" => false,
			"CSS.AllowTricky" => false,
			"CSS.AllowImportant" => false,
			"CSS.AllowedProperties" => dict[],
			"CSS.ForbiddenProperties" => dict[],
			"CSS.Proprietary" => false,
			"CSS.Trusted" => false,
			"CSS.DefinitionRev" => 1,
			"CSS.MaxImgLength" => '1200px',
			"Attr.EnableID" => false,
			"Attr.IDPrefixLocal" => '',
			"Attr.IDPrefix" => '',
			"Attr.ID.HTML5" => false,
			"Attr.IDlocklistRegexp" => '',
			"Attr.AllowedClasses" => dict[],
			"Attr.ForbiddenClasses" => dict[],
			"Attr.AllowedFrameTargets" => vec[],
			"Attr.AllowedRel" => dict["noopener" => true, "noreferrer" => true],
			"Attr.AllowedRev" => dict[],
			"Attr.ClassUseCDATA" => null,
			"Attr.DefaultImageAlt" => '',
			"Attr.DefaultInvalidImage" => '',
			"Attr.DefaultInvalidImageAlt" => 'Invalid Image',
			"Attr.DefaultTextDir" => 'ltr',
			"Attr.IDBlocklistRegexp" => '',
			"Attr.IDBlocklist" => vec[],
			"URI.Disable" => false,
			"URI.Host" => '',
			"URI.Base" => '',
			"URI.SafeIframeRegexp" => '',
			"URI.DefaultScheme" => 'http',
			"URI.DefinitionRev" => 1,
			"URI.Munge" => '',
			"URI.MungeResources" => false,
			"URI.MungeSecretKey" => '',
			"URI.DisableExternal" => false,
			"URI.DisableExternalResources" => false,
			"URI.DisableResources" => false,
			"URI.HostBlocklist" => vec[],
			"URI.MakeAbsolute" => false,
			"URI.DefinitionID" => '',
			"Test.ForceNoIconv" => false,
		);
	}

	public static function makeFromSerial(): HTMLPurifier_ConfigSchema {
		return new HTMLPurifier_ConfigSchema();
	}

	public function instance(?HTMLPurifier_ConfigSchema $prototype = null): HTMLPurifier_ConfigSchema {
		if ($prototype) {
			$this->singleton = $prototype;
		} else if ($this->singleton is null) {
			$this->singleton = HTMLPurifier_ConfigSchema::makeFromSerial();
		}
		return $this->singleton;
	}
}
