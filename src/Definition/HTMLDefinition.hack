/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Definition;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, ChildDef};
use namespace HTMLPurifier\AttrDef\HTML;
use namespace HH\Lib\{C, Str};

/**
 * Definition of the purified HTML that describes allowed children,
 * attributes, and many other things.
 *
 * Conventions:
 *
 * All member variables that are prefixed with info
 * (including the main $info array) are used by HTML Purifier internals
 * and should not be directly edited when customizing the HTMLDefinition.
 * They can usually be set via configuration directives or custom
 * modules.
 *
 * On the other hand, member variables without the info prefix are used
 * internally by the HTMLDefinition and MUST NOT be used by other HTML
 * Purifier internals. Many of them, however, are public, and may be
 * edited by userspace code to tweak the behavior of HTMLDefinition.
 *
 * @note This class is inspected by Printer_HTMLDefinition; please
 *       update that class if things here change.
 *
 * @warning Directives that change this object's structure must be in
 *          the HTML or Attr namespace!
 */
class HTMLPurifier_HTMLDefinition extends HTMLPurifier\HTMLPurifier_Definition {
    public dict<string, HTMLPurifier\HTMLPurifier_ElementDef> $info = dict[];
    public string $info_parent = 'div';
    public string $info_block_wrapper = 'p';
    public dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info_global_attr = dict[];
    public ?HTMLPurifier\HTMLPurifier_ElementDef $info_parent_def;
    public vec<HTMLPurifier\HTMLPurifier_AttrTransform> $info_attr_transform_pre = vec[];
    public vec<HTMLPurifier\HTMLPurifier_AttrTransform> $info_attr_transform_post = vec[];
    //public dict<string, HTMLPurifier\HTMLPurifier_TagTransform> $info_tag_transform = dict[];
    public dict<string, dict<string, bool>> $info_content_sets = dict[];
    public dict<string, HTMLPurifier\HTMLPurifier_Injector> $info_injector = dict[];
    public HTMLPurifier\HTMLPurifier_HTMLModuleManager $manager;
    public ?HTMLPurifier\HTMLPurifier_HTMLModule $anonModule;
    public ?HTMLPurifier\HTMLPurifier_Doctype $doctype;
    public function __construct() {
        $this->doctype = new HTMLPurifier\HTMLPurifier_Doctype('', false);

        $alt_child_elements = dict[
            "h1" => true,
            "h2" => true,
            "h3" => true,
            "h4" => true,
            "h5" => true,
            "h6" => true,
            "address" => true,
            "blockquote" => true,
            "pre" => true,
            "p" => true,
            "div" => true,
            "hr" => true,
            "table" => true,
            "script" => true,
            "noscript" => true,
            "center" => true,
            "dir" => true,
            "menu" => true,
            "abbr" => true,
            "acronym" => true,
            "cite" => true,
            "dfn" => true,
            "kbd" => true,
            "q" => true,
            "samp" => true,
            "var" => true,
            "em" => true,
            "strong" => true,
            "code" => true,
            "span" => true,
            "br" => true,
            "a" => true,
            "sub" => true,
            "sup" => true,
            "b" => true,
            "big" => true,
            "i" => true,
            "small" => true,
            "tt" => true,
            "del" => true,
            "ins" => true,
            "bdo" => true,
            "img" => true,
            "object" => true,
            "basefont" => true,
            "font" => true,
            "s" => true,
            "strike" => true,
            "u" => true,
            "iframe" => true,
            "ol" => true,
            "ul" => true,
            "dl" => true,
            "form" => true,
            "fieldset" => true,
            "input" => true,
            "select" => true,
            "textarea" => true,
            "button" => true,
            "label" => true,
            "#PCDATA" => true,
            "aside" => true
        ];

        $this->manager = new HTMLPurifier\HTMLPurifier_HTMLModuleManager();

        $abbr_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
            null, '', true, vec[], vec[], vec[], '', false);
        $this->info["abbr"] = $abbr_element;

        $acronym_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["acronym"] = $acronym_element;

        $dfn_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["dfn"] = $dfn_element;

        $kbd_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["kbd"] = $kbd_element;

        $q_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["cite" => new AttrDef\HTMLPurifier_AttrDef_URI()], 
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["q"] = $q_element;

        $samp_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["samp"] = $samp_element;

        $samp_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["cite"] = $samp_element;
        
        $var_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["var"] = $var_element;

        $em_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["em"] = $em_element;

        $strong_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["strong"] = $strong_element;

        $code_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["code"] = $code_element;

        $span_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["span"] = $span_element;

        $br_drop_attr = vec["lang", "xml:lang", "dir"];
        $br_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["clear" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "all", "right", "none"])], 
                    $br_drop_attr, vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["br"] = $br_element;

        $address_child_elements = dict[
            "abbr" => true,
            "acronym" => true,
            "cite" => true,
            "dfn" => true,
            "kbd" => true,
            "q" => true,
            "samp" => true,
            "var" => true,
            "em" => true,
            "strong" => true,
            "code" => true,
            "span" => true,
            "br" => true,
            "a" => true,
            "sub" => true,
            "sup" => true,
            "b" => true,
            "big" => true,
            "i" => true,
            "small" => true,
            "tt" => true,
            "del" => true,
            "ins" => true,
            "bdo" => true,
            "img" => true,
            "script" => true,
            "noscript" => true,
            "object" => true,
            "basefont" => true,
            "font" => true,
            "s" => true,
            "strike" => true,
            "u" => true,
            "iframe" => true,
            "input" => true,
            "select" => true,
            "textarea" => true,
            "button" => true,
            "label" => true,
            "#PCDATA" => true,
            "p" => true
        ];
        $address_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional($address_child_elements),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["address"] = $address_element;

        $blockquote_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["width" => new AttrDef\HTMLPurifier_AttrDef_Integer()], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements),
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["blockquote"] = $blockquote_element;

        $pre_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["cite" => new AttrDef\HTMLPurifier_AttrDef_URI()], 
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["pre"] = $pre_element;

        $h1_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h1"] = $h1_element;

        $h2_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h2"] = $h2_element;

        $h3_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h3"] = $h3_element;

        $h4_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h4"] = $h4_element;

        $h5_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h5"] = $h5_element;

        $h6_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["h6"] = $h6_element;

        $p_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"])],
            vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["p"] = $p_element;

        $a_add_attr = dict[
            "name" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "rev" => new HTML\HTMLPurifier_AttrDef_HTML_LinkTypes("rev"),
            "rel" => new HTML\HTMLPurifier_AttrDef_HTML_LinkTypes("rel"),
            "target" => new HTML\HTMLPurifier_AttrDef_HTML_FrameTarget(vec["_blank"]),
            "href" => new AttrDef\HTMLPurifier_AttrDef_URI()
        ];
        $a_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $a_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec['a'], vec[], '', true);
        $this->info["a"] = $a_element;

        $ol_add_attr = dict[
            "compact" => new HTML\HTMLPurifier_AttrDef_HTML_Bool(),
            "start" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
            "type" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["1", "i", "I", "a", "A"])
        ];
        $ol_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $ol_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_List(),
                    null, '', false, vec[], vec[], vec[], 'li', false);
        $this->info["ol"] = $ol_element;

        $ul_add_attr = dict[
            "compact" => new HTML\HTMLPurifier_AttrDef_HTML_Bool(),
            "type" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["square", "disc", "circle"])
        ];
        $ul_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $ul_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_List(),
                    null, '', false, vec[], vec[], vec[], 'li', false);
        $this->info["ul"] = $ul_element;

        $dl_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["compact" => new HTML\HTMLPurifier_AttrDef_HTML_Bool()], 
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Required(dict["dt" => true, "dd" => true]), 
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["dl"] = $dl_element;

        $li_add_attr = dict[
            "type" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["1", "i", "I", "a", "A", "square", "disc", "circle"]),
            "value" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
        ];
        $li_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $li_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements),
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["li"] = $li_element;

        $dd_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements),
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["dd"] = $dd_element;

        $dt_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["dt"] = $dt_element;

        $hr_add_attr = dict[
            "noshade" => new HTML\HTMLPurifier_AttrDef_HTML_Bool(),
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "right", "center", "justify"]),
            "width" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
            "size" => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $hr_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $hr_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Empty(),
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["hr"] = $hr_element;

        $sub_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["sub"] = $sub_element;

        $sup_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["sup"] = $sup_element;

        $b_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), 
                    null, '', false, vec[], vec[], vec[], '', true);
        $this->info["b"] = $b_element;

        $big_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["big"] = $big_element;

        $i_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["i"] = $i_element;

        $small_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["small"] = $small_element;

        $tt_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', true);
        $this->info["tt"] = $tt_element;
        
        $ins_child_element = new ChildDef\HTMLPurifier_ChildDef_Chameleon(new ChildDef\HTMLPurifier_ChildDef_Optional(), new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements));
        $ins_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["cite" => new AttrDef\HTMLPurifier_AttrDef_URI()],
                    vec[], vec[], vec[], $ins_child_element, null, '', false, vec[], vec[], vec[], '', false);
        $this->info["ins"] = $ins_element;

        $bdo_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(),
                    null, '', true, vec[], vec[], vec[], '', false);
        $this->info["bdo"] = $bdo_element;

        $caption_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "bottom", "left", "right"])],
                    vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["caption"] = $caption_element;
        
        $table_add_attr = dict[
            "rules" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["none", "groups", "rows", "cols", "all"]),
            "border" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "frame" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "bgcolor" => new HTML\HTMLPurifier_AttrDef_HTML_Color(),
            "summary" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right"]),
            "width" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
            "cellpadding" => new HTML\HTMLPurifier_AttrDef_HTML_Length(),
            "cellspacing" => new HTML\HTMLPurifier_AttrDef_HTML_Length()
        ];
        $table_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $table_add_attr, vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Table(),
                    null, '', false, vec[], vec[], vec[], '', false);
        $this->info["table"] = $table_element;

        $b_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), 
                        null, '', true, vec[], vec[], vec[], '', true);
        $this->info["b"] = $b_element;

        $div_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"])], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["div"] = $div_element;

        $aside_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["aside"] = $aside_element;

        $del_child_element = new ChildDef\HTMLPurifier_ChildDef_Chameleon(new ChildDef\HTMLPurifier_ChildDef_Optional(), new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements));
        $del_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["cite" => new AttrDef\HTMLPurifier_AttrDef_URI()], vec[], vec[], vec[], 
            $del_child_element, null, '', false, vec[], vec[], vec[], '', false);
        $this->info["del"] = $del_element;

        $img_add_attr = dict[
            "src" => new AttrDef\HTMLPurifier_AttrDef_URI(),
            "name" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "hspace" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "left", "right"]),
            "width" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(1200),
            "vspace" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "longdesc" => new AttrDef\HTMLPurifier_AttrDef_URI(),
            "alt" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "border" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "height" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(1200),
            "srcset" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "sizes" => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $img_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $img_add_attr, vec[], vec[], vec[], 
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', false, vec["alt", "src"], vec[],
            vec[], '', false);
        $this->info["img"] = $img_element;

        $td_add_attr = dict[
                            'abbr' => new AttrDef\HTMLPurifier_AttrDef_Text(),
                            'colspan' => new AttrDef\HTMLPurifier_AttrDef_Integer(false, false),
                            'rowspan' => new AttrDef\HTMLPurifier_AttrDef_Integer(false, false),
                            'scope' => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["row", "col", "rowgroup", "colgroup"]),
                            'align' => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
                            'valign' => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"]),
                            'title' => new AttrDef\HTMLPurifier_AttrDef_Text(),
                            'style' => new AttrDef\HTMLPurifier_AttrDef_CSS(),
                            'dir' => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["ltr", "rtl"]),
                            'xml:lang' => new AttrDef\HTMLPurifier_AttrDef_Lang(),
                            'lang' => new AttrDef\HTMLPurifier_AttrDef_Lang()
                        ];
        $td_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $td_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["td"] = $td_element;

        $tr_add_attr = dict[
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
            "bgcolor" => new HTML\HTMLPurifier_AttrDef_HTML_Color(),
            "charoff" => new HTML\HTMLPurifier_AttrDef_HTML_Length(),
            "valign" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"])
        ];
        $tr_element = new HTMLPurifier\HTMLPurifier_ElementDef(true,  $tr_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["td"=>true, "th"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["tr"] = $tr_element;

        $th_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $td_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["th"] = $th_element;

        $col_add_attr = dict[
            "span" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
            "valign" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"]),
            "charoff" => new HTML\HTMLPurifier_AttrDef_HTML_Length(),
            "width" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
        ];
        $col_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $col_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["col"] = $col_element;

        $colgroup_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $col_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(dict["col"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["colgroup"] = $colgroup_element;

        $tbody_add_attr = dict[
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
            "charoff" => new HTML\HTMLPurifier_AttrDef_HTML_Length(),
            "valign" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"])
        ];
        $tbody_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $tbody_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["tr"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["tbody"] = $tbody_element;

        $thead_add_attr = dict[
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
            "valign" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"]),
            "charoff" => new HTML\HTMLPurifier_AttrDef_HTML_Length()
        ];
        $thead_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $thead_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["tr"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["thead"] = $thead_element;

        $tfoot_add_attr = dict[
            "charoff" => new HTML\HTMLPurifier_AttrDef_HTML_Length(),
            "align" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["left", "center", "right", "justify", "char"]),
            "valign" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["top", "middle", "bottom", "baseline"])
        ];
        $tfoot_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $tfoot_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["tr"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["tfoot"] = $tfoot_element;
        
        $basefont_add_attr = dict[
            "color" => new HTML\HTMLPurifier_AttrDef_HTML_Color(),
            "face" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "size" => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $basefont_drop_attr = vec["lang", "style", "title", "xml:lang", "class", "dir"];
        $basefont_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $basefont_add_attr, $basefont_drop_attr, vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["basefont"] = $basefont_element;

        $center_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["center"] = $center_element;

        $dir_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["compact" => new HTML\HTMLPurifier_AttrDef_HTML_Bool()],
            vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Required(dict["li"=>true]), null, '', false, vec[], vec[], vec[], '', false);
        $this->info["dir"] = $dir_element;

        $font_add_attr = dict[
            "color" => new HTML\HTMLPurifier_AttrDef_HTML_Color(),
            "face" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "size" => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $font_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $font_add_attr, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["font"] = $font_element;

        $menu_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["compact" => new HTML\HTMLPurifier_AttrDef_HTML_Bool()],
             vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Required(dict["li"=>true]), 
             null, '', false, vec[], vec[], vec[], '', false);
        $this->info["menu"] = $menu_element;

        $s_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["s"] = $s_element;

        $strike_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["strike"] = $strike_element;

        $u_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["u"] = $u_element;

        $iframe_add_attr = dict[
            "width" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "height" => new HTML\HTMLPurifier_AttrDef_HTML_Pixels(),
            "src" => new AttrDef\HTMLPurifier_AttrDef_URI(),
            "title" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "allowfullscreen" => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $iframe_drop_attr = vec["lang", "xml:lang", "class", "style", "dir","id"];
        $iframe_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $iframe_add_attr, $iframe_drop_attr, vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["iframe"] = $iframe_element;

        $article_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["article"] = $article_element;

        $nav_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["nav"] = $nav_element;

        $section_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["section"] = $section_element;

        $header_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec["header", "footer", "main"], vec[], '', false);
        $this->info["header"] = $header_element;

        $footer_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec["header", "footer", "main"], vec[], '', false);
        $this->info["footer"] = $footer_element;

        $hgroup_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["h1" => true, "h2" => true, "h3" => true, "h4" => true, "h5" => true, "h6" => true]), null,
            'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["hgroup"] = $hgroup_element;

        $main_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["main"] = $main_element;

        $figcaption_element = new HTMLPurifier\HTMLPurifier_ElementDef(false, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["figcaption"] = $figcaption_element;

        $mark_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Inline | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["mark"] = $mark_element;

        $wbr_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["wbr"] = $wbr_element;

        $audio_add_attrs = dict[
            "controls" => new AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Bool("controls"),
            "preload" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["auto", "metadata", "none"]),
            "src" => new AttrDef\HTMLPurifier_AttrDef_URI()
        ];
        $audio_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $audio_add_attrs, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec["source", "track"], vec[], vec[], '', false);
        $this->info["audio"] = $audio_element;

        $source_add_attrs = dict[
            "media"  => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "sizes"  => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "src"    => new AttrDef\HTMLPurifier_AttrDef_URI(),
            "srcset" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "type"   => new AttrDef\HTMLPurifier_AttrDef_Text()
        ];
        $source_element = new HTMLPurifier\HTMLPurifier_ElementDef(false, $source_add_attrs, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["source"] = $source_element;

        $track_add_attrs = dict[
            "kind" => new AttrDef\HTMLPurifier_AttrDef_Enum(vec["captions", "chapters", "descriptions", "metadata", "subtitles"]),
            "src" => new AttrDef\HTMLPurifier_AttrDef_URI(),
            "srclang" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "lang" => new AttrDef\HTMLPurifier_AttrDef_Text(),
            "default" => new AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Bool("default")
        ];
        $track_element = new HTMLPurifier\HTMLPurifier_ElementDef(false, $track_add_attrs, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Empty(), null, '', true, vec[], vec[], vec[], '', false);
        $this->info["track"] = $track_element;

        $picture_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Required(dict["img" => true]), null,
            'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["picture"] = $picture_element;

        $progress_add_attrs = dict[
            "value" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
            "max" => new AttrDef\HTMLPurifier_AttrDef_Integer(),
        ];
        $progress_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, $progress_add_attrs, vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["progress"] = $progress_element;

        $summary_element = new HTMLPurifier\HTMLPurifier_ElementDef(false, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["summary"] = $summary_element;

        $dialog_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict["open" => new AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Bool("open")], 
            vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Flow | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["dialog"] = $dialog_element;

        $bdi_element = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[],
            new ChildDef\HTMLPurifier_ChildDef_Optional(), null, 'Inline | #PCDATA', true, vec[], vec[], vec[], '', false);
        $this->info["bdi"] = $bdi_element;

        $this->info_parent_def = new HTMLPurifier\HTMLPurifier_ElementDef(true, dict[], vec[], vec[], vec[], new ChildDef\HTMLPurifier_ChildDef_Optional($alt_child_elements),
                                null, "optional", false, vec[], vec[], vec[], '', false);

        $block_info = dict[
                        "address" => true,
                        "blockquote" => true,
                        "pre" => true,
                        "p" => true,
                        "div" => true,
                        "hr" => true,
                        "table" => true,
                        "script" => true,
                        "noscript" => true,
                        "center" => true,
                        "dir" => true,
                        "menu" => true,
                        "form" => true,
                        "fieldset" => true
                    ];
        $this->info_content_sets['Block'] = $block_info;

    }  


    // RAW CUSTOMIZATION STUFF --------------------------------------------

    /**
     * Adds a custom attribute to a pre-existing element
     * @note This is strictly convenience, and does not have a corresponding
     *       method in HTMLPurifier_HTMLModule
     * @param string $element_name Element name to add attribute to
     * @param string $attr_name Name of attribute
     * @param mixed $def Attribute definition, can be string or object, see
     *             HTMLPurifier_AttrTypes for details
     */
    public function addAttribute(string $element_name, string $attr_name, HTMLPurifier\HTMLPurifier_AttrDef $def): void{
        $module = $this->getAnonymousModule();
        if (!C\contains_key($module->info, $element_name)) {
            $element = $module->addBlankElement($element_name);
        } else {
            $element = $module->info[$element_name];
        }
        $element->attr[$attr_name] = $def;
    }

    /**
     * Adds a blank element to your HTML definition, for overriding
     * existing behavior
     * @param string $element_name
     * @return HTMLPurifier_ElementDef
     * @see HTMLPurifier_HTMLModule::addBlankElement() for detailed
     *       parameter and return value descriptions.
     */
    public function addBlankElement(string $element_name): HTMLPurifier\HTMLPurifier_ElementDef {
        $module  = $this->getAnonymousModule();
        $element = $module->addBlankElement($element_name);
        return $element;
    }

    /**
     * Retrieves a reference to the anonymous module, so you can
     * bust out advanced features without having to make your own
     * module.
     * @return HTMLPurifier_HTMLModule
     */
    public function getAnonymousModule(): HTMLPurifier\HTMLPurifier_HTMLModule {
        if ($this->anonModule is null) {
            $this->anonModule = new HTMLPurifier\HTMLPurifier_HTMLModule('Anonymous');
        }
        return $this->anonModule;
    }

    private ?HTMLPurifier\HTMLPurifier_HTMLModule $_anonModule = null;


    /**
     * @param HTMLPurifier_Config $config
     */
    protected function doSetup(HTMLPurifier\HTMLPurifier_Config $config): void{
        $this->setupConfigStuff($config);
    }


    /**
     * Sets up stuff based on config. We need a better way of doing this.
     * @param HTMLPurifier_Config $config
     */
    protected function setupConfigStuff(HTMLPurifier\HTMLPurifier_Config$config) : void {
        $block_wrapper = $config->def->defaults['HTML.BlockWrapper'];
        if (C\contains_key($this->info_content_sets, 'Block') && C\contains_key($this->info_content_sets['Block'], $block_wrapper) && $this->info_content_sets['Block'][$block_wrapper] is nonnull) {
            $this->info_block_wrapper = $block_wrapper;
        } else {
            throw new \Error(
                'Cannot use non-block element as block wrapper',
                \E_USER_ERROR
            );
        }


        // support template text
        $support = "at the moment. Please implement the element you would like to support, and add the element to the HTMLDefinition constructor.";

        // setup allowed elements -----------------------------------------

        $allowed_elements = $config->def->defaults['HTML.AllowedElements'];
        $allowed_attributes = $config->def->defaults['HTML.AllowedAttributes']; // retrieve early

        if ($allowed_elements is dict<_,_> && C\is_empty($allowed_elements) &&
            $allowed_attributes is dict<_,_> && C\is_empty($allowed_attributes)) {
            $allowed = (string)$config->def->defaults['HTML.Allowed'];
            if ($allowed !== '') {
                list($allowed_elements, $allowed_attributes) = $this->parseTinyMCEAllowedList($allowed);
            }
        }

        if ($allowed_elements is dict<_, _> && !C\is_empty($allowed_elements)) {
            foreach ($this->info as $name => $d) {
                if (!C\contains_key($allowed_elements, $name)) {
                    unset($this->info[$name]);
                }
                unset($allowed_elements[$name]);
            }
            // emit errors
            foreach ($allowed_elements as $element => $d) {
                if ($element is string) {
                    $element = \htmlspecialchars($element); // PHP doesn't escape errors, be careful!
                    throw new \Error("Element '$element' is not supported $support", \E_USER_WARNING);
                }
            }
        }

        // setup allowed attributes ---------------------------------------

        $allowed_attributes_mutable = $allowed_attributes; // by copy!
        if ($allowed_attributes is dict<_, _> && !C\is_empty($allowed_attributes) &&
            $allowed_attributes_mutable is dict<_, _> && !C\is_empty($allowed_attributes_mutable)) {
            // This actually doesn't do anything, since we went away from
            // global attributes. It's possible that userland code uses
            // it, but HTMLModuleManager doesn't!
            foreach ($this->info_global_attr as $attr => $x) {
                $keys = vec[$attr, "*@$attr", "*.$attr"];
                $delete = true;
                foreach ($keys as $key) {
                    if ($delete && C\contains_key($allowed_attributes, $key) && 
                        $allowed_attributes[$key] is nonnull) {
                        $delete = false;
                    }
                    if (C\contains_key($allowed_attributes_mutable, $key) &&
                        $allowed_attributes_mutable[$key] is nonnull) {
                        unset($allowed_attributes_mutable[$key]);
                    }
                }
                if ($delete) {
                    unset($this->info_global_attr[$attr]);
                }
            }

            foreach ($this->info as $tag => $info) {
                foreach ($info->attr as $attr => $x) {
                    $keys = vec["$tag@$attr", $attr, "*@$attr", "$tag.$attr", "*.$attr"];
                    $delete = true;
                    foreach ($keys as $key) {
                        if ($delete && C\contains_key($allowed_attributes, $key)) {
                            $delete = false;
                        }
                        if (C\contains_key($allowed_attributes_mutable, $key)) {
                            unset($allowed_attributes_mutable[$key]);
                        }
                    }
                    if ($delete) {
                        if ($this->info[$tag]->attr[$attr]->required) {
                            throw new \Error(
                                "Required attribute '$attr' in element '$tag' " .
                                "was not allowed, which means '$tag' will not be allowed either",
                                \E_USER_WARNING
                            );
                        }
                        unset($this->info[$tag]->attr[$attr]);
                    }
                }
            }
            // emit errors
            foreach ($allowed_attributes_mutable as $elattr => $d) {
                $bits = \preg_split('/[.@]/', (string)$elattr, 2);
                $c = C\count($bits);
                switch ($c) {
                    case 2:
                        if ($bits[0] !== '*') {
                            $element = \htmlspecialchars($bits[0]);
                            $attribute = \htmlspecialchars($bits[1]);
                            if ($this->info[$element] is null) {
                                throw new \Error(
                                    "Cannot allow attribute '$attribute' if element " .
                                    "'$element' is not allowed/supported $support"
                                );
                            } else {
                                throw new \Error(
                                    "Attribute '$attribute' in element '$element' not supported $support",
                                    \E_USER_WARNING
                                );
                            }
                            break;
                        }
                        // FALLTHROUGH
                    case 1:
                        $attribute = \htmlspecialchars($bits[0]);
                        throw new \Error(
                            "Global attribute '$attribute' is not ".
                            "supported in any elements $support",
                           \E_USER_WARNING
                        );
                        break;
                }
            }
        }

        
        // setup injectors -----------------------------------------------------
        foreach ($this->info_injector as $i => $injector) {
            // if ($injector->checkNeeded($config) !== false) {
            //     // remove injector that does not have it's required
            //     // elements/attributes present, and is thus not needed.
            //     unset($this->info_injector[$i]);
            // }
        }
    }

    // /**
    //  * Parses a TinyMCE-flavored Allowed Elements and Attributes list into
    //  * separate lists for processing. Format is element[attr1|attr2],element2...
    //  * @warning Although it's largely drawn from TinyMCE's implementation,
    //  *      it is different, and you'll probably have to modify your lists
    //  */
    public function parseTinyMCEAllowedList(string $list) : vec<dict<string, bool>> {
        $list = Str\replace_every($list, dict[' ' => '', "\t" => '']);

        $elements = dict[];
        $attributes = dict[];

        $chunks = \preg_split('/(,|[\n\r]+)/', $list);
        foreach ($chunks as $chunk) {
            if ($chunk is null) {
                continue;
            }
            // remove TinyMCE element control characters
            if (!Str\search($chunk, '[')) {
                $element = $chunk;
                $attr = '';
            } else {
                list($element, $attr) = Str\split($chunk, '[');
            }
            if ($element !== '*') {
                $elements[$element] = true;
            }
            if (!$attr) {
                continue;
            }
            $attr = Str\slice($attr, 0, Str\length($attr) - 1); // remove trailing ]
            $attr = Str\split($attr, '|');
            foreach ($attr as $key) {
                $attributes["$element.$key"] = true;
            }
        }
        return vec[$elements, $attributes];
    }
}
