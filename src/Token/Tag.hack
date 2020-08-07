/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Token;
use namespace HTMLPurifier;
use namespace HTMLPurifier\Node;
use namespace HH\Lib\{Dict, Str};

/**
 * 
 */
class HTMLPurifier_Token_Tag extends HTMLPurifier\HTMLPurifier_Token {
    public bool $is_tag = true;
    public string $name;
    public dict<string, mixed> $attr = dict[];

    public function __construct(string $name, dict<string, mixed> $attr = dict[], int $line=0, int $col=0, vec<string> $armor = vec[]) {
        $this->name = Str\lowercase($name);
        if (!$attr) {
            $attr = dict[];
        }
        $this->attr = Dict\map_keys($attr, $key ==> Str\lowercase($key));
        $this->line = $line;
        $this->col = $col;
        $this->armor = $armor;
    }

    public function toNode(): Node\HTMLPurifier_Node_Element {
        return new Node\HTMLPurifier_Node_Element($this->name, $this->attr, $this->line, $this->col, $this->armor);
    }
}
