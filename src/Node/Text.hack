/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Node;
use namespace HTMLPurifier\Token;
use namespace HTMLPurifier;

/**
 * Text token class.
 */
class HTMLPurifier_Node_Text extends HTMLPurifier\HTMLPurifier_Node {
    public string $name = '#PCDATA';
    public string $data;
    public bool $is_whitespace;
    
    public function __construct(string $data, bool $is_whitespace, int $line=0, int $col=0) {
        $this->data = $data;
        $this->is_whitespace = $is_whitespace;
        $this->line = $line;
        $this->col = $col;
    }

    <<__Override>>
    public function toTokenPair(): (Token\HTMLPurifier_Token_Text, ?Token\HTMLPurifier_Token_Text) {
        return tuple(new Token\HTMLPurifier_Token_Text($this->data, $this->line, $this->col), null);
    }

}
