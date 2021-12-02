/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Node;

use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Concrete comment node class;
 */
class HTMLPurifier_Node_Comment extends HTMLPurifier\HTMLPurifier_Node {
	public string $data;
	public bool $is_whitespace = true;

	public function __construct(string $data, int $line = 0, int $col = 0) {
		$this->data = $data;
		$this->line = $line;
		$this->col = $col;
	}

	<<__Override>>
	public function toTokenPair(): (Token\HTMLPurifier_Token_Comment, ?Token\HTMLPurifier_Token_Comment) {
		return tuple(new Token\HTMLPurifier_Token_Comment($this->data, $this->line, $this->col), null);
	}
}
