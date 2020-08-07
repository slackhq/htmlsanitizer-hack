/* Created by Jacob Polacek on 06/29/2020 */

namespace HTMLPurifier\ChildDef;
use namespace HTMLPurifier;

/**
 * Definition that disallows all elements.
 * @warning validateChildren() in this class is actually never called, because
 *          empty elements are corrected in HTMLPurifier_Strategy_MakeWellFormed
 *          before child definitions are parsed in earnest by
 *          HTMLPurifier_Strategy_FixNesting.
 */
class HTMLPurifier_ChildDef_Empty extends HTMLPurifier\HTMLPurifier_ChildDef
{
    public bool $allow_empty = true;

    public string $type = 'empty';

    public function __construct()
    {
    }

    public function validateChildren(vec<HTMLPurifier\HTMLPurifier_Node>$_children, HTMLPurifier\HTMLPurifier_Config $_config, HTMLPurifier\HTMLPurifier_Context $_context) : (bool, vec<HTMLPurifier\HTMLPurifier_Node>) {
        return tuple(true, vec[]);
    }
}