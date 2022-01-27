/* Created by Jake Polacek on 01/20/2022 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer, Enums};

class HandleIframeAsTextTest extends HackTest {
	public function testSingleNestedElement(): void {
		echo "\ntestSingleNestedElement()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<b></b>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;b&gt;&lt;/b&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testSingleNestedElementWithData(): void {
		echo "\ntestSingleNestedElementWithData()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<script>alert(1);</script>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;script&gt;alert(1);&lt;/script&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testMultipleNestedElementWithData(): void {
		echo "\ntestMultipleNestedElementWithData()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<script>alert(1);</script>
	<script>alert(2);</script>
	<script>alert(3);</script>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;script&gt;alert(1);&lt;/script&gt;
	&lt;script&gt;alert(2);&lt;/script&gt;
	&lt;script&gt;alert(3);&lt;/script&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testSingleDoublyNestedElement(): void {
		echo "\ntestSingleDoublyNestedElement()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<b><i>hello world</i></b>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;b&gt;&lt;i&gt;hello world&lt;/i&gt;&lt;/b&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testMultipleDoublyNestedElement(): void {
		echo "\ntestMultipleDoublyNestedElement()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<b><i>hello world1</i></b>
	<b><i>hello world2</i></b>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;b&gt;&lt;i&gt;hello world1&lt;/i&gt;&lt;/b&gt;
	&lt;b&gt;&lt;i&gt;hello world2&lt;/i&gt;&lt;/b&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testDoublyNestedElement(): void {
		echo "\ntestDoublyNestedElement()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	<p><i>hello</i> <b>world</b></p>
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	&lt;p&gt;&lt;i&gt;hello&lt;/i&gt; &lt;b&gt;world&lt;/b&gt;&lt;/p&gt;
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testMultiLineIframe(): void {
		echo "\ntestSingleLineIframe()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	hello world
</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">
	hello world
</iframe>',
		);
		echo "finished.\n\n";
	}

	public function testSingleLineIframe(): void {
		echo "\ntestSingleLineIframe()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault()
			|> $$->addAllowedTag(Enums\HtmlTags::IFRAME);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html =
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">hello world</iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://example.org" title="iframe Example 1" width="400" height="300">hello world</iframe>',
		);
		echo "finished.\n\n";
	}
}
