/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Token;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;

/**
 * Concrete comment token class.
 */
class HTMLPurifier_Token_Comment extends HTMLPurifier\HTMLPurifier_Token {
    public string $data;
    public bool $is_whitespace = true;

    public function __construct(string $data, int $line=0, int $col=0) {
        $this->data = $data;
        $this->line = $line;
        $this->col = $col;
    }

    <<__Override>>
    public function toNode(): Node\HTMLPurifier_Node_Comment {
        return new Node\HTMLPurifier_Node_Comment($this->data, $this->line, $this->col);
    }
}
