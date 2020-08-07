/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Token;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;

/**
 * End token class.
 */
class HTMLPurifier_Token_End extends HTMLPurifier_Token_Tag {

    public ?HTMLPurifier\HTMLPurifier_Token $start;

    <<__Override>>
    public function toNode(): Node\HTMLPurifier_Node_Element {
        throw new \Exception("HTMLPurifier_Token_End->toNode not supported");
        //unsure why the original code does this
    }
}
