/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

/**
 * Factory for token generation.
 */
class HTMLPurifier_TokenFactory {

	private Token\HTMLPurifier_Token_Start $p_start;
	private Token\HTMLPurifier_Token_End $p_end;
	private Token\HTMLPurifier_Token_Empty $p_empty;
	private Token\HTMLPurifier_Token_Text $p_text;
	private Token\HTMLPurifier_Token_Comment $p_comment;

	public function __construct() {
		$this->p_start = new Token\HTMLPurifier_Token_Start('', dict[]);
		$this->p_end = new Token\HTMLPurifier_Token_End('');
		$this->p_empty = new Token\HTMLPurifier_Token_Empty('', dict[]);
		$this->p_text = new Token\HTMLPurifier_Token_Text('');
		$this->p_comment = new Token\HTMLPurifier_Token_Comment('');
	}

	public function createStart(string $name, dict<string, string> $attr): Token\HTMLPurifier_Token_Start {
		return new Token\HTMLPurifier_Token_Start($name, $attr);
	}

	public function createEnd(string $name): Token\HTMLPurifier_Token_End {
		return new Token\HTMLPurifier_Token_End($name);
	}

	public function createEmpty(string $name, dict<string, string> $attr = dict[]): Token\HTMLPurifier_Token_Empty {
		return new Token\HTMLPurifier_Token_Empty($name, $attr);
	}

	public function createText(string $data): Token\HTMLPurifier_Token_Text {
		return new Token\HTMLPurifier_Token_Text($data);
	}

	public function createComment(string $data): Token\HTMLPurifier_Token_Comment {
		return new Token\HTMLPurifier_Token_Comment($data);
	}

}
