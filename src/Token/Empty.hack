/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Token;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Node, Token};

/**
 * Empty token class.
 */
class HTMLPurifier_Token_Empty extends HTMLPurifier_Token_Tag {
    public function toNode(): Node\HTMLPurifier_Node_Element {
        $n = parent::toNode();
        $n->empty = true;
        return $n;
    }
}


