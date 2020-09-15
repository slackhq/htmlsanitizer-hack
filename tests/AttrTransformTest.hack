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
		expect($value)->toEqual('b');
		expect($dict)->toEqual(dict[]);
	}

	public function testConfiscateAttrBug2(): void {
		$obj = $this->instance();

		$dict = dict['a' => 'b'];
		$value = $obj->confiscateAttr(inout $dict, 'b');
		expect($value)->toEqual(null);
		expect($dict)->toEqual(dict['a' => 'b']);
	}
}

class InstantiatableAttrTransform extends HTMLPurifier_AttrTransform {
	<<__Override>>
	public function transform(mixed $s, mixed $t, mixed $ub): nothing {
		invariant_violation('stub');
	}
}
