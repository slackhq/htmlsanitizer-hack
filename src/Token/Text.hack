/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Token;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;
/**
 * 
 */
class HTMLPurifier_Token_Text extends HTMLPurifier\HTMLPurifier_Token {
    public string $name = '#PCDATA';
    public string $data;
    public bool $is_whitespace;
    
    public function __construct(string $data, int $line=0, int $col=0) {
        $this->data = $data;
        $this->is_whitespace = \ctype_space($data);
        $this->line = $line;
        $this->col = $col;
    }

    <<__Override>>
    public function toNode(): Node\HTMLPurifier_Node_Text {
        return new Node\HTMLPurifier_Node_Text($this->data, $this->is_whitespace, $this->line, $this->col);
    }

}
