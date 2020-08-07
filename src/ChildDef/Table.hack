/* Created by Jacob Polacek on 07/07/2020 */

namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;
use namespace HH\Lib\{C, Vec};

/**
 * Definition for tables.  The general idea is to extract out all of the
 * essential bits, and then reconstruct it later.
 *
 * This is a bit confusing, because the DTDs and the W3C
 * validators seem to disagree on the appropriate definition. The
 * DTD claims:
 *
 *      (CAPTION?, (COL*|COLGROUP*), THEAD?, TFOOT?, TBODY+)
 *
 * But actually, the HTML4 spec then has this to say:
 *
 *      The TBODY start tag is always required except when the table
 *      contains only one table body and no table head or foot sections.
 *      The TBODY end tag may always be safely omitted.
 *
 * So the DTD is kind of wrong.  The validator is, unfortunately, kind
 * of on crack.
 *
 * The definition changed again in XHTML1.1; and in my opinion, this
 * formulation makes the most sense.
 *
 *      caption?, ( col* | colgroup* ), (( thead?, tfoot?, tbody+ ) | ( tr+ ))
 *
 * Essentially, we have two modes: thead/tfoot/tbody mode, and tr mode.
 * If we encounter a thead, tfoot or tbody, we are placed in the former
 * mode, and we *must* wrap any stray tr segments with a tbody. But if
 * we don't run into any of them, just have tr tags is OK.
 */
class HTMLPurifier_ChildDef_Table extends HTMLPurifier\HTMLPurifier_ChildDef {
    public bool $allow_empty = false;

    public string $type = 'table';

    public dict<string, bool> $elements = dict[
        'tr' => true,
        'tbody' => true,
        'thead' => true,
        'tfoot' => true,
        'caption' => true,
        'colgroup' => true,
        'col' => true
    ];

    public function __construct()
    {
    }

    /**
     * @param array $children
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return array
     */
    public function validateChildren(vec<HTMLPurifier\HTMLPurifier_Node> $children, 
        HTMLPurifier\HTMLPurifier_Config $_config, HTMLPurifier\HTMLPurifier_Context $_context) : 
        (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
        if (C\count($children) == 0) {
            return tuple(false, vec[]);
        }

        // only one of these elements is allowed in a table
        $caption = null;
        $thead = null;
        $tfoot = null;

        // whitespace
        $initial_ws = vec[];
        $after_caption_ws = vec[];
        $after_thead_ws = vec[];
        $after_tfoot_ws = vec[];

        $accum_dict = dict[
            "initial_ws" => vec<HTMLPurifier\HTMLPurifier_Node>[],
            "after_caption_ws" => vec[],
            "after_thead_ws" => vec[],
            "after_tfoot_ws" => vec[],
            "cols" => vec[],
            "content" => vec<HTMLPurifier\HTMLPurifier_Node>[]
        ];

        // as many of these as you want
        $cols = vec[];
        $content = vec[];

        $tbody_mode = false; // if true, then we need to wrap any stray
                             // <tr>s with a <tbody>.

        $ws_accum = $initial_ws;

        $current_key = 'initial_ws';
        foreach ($children as $node) {
            if ($node is Node\HTMLPurifier_Node_Comment) {
                $accum_dict[$current_key][] = $node;
                continue;
            }
            if ($node is Node\HTMLPurifier_Node_Element || $node is Node\HTMLPurifier_Node_Text) {
                switch ($node->name) {
                case 'tbody':
                    $tbody_mode = true;
                    // FALLTHROUGH
                case 'tr':
                    $current_key = "content";
                    $accum_dict[$current_key][] = $node;
                    break;
                case 'caption':
                    // there can only be one caption!
                    if ($caption is nonnull)  break;
                    $caption = $node;
                    $current_key = "after_caption_ws";
                    break;
                case 'thead':
                    $tbody_mode = true;
                    // XXX This breaks rendering properties with
                    // Firefox, which never floats a <thead> to
                    // the top. Ever. (Our scheme will float the
                    // first <thead> to the top.)  So maybe
                    // <thead>s that are not first should be
                    // turned into <tbody>? Very tricky, indeed.
                    if ($thead is null) {
                        $thead = $node;
                        $current_key = "after_thead_ws";
                    } else {
                        // Oops, there's a second one! What
                        // should we do?  Current behavior is to
                        // transmutate the first and last entries into
                        // tbody tags, and then put into content.
                        // Maybe a better idea is to *attach
                        // it* to the existing thead or tfoot?
                        // We don't do this, because Firefox
                        // doesn't float an extra tfoot to the
                        // bottom like it does for the first one.
                        $node->name = 'tbody';
                        $current_key = "content";
                        $accum_dict[$current_key][] = $node;
                    }
                    break;
                case 'tfoot':
                    // see above for some aveats
                    $tbody_mode = true;
                    if ($tfoot is null) {
                        $tfoot = $node;
                        $current_key = "after_tfoot_ws";
                    } else {
                        $node->name = 'tbody';
                        $current_key = "content";
                        $accum_dict[$current_key][] = $node;
                    }
                    break;
                case 'colgroup':
                case 'col':
                    $current_key = "cols";
                    $accum_dict[$current_key][] = $node;
                    break;
                case '#PCDATA':
                    // How is whitespace handled? We treat is as sticky to
                    // the *end* of the previous element. So all of the
                    // nonsense we have worked on is to keep things
                    // together.
                    if ($node is Node\HTMLPurifier_Node_Text && $node->is_whitespace) {
                        $accum_dict[$current_key][] = $node;
                    }
                    break;
                }
            }
        }

        if (C\count($accum_dict["content"]) == 0) {
            return tuple(false, vec[]);
        }

        $ret = $accum_dict["initial_ws"];
        if ($caption is nonnull) {
            $ret[] = $caption;
            $ret = Vec\concat($ret, $accum_dict["after_caption_ws"]);
        }
        if (!C\is_empty($cols)) {
            $ret = Vec\concat($ret, $accum_dict["cols"]);
        }
        if ($thead is nonnull) {
            $ret[] = $thead;
            $ret = Vec\concat($ret, $accum_dict["after_thead_ws"]);
        }
        if ($tfoot is nonnull) {
            $ret[] = $tfoot;
            $ret = Vec\concat($ret, $accum_dict["after_tfoot_ws"]);
        }

        if ($tbody_mode) {
            // we have to shuffle tr into tbody
            $current_tr_tbody = null;

            foreach($accum_dict["content"] as $node) {
                if ($node is Node\HTMLPurifier_Node_Element || $node is Node\HTMLPurifier_Node_Text) {
                    switch ($node->name) {
                    case 'tbody':
                        $current_tr_tbody = null;
                        $ret[] = $node;
                        break;
                    case 'tr':
                        if ($current_tr_tbody is null) {
                            $current_tr_tbody = new Node\HTMLPurifier_Node_Element('tbody');
                            $ret[] = $current_tr_tbody;
                        }
                        $current_tr_tbody->children[] = $node;
                        break;
                    case '#PCDATA':
                        //assert($node->is_whitespace);
                        if ($current_tr_tbody is null) {
                            $ret[] = $node;
                        } else {
                            $current_tr_tbody->children[] = $node;
                        }
                        break;
                    }
                }
            }
        } else {
            $ret = Vec\concat($ret, $accum_dict["content"]);
        }

        return tuple(false, $ret);

    }
}