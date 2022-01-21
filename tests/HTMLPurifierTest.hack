/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer, Enums};

class HTMLPurifierTest extends HackTest {
	private function standardPolicy(): HTMLPurifier\HTMLPurifier_Policy {
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
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
		$policy->addAllowedTagsWithAttributes(
			dict[
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
			],
		);

		return $policy;
	}

	public function testMissingEndTags(): void {
		echo "\nrunning testMissingEndTags()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<b>Bold';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Bold</b>');
		echo "finished.\n\n";
	}

	public function testMaliciousCodeRemoved(): void {
		echo "\ntestMaliciousCodeRemoved()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<img src="javascript:evil();" onload="evil();" />';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('');
		echo "finished.\n\n";
	}

	public function testMaliciousCodeRemovedWithText(): void {
		echo "\ntestMaliciousCodeRemovedWithText()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<img src="javascript:evil();" onload="evil();" />hello';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('hello');
		echo "finished.\n\n";
	}

	public function testIllegalNestingFixed(): void {
		echo "\ntestIllegalNestingFixed()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTags(keyset[Enums\HtmlTags::DEL, Enums\HtmlTags::DIV]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<b>Inline <del>context <div>No block allowed</div></del></b>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Inline <del>context No block allowed</del></b>');
		echo "finished.\n\n";
	}

	public function testDeprecatedTagsConverted(): void {
		echo "\ntestDeprecatedTagsConverted()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTag(Enums\HtmlTags::CENTER);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<center>Centered</center>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<center>Centered</center>');
		echo "finished.\n\n";
	}

	public function testCSSValidated(): void {
		echo "\ntestCSSValidated()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTag(Enums\HtmlTags::SPAN);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<span style="color:#COW;float:around;text-decoration:blink;">Text</span>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<span>Text</span>');
		echo "finished.\n\n";
	}

	public function testMaintainSuperfluousDivs(): void {
		echo "\ntestMaintainSuperfluousDivs()...";
		// porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTags(keyset[Enums\HtmlTags::H2, Enums\HtmlTags::DIV]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<div class="style1">
<div class="style2">
<h2>text</h2>
</div>
</div>';
		$clean_html = $purifier->purify($dirty_html);
		// no-op, extra div should remain
		expect($clean_html)->toEqual($dirty_html);
	}

	public function testRichFormattingPreserved(): void {
		echo "\ntestRichFormattingPreserved()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTags(keyset[
			Enums\HtmlTags::CAPTION,
			Enums\HtmlTags::TFOOT,
			Enums\HtmlTags::TR,
			Enums\HtmlTags::TH,
			Enums\HtmlTags::TBODY,
			Enums\HtmlTags::TABLE,
		]);
		$policy->addAllowedTagWithAttributes(Enums\HtmlTags::TD, keyset[Enums\HtmlAttributes::STYLE]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<table>
  <caption>
	Cool table
  </caption>
  <tfoot>
	<tr>
	  <th>I can do so much!</th>
	</tr>
  </tfoot>
  <tr>
	<td style="font-size:16pt;
	  color:#F00;font-family:sans-serif;
	  text-align:center;">Wow</td>
  </tr>
</table>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<table>
  <caption>
	Cool table
  </caption>
  <tfoot>
	<tr>
	  <th>I can do so much!</th>
	</tr>
  </tfoot>
  <tbody><tr>
	<td style="font-size:16pt;color:#F00;font-family:sans-serif;text-align:center;">Wow</td>
  </tr>
</tbody></table>');
	}

	public function testDOM(): void {
		echo "\nrunning testDOM()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		// This is weird, but based off of how we define config in HTMLPurifier constructor
		$config = $policy->configPolicy($config);
		$context = new HTMLPurifier\HTMLPurifier_Context();

		$html = "<b>Bold";
		$lexer = new Lexer\HTMLPurifier_Lexer_DOMLex();
		$tokens = $lexer->tokenizeHTML($html, $config, $context);

		$expected_tokens = vec[
			new Token\HTMLPurifier_Token_Start("b", dict[]),
			new Token\HTMLPurifier_Token_Text("Bold"),
			new Token\HTMLPurifier_Token_End("b", dict[]),
		];

		expect($tokens)->toBePHPEqual($expected_tokens);
		echo "finished.\n";
	}

	public function testStrategies(): void {
		echo "\nrunning testStrategies()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		// This is weird, but based off of how we define config in HTMLPurifier constructor
		$config = $policy->configPolicy($config);
		$context = new HTMLPurifier\HTMLPurifier_Context();

		$remove_foreign_elements = new Strategy\HTMLPurifier_Strategy_RemoveForeignElements();
		$make_well_formed = new Strategy\HTMLPurifier_Strategy_MakeWellFormed();
		$fix_nesting = new Strategy\HTMLPurifier_Strategy_FixNesting();
		$validate_attributes = new Strategy\HTMLPurifier_Strategy_ValidateAttributes();

		$tokens = vec[
			new Token\HTMLPurifier_Token_Start("b", dict[]),
			new Token\HTMLPurifier_Token_Text("Text"),
			new Token\HTMLPurifier_Token_End("b", dict[]),
		];

		$rfe_tokens = $remove_foreign_elements->execute($tokens, $config, $context);
		$mwf_tokens = $make_well_formed->execute($tokens, $config, $context);
		$fn_tokens = $fix_nesting->execute($tokens, $config, $context);
		$va_tokens = $validate_attributes->execute($tokens, $config, $context);

		expect($rfe_tokens)->toBePHPEqual($tokens);
		expect($mwf_tokens)->toBePHPEqual($tokens);
		expect($fn_tokens)->toBePHPEqual($tokens);
		expect($va_tokens)->toBePHPEqual($tokens);
		echo "finished.\n";
	}

	public function testPolicyAllowListUnClean(): void {
		echo "\nrunning testPolicyAllowListUnClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTag(Enums\HtmlTags::A);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<b>Hello';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('Hello');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListUnCleanWithPolicyDict(): void {
		echo "\nrunning testPolicyAllowListUnCleanWithPolicyDict()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTag(Enums\HtmlTags::A);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<b>Hello';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('Hello');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListClean(): void {
		echo "\nrunning testPolicyAllowListClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTag(Enums\HtmlTags::B);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<b>Hello';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Hello</b>');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListWithAttributesRemoveExtra(): void {
		echo "\nrunning testPolicyAllowListWithAttributesRemoveExtra...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTagWithAttributes(Enums\HtmlTags::DIV, keyset[Enums\HtmlAttributes::ALIGN]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<div align="center" title="hi">Hello';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<div align="center">Hello</div>');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListCleanAndUnclean(): void {
		echo "\nrunning testPolicyAllowListClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTagWithAttributes(Enums\HtmlTags::DIV, keyset[Enums\HtmlAttributes::ALIGN]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<div align="center" title="hi"><b>Hello</b>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<div align="center">Hello</div>');
		echo "finished.\n\n";
	}

	public function testSanitizeHtmlWithIframeForVideoPolicySet(): void {
		echo "\nrunning testSanitizeHtmlWithIframeForVideoPolicySet()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTagWithAttributes(
			Enums\HtmlTags::IFRAME,
			keyset[
				Enums\HtmlAttributes::TITLE,
				Enums\HtmlAttributes::WIDTH,
				Enums\HtmlAttributes::HEIGHT,
				Enums\HtmlAttributes::SRC,
				Enums\HtmlAttributes::ALLOWFULLSCREEN,
			],
		);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html = '<iframe src="https://www.example.com/watch?v=M84hFmNhTQU" height="364" width="576"></iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe src="https://www.example.com/watch?v=M84hFmNhTQU" height="364" width="576"></iframe>',
		);
		echo "finished.\n\n";
	}

	public function testSanitizeHtmlWithIframeForSearchProtocolsPolicySet(): void {
		echo "\nrunning testSanitizeHtmlWithIframeForSearchProtocolsPolicySet()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTagWithAttributes(
			Enums\HtmlTags::IFRAME,
			keyset[
				Enums\HtmlAttributes::TITLE,
				Enums\HtmlAttributes::WIDTH,
				Enums\HtmlAttributes::HEIGHT,
				Enums\HtmlAttributes::SRC,
				Enums\HtmlAttributes::ALLOWFULLSCREEN,
			],
		);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		// Test1 clean iframe with usertesting domain with no protocol
		$dirty_html = '<iframe
			title="Wildlife"
			width="500"
			height="400"
			src="//www.example.com"
			allowfullscreen=true
			></iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe title="Wildlife" width="500" height="400" src="//www.example.com" allowfullscreen="true"></iframe>',
		);

		$dirty_html = '<iframe
			title="Wildlife"
			width="500"
			height="400"
			src="https://www.example.com/"
			allowfullscreen=true
			></iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<iframe title="Wildlife" width="500" height="400" src="https://www.example.com/" allowfullscreen="true"></iframe>',
		);
		echo "finished.\n\n";
	}

	public function testMunge(): void {
		echo "\nrunning testMunge()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTagWithAttributes(Enums\HtmlTags::A, keyset[Enums\HtmlAttributes::HREF]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$config->def->defaults["URI.Munge"] = "/redirect.php?url=%s&check=%t";
		$config->def->defaults["URI.MungeSecretKey"] = "foo";
		// print($config);
		$dirty_html = '<a href="http://localhost">foo</a>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual(
			'<a href="/redirect.php?url=http%3A%2F%2Flocalhost&amp;check=c0efad89696082f5cb925d28636b0f4260f346391c92c70c8e9eba72591c2a73">foo</a>',
		);
	}

	public function testPercentageHeightWidth(): void {
		echo "\nrunning testPercentageHeightWidth()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromDefault();
		$policy->addAllowedTagWithAttributes(Enums\HtmlTags::IFRAME, keyset[
			Enums\HtmlAttributes::SRC,
			Enums\HtmlAttributes::HEIGHT,
			Enums\HtmlAttributes::WIDTH,
			Enums\HtmlAttributes::ALLOWFULLSCREEN,
		]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);

		$dirty_html =
			'<iframe src="https://example.com/videoclip/abc123?autoplay=true&origin=slack" height="100%" width="100%" allow="fullscreen" allowfullscreen="true" frameborder="0"></iframe>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html =
			'<iframe src="https://example.com/videoclip/abc123?autoplay=true&amp;origin=slack" height="100%" width="100%" allowfullscreen="true"></iframe>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testImagePolicyWithMissingAltAttribute(): void {
		echo "\nrunning testImagePolicyWithMissingAltAttribute()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
		$policy->addAllowedTagWithAttributes(
			Enums\HtmlTags::IMG,
			keyset[
				Enums\HtmlAttributes::SRC,
				Enums\HtmlAttributes::ALT,
				Enums\HtmlAttributes::CLASSES,
				Enums\HtmlAttributes::WIDTH,
				Enums\HtmlAttributes::HEIGHT,
				Enums\HtmlAttributes::SRCSET,
				Enums\HtmlAttributes::SIZES,
			],
		);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html =
			'<img loading="lazy" class="alignright" src="https://biz-hq.co/request-unlimited-pto@2x.jpg?w=360">';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html =
			'<img class="alignright" src="https://biz-hq.co/request-unlimited-pto@2x.jpg?w=360" alt="request-unlimited-pto@2x.jpg?w=360">';
		// do not remove images without alt attributes, add the basename as alt
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testWebappPolicy(): void {
		echo "\nrunning testWebappPolicy()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		expect(true)->toNotBeNull();
		echo "finished.\n\n";
	}

	public function testSpecialCharacterValidateUTF8(): void {
		echo "\nrunning testSpecialCharacterValidateUTF8()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<ul>
<li>Just a sentence. </li>
<li>Just a sentence.</li>
<li>Just a sentence.</li>
<li>Just a sentence.</li>
</ul>
<h2>Should I?</h2>
<p><strong>If you’re working with&#8230;</strong></p>
<ul>
<li>An individual &#8211; abc</li>
<li>A team &#8211; abc</li>
</ul>
<p>p tags.</p>
<h2>header 2</h2>
[aside headline="Who are you working with?" description="" bullets="a sentence. " /]
<p>&nbsp;</p>
[aside headline="How many people are involved?" description="" bullets="a sentence" /]
<p>&nbsp;</p>
[aside headline="Data access" description="" bullets="a sentence" /]
<p>&nbsp;</p>
[aside headline="Security" description="" bullets="a sentence" /]';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<ul>
<li>Just a sentence. </li>
<li>Just a sentence.</li>
<li>Just a sentence.</li>
<li>Just a sentence.</li>
</ul>
<h2>Should I?</h2>
<p><strong>If you’re working with…</strong></p>
<ul>
<li>An individual – abc</li>
<li>A team – abc</li>
</ul>
<p>p tags.</p>
<h2>header 2</h2>
[aside headline="Who are you working with?" description="" bullets="a sentence. " /]
<p> </p>
[aside headline="How many people are involved?" description="" bullets="a sentence" /]
<p> </p>
[aside headline="Data access" description="" bullets="a sentence" /]
<p> </p>
[aside headline="Security" description="" bullets="a sentence" /]';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testQuote(): void {
		echo "\nrunning testWebappPolicy()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html =
			'<h3><img loading="lazy" class="alignnone size-full wp-image-1466" src="https://a1b.cloudfront.net/test/6/at-test-user-test%402x.png" alt="how to use the &quot;at&quot; html sanitizer" width="1024" height="579" />How it works</h3>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html =
			'<h3><img class="alignnone size-full wp-image-1466" src="https://a1b.cloudfront.net/test/6/at-test-user-test%402x.png" alt="how to use the &quot;at&quot; html sanitizer" width="1024" height="579">How it works</h3>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testRel(): void {
		echo "\nrunning testRel()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a rel="ab" name="bobcat"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testAtagTargetAttribute(): void {
		echo "\nrunning testAtagTargetAttribute()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a name="bobcat" target="_blank"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat" target="_blank" rel="noopener noreferrer"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testAtagNoChange(): void {
		echo "\nrunning testAtagNoChange()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a name="bobcat" target="_blank" rel="noopener noreferrer"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat" target="_blank" rel="noopener noreferrer"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testAtagStripAdd(): void {
		echo "\nrunning testAtagStripAdd()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a name="bobcat" target="_blank" rel="ab" target="_blank"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat" target="_blank" rel="noopener noreferrer"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testAtagStripLeave(): void {
		echo "\nrunning testAtagStripLeave()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a name="bobcat" target="_blank" rel="ab noopener noreferrer"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat" target="_blank" rel="noopener noreferrer"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testAtagNoTarget(): void {
		echo "\nrunning testAtagNoTarget()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = $this->standardPolicy();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<p><a name="bobcat" rel="noopener noreferrer"></a></p>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<p><a name="bobcat" rel="noopener noreferrer"></a></p>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testDisabledTargetBlankTransform(): void {
		echo "\nrunning testAtagNoTarget()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLPurifier_Policy::fromEmpty();
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
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<a href="https://google.com"></a>';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<a href="https://google.com"></a>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}
}
