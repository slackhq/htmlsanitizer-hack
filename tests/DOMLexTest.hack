namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;

class DOMLexTest extends HackTest {
    use ObjectCreationTrait;

	public function testDOMLexBug1(): void {
        // Unexpected TypeError
        $this->makeDOMLex()->tokenizeHTML("<!--sometext-->", $this->makeConfig(), $this->makeContext());
    }
}
