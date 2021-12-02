/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

/**
 * Abstract base node class that all others inherit from.
 */
abstract class HTMLPurifier_Node {
	public int $line = 0;
	public int $col = 0;

	//making this a string type for now
	public vec<string> $armor = vec[];

	public bool $dead = false;

	abstract public function toTokenPair(): (HTMLPurifier_Token, ?HTMLPurifier_Token);
}
