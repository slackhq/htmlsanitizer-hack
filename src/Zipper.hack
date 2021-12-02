/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\{C, Vec};

/**
 * A zipper is a purely-functional data structure which contains
 * a focus that can be efficiently manipulated.  It is known as
 * a "one-hole context".  This mutable variant implements a zipper
 * for a list as a pair of two arrays, laid out as follows:
 *
 *      Base list: 1 2 3 4 [ ] 6 7 8 9
 *      Front list: 1 2 3 4
 *      Back list: 9 8 7 6
 *
 * User is expected to keep track of the "current element" and properly
 * fill it back in as necessary.  (ToDo: Maybe it's more user friendly
 * to implicitly track the current element?)
 *
 * Nota bene: the current class gets confused if you try to store NULLs
 * in the list.
 */
class HTMLPurifier_Zipper<T> {
	// I think it makes sense for this to be a generic. I _think_ that we mostly use
	// tokens, but since this can be with other types I figured it made sense to
	// implement it in this manner
	public vec<T> $front;
	public vec<T> $back;

	public function __construct(vec<T> $front, vec<T> $back) {
		$this->front = $front;
		$this->back = $back;
	}

	/**
	 * Creates a zipper from an array, with a hole in the
	 * 0-index position.
	 * @param Array to zipper-ify.
	 * @return Tuple of zipper and element of first position.
	 */
	static public function fromArray(vec<T> $array): (HTMLPurifier_Zipper<T>, ?T) {
		$z = new self(vec[], Vec\reverse($array));
		$t = $z->delete(); // delete the "dummy hole"
		return tuple($z, $t);
	}

	/**
	 * Convert zipper back into a normal array, optionally filling in
	 * the hole with a value. (Usually you should supply a $t, unless you
	 * are at the end of the array.)
	 */
	public function toArray(?T $t = null): vec<T> {
		$a = $this->front;
		if ($t !== null) $a[] = $t;
		for ($i = C\count($this->back) - 1; $i >= 0; $i--) {
			$a[] = $this->back[$i];
		}
		return $a;
	}

	/**
	 * Move hole to the next element.
	 * @note please compare this to the PHP code. The documentation
	 * was pretty vague on this one and the pop function doesn't 
	 * exist in Hack
	 */
	public function next(?T $t): ?T {
		if ($t !== null) {
			$this->front[] = $t;
		}
		$ret = C\last($this->back);
		$back_length = C\count($this->back);
		if ($back_length > 0) {
			$this->back = Vec\take($this->back, $back_length - 1);
		}
		return $ret;
	}

	/**
	 * Iterated hole advancement.
	 */
	public function advance(T $t, int $n): ?T {
		for ($i = 0; $i < $n; $i++) {
			$t = $this->next($t);
		}
		return $t;
	}

	/**
	 * Move hole to the previous element
	 * @param $t Element to fill hole with
	 * @return Original contents of new hole.
	 */
	public function prev(?T $t): ?T {
		if ($t !== null) {
			$this->back[] = $t;
		}
		$ret = C\last($this->front);
		$front_length = C\count($this->front);
		if ($front_length > 0) {
			$this->front = Vec\take($this->front, $front_length - 1);
		}
		return $ret;
	}

	/**
	* Delete contents of current hole, shifting hole to
	* next element.
	*/
	public function delete(): ?T {
		$ret = C\last($this->back);
		$back_length = C\count($this->back);
		if ($back_length > 0) {
			$this->back = Vec\take($this->back, $back_length - 1);
		}
		return $ret;
	}

	/**
	* Returns true if we are at the end of the list.
	*/
	public function done(): bool {
		return !$this->back;
	}

	/**
	* Insert element before hole.
	*/
	public function insertBefore(T $t): void {
		if ($t !== NULL) $this->front[] = $t;
	}

	/**
	* Insert element after hole.
	*/
	public function insertAfter(T $t): void {
		if ($t !== NULL) $this->back[] = $t;
	}

	/**
	* Splice in multiple elements at hole.  Functional specification
	* in terms of array_splice:
	*
	*      $arr1 = $arr;
	*      $old1 = array_splice($arr1, $i, $delete, $replacement);
	*
	*      list($z, $t) = HTMLPurifier_Zipper::fromArray($arr);
	*      $t = $z->advance($t, $i);
	*      list($old2, $t) = $z->splice($t, $delete, $replacement);
	*      $arr2 = $z->toArray($t);
	*
	*      assert($old1 === $old2);
	*      assert($arr1 === $arr2);
	*
	* NB: the absolute index location after this operation is
	* *unchanged!*
	*
	* @param Current contents of hole.
	*/
	public function splice(T $t, int $delete, vec<T> $replacement): (vec<?T>, ?T) {
		// delete
		$old = vec[];
		$r = $t;
		for ($i = $delete; $i > 0; $i--) {
			$old[] = $r;
			$r = $this->delete();
		}
		// insert
		for ($i = C\count($replacement) - 1; $i >= 0; $i--) {
			if ($r !== null) $this->insertAfter($r);
			$r = $replacement[$i];
		}
		return tuple($old, $r);
	}
}
