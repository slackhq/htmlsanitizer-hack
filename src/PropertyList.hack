/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\{C, Keyset};

/**
 * Generic property list implementation
 */
class HTMLPurifier_PropertyList {

	//this class variable (data) will hold properties

	protected keyset<arraykey> $data = keyset[];

	protected ?HTMLPurifier_PropertyList $parent;

	//cache
	protected keyset<arraykey> $cache = keyset[];

	public function __construct(?HTMLPurifier_PropertyList $parent = null) {
		$this->parent = $parent;
	}

	//not sure when data ever gets real values in the simple use case: todo figure out
	public function get(string $name): mixed {
		if ($this->has($name)) {
			return $this->data[$name];
		}
		if ($this->parent) {
			return $this->parent->get($name);
		}

		throw new \Exception("Key '$name' not found");
	}

	public function has(string $name): bool {
		return C\contains($this->data, $name);
	}

	/**
	 * Squashes this property list and all of its property lists into a single
	 * array, and returns the array. This value is cached by default.
	 */
	public function squash(bool $force = false): keyset<arraykey> {
		if ($this->cache is nonnull && !$force) {
			return $this->cache;
		}
		if ($this->parent) {
			$this->cache = Keyset\intersect($this->parent->squash($force), $this->data);
			return $this->cache;
		} else {
			$this->cache = $this->data;
			return $this->cache;
		}
	}
}
