/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Node;

use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Element node class.
 */
class HTMLPurifier_Node_Element extends HTMLPurifier\HTMLPurifier_Node {
	public string $name;
	public dict<string, string> $attr = dict[];
	public vec<HTMLPurifier\HTMLPurifier_Node> $children = vec[];
	/**
	 * Does this use the <a></a> form or the </a> form, i.e.
	 * is it a pair of start/end tokens or an empty token.
	 * @bool
	*/
	public bool $empty = false;
	public int $endCol = 0;
	public int $endLine = 0;
	public vec<string> $endArmor = vec[];

	public function __construct(
		string $name,
		dict<string, string> $attr = dict[],
		int $line = 0,
		int $col = 0,
		vec<string> $armor = vec[],
	) {
		$this->name = $name;
		$this->attr = $attr;
		$this->line = $line;
		$this->col = $col;
		$this->armor = $armor;
	}

	<<__Override>>
	public function toTokenPair(): (HTMLPurifier\HTMLPurifier_Token, ?HTMLPurifier\HTMLPurifier_Token) {
		if ($this->empty) {
			return tuple(
				new Token\HTMLPurifier_Token_Empty($this->name, $this->attr, $this->line, $this->col, $this->armor),
				null,
			);
		} else {
			$start = new Token\HTMLPurifier_Token_Start(
				$this->name,
				$this->attr,
				$this->line,
				$this->col,
				$this->armor,
			);
			$end = new Token\HTMLPurifier_Token_End(
				$this->name,
				dict[],
				$this->endLine,
				$this->endCol,
				$this->endArmor,
			);
			return tuple($start, $end);
		}
	}
}
