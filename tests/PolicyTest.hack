/* Created by Jake Polacek on 11/21/2021 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer};

class PolicyTest extends HackTest {

	public function testDefaultPolicy(): void {
		echo "\nrunning testMissingEndTags()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config);

		$dirty_html = '<b>Bold';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Bold</b>');
		echo "finished.\n\n";
	}

	public function testEmptyPolicy(): void {
		echo "\nrunning testEmptyPolicy()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict[]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<b>Bold';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Bold</b>');
		echo "finished.\n\n";
	}


}
