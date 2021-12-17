/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer, Enums};

class AllowedTest extends HackTest {
	public function testEmptyAllowedList(): void {
		echo "\ntestDefaultAllowed()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromEmpty();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_html = '<h1>Title</h1><a href="slack.com">Go to Slack</a>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('TitleGo to Slack');
		echo "finished.\n\n";
	}

	public function testStripTagsNotInDefaultPolicy(): void {
		echo "\ntestStripTagsNotInDefaultPolicy()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_html = '<a>test</a>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('test');
		echo "finished.\n\n";
	}

	public function testCustomTagsWithAttributes(): void {
		echo "\ntestCustomTagsWithAttributes()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTagWithAttributes(
			Enums\HtmlTags::IMG,
			keyset[Enums\HtmlAttributes::SRC, Enums\HtmlAttributes::ALT],
		);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_html = '<img src="https://test.com" alt="test" onerror=alert(1); />hello<script>alert(1);</script>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<img src="https://test.com" alt="test">helloalert(1);');
		echo "finished.\n\n";
	}
}
