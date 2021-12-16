namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;

class DOMLexTest extends HackTest {
	use ObjectCreationTrait;

	public function testDOMLexBug1(): void {
		// Unexpected TypeError
		$this->makeDOMLex()->tokenizeHTML("<!--sometext-->", $this->makeConfig(), $this->makeContext());
	}

	public function testOutOfBounds(): void {
		echo "\nrunning testOutOfBounds()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_html = '<style><!--';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('');
		echo "finished.\n\n";
	}
}
