namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;

final class LexerTest extends HackTest {
	use ObjectCreationTrait;

	public function testHTMLPurifierLexerBug1(): void {
		// Unexpected TypeError
		$this->makeLexer()->normalize('<![CDATA[sometext]]>', $this->makeConfig(), $this->makeContext());
	}
}
