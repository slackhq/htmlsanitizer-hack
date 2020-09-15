namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use type HTMLPurifier\HTMLPurifier_AttrTransform;
use namespace HH\Lib\C;

class AttrTransformTest extends HackTest {
	private function instance(): InstantiatableAttrTransform {
		return new InstantiatableAttrTransform();
	}

	public function testConfiscateAttrBug1(): void {
		$obj = $this->instance();
		$dict = dict['a' => 'b'];
		$value = $obj->confiscateAttr(inout $dict, 'a');
		// anti expect, this assertion should fail!
		expect($value)->toEqual(null, 'Expected to get the value for the key "a", got null');

		$dict = dict['a' => 'b'];
		$value = $obj->confiscateAttrFixed(inout $dict, 'a');
		expect($value)->toEqual('b');
	}

	public function testConfiscateAttrBug2(): void {
		$obj = $this->instance();
		$dict = dict['a' => 'b'];
		// anti expect, this assertion should fail!
		expect(() ==> $obj->confiscateAttr(inout $dict, 'b'))->toThrow(
			\OutOfBoundsException::class,
			'invalid index "b"',
			'This exception should not be thrown',
		);

		$dict = dict['a' => 'b'];
		$value = $obj->confiscateAttrFixed(inout $dict, 'b');
		expect($value)->toEqual(null);
	}
}

class InstantiatableAttrTransform extends HTMLPurifier_AttrTransform {
	<<__Override>>
	public function transform(mixed $s, mixed $t, mixed $ub): nothing {
		invariant_violation('stub');
	}
	// Retrieves and removes an attribute.
	public function confiscateAttrFixed<Tk as arraykey, Tv>(inout dict<Tk, Tv> $attr, Tk $key): ?Tv {
		if (!C\contains_key($attr, $key)) {
			return null;
		}
		$value = $attr[$key];
		unset($attr[$key]);
		return $value;
	}
}
