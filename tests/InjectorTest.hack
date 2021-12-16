/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer, Injector};

class InjectorTest extends HackTest {
	private function assertAutoParagraphResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.AutoParagraph"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertDisplayURIResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTag(HTMLPurifier\html_tags_t::A);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.DisplayLinkURI"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertRemoveEmptyResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.RemoveEmpty"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertPurifierLinkifyResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTags(keyset[HTMLPurifier\html_tags_t::DIV, HTMLPurifier\html_tags_t::SPAN]);
		$policy->addAllowedTagWithAttributes(HTMLPurifier\html_tags_t::A, keyset[
			HTMLPurifier\html_attributes_t::HREF,
		]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.PurifierLinkify"] = true;
		$config->def->defaults["AutoFormat.PurifierLinkify.DocURL"] = '#%s';
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertLinkifyResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTag(HTMLPurifier\html_tags_t::SPAN);
		$policy->addAllowedTagWithAttributes(HTMLPurifier\html_tags_t::A, keyset[
			HTMLPurifier\html_attributes_t::HREF,
		]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.Linkify"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertRemoveSpansWithoutAttributesResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$policy->addAllowedTags(keyset[
			HTMLPurifier\html_tags_t::DIV,
			HTMLPurifier\html_tags_t::P,
			HTMLPurifier\html_tags_t::STRONG,
			HTMLPurifier\html_tags_t::EM,
		]);
		$policy->addAllowedTagWithAttributes(
			HTMLPurifier\html_tags_t::SPAN,
			keyset[HTMLPurifier\html_attributes_t::CLASSES],
		);
		// $config->def->defaults['HTML.Allowed'] = 'span[class],div,p,strong,em';
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.RemoveSpansWithoutAttributes"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	private function assertSafeObjectResult(string $name, string $dirty, string $expected): void {
		echo "\nrunning test$name()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$policy = HTMLPurifier\HTMLSanitizerPolicy::fromDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy->constructPolicy());
		$config->def->defaults["AutoFormat.Custom"] = vec[new Injector\HTMLPurifier_Injector_SafeObject()];
		$config->def->defaults["HTML.Trusted"] = true;
		$clean_html = $purifier->purify($dirty);
		expect($clean_html)->toEqual($expected);
		echo "finished.\n\n";
	}

	public function testSingleParagraph(): void {
		$this->assertAutoParagraphResult('SingleParagraph', 'Foobar', '<p>Foobar</p>');
	}

	public function testSingleMultiLineParagraph(): void {
		$this->assertAutoParagraphResult(
			'SingleMultiLineParagraph',
			'Par 1
Par 1 still',
			'<p>Par 1
Par 1 still</p>',
		);
	}

	public function testTwoParagraphs(): void {
		$this->assertAutoParagraphResult(
			'TwoParagraphs',
			'Par1

Par2',
			"<p>Par1</p>

<p>Par2</p>",
		);
	}

	public function testTwoParagraphsWithLotsOfSpace(): void {
		$this->assertAutoParagraphResult(
			'TwoParagraphsWithLotsOfSpace',
			'Par1



Par2',
			'<p>Par1</p>

<p>Par2</p>',
		);
	}

	public function testBasicLink(): void {
		$this->assertDisplayURIResult(
			'BasicLink',
			'<a href="http://malware.example.com">Don\'t go here!</a>',
			'<a>Don\'t go here!</a> (http://malware.example.com)',
		);
	}

	public function testEmptyLink(): void {
		$this->assertDisplayURIResult('EmptyLink', '<a>Don\'t go here!</a>', '<a>Don\'t go here!</a>');
	}

	public function testPreserve(): void {
		$this->assertRemoveEmptyResult('Preserve', '<b>asdf</b>', '<b>asdf</b>');
	}

	public function testRemove(): void {
		$this->assertRemoveEmptyResult('Remove', '<b></b>', '');
	}

	public function testRemoveWithSpace(): void {
		$this->assertRemoveEmptyResult('RemoveWithSpace', '<b>   </b>', '');
	}

	public function testRemoveWithAttr(): void {
		$this->assertRemoveEmptyResult('RemoveWithAttr', '<b class="asdf"></b>', '');
	}

	public function testNoTriggerCharacer(): void {
		$this->assertPurifierLinkifyResult('NoTriggerCharacter', 'Foobar', 'Foobar');
	}

	public function testTriggerCharacterInIrrelevantContext(): void {
		$this->assertPurifierLinkifyResult('TriggerCharacterInIrrelevantContext', '20% off!', '20% off!');
	}

	public function testPreserveNamespace(): void {
		$this->assertPurifierLinkifyResult(
			'PreserveNamespace',
			'%Core namespace (not recognized)',
			'%Core namespace (not recognized)',
		);
	}

	public function testLinkifyBasic(): void {
		$this->assertPurifierLinkifyResult(
			'LinkifyBasic',
			'%Namespace.Directive',
			'<a href="#Namespace.Directive">%Namespace.Directive</a>',
		);
	}

	public function testLinkifyWithAdjacentTextNodes(): void {
		$this->assertPurifierLinkifyResult(
			'LinkifyWithAdjacentTextNodes',
			'This %Namespace.Directive thing',
			'This <a href="#Namespace.Directive">%Namespace.Directive</a> thing',
		);
	}

	public function testLinkifyInBlock(): void {
		$this->assertPurifierLinkifyResult(
			'LinkifyInBlock',
			'<div>This %Namespace.Directive thing</div>',
			'<div>This <a href="#Namespace.Directive">%Namespace.Directive</a> thing</div>',
		);
	}

	public function testPreserveInATag(): void {
		$this->assertPurifierLinkifyResult(
			'PreserveInATag',
			'<a>%Namespace.Directive</a>',
			'<a>%Namespace.Directive</a>',
		);
	}

	public function testLinkifyURLInRootNode(): void {
		$this->assertLinkifyResult(
			'LinkifyURLInRootNode',
			'http://example.com',
			'<a href="http://example.com">http://example.com</a>',
		);
	}

	public function testLinkifyURLInInlineNode(): void {
		$this->assertLinkifyResult(
			'LinkifyURLInInlineNode',
			'<b>http://example.com</b>',
			'<b><a href="http://example.com">http://example.com</a></b>',
		);
	}

	public function testBasicUsageCase(): void {
		$this->assertLinkifyResult(
			'BasicUsageCase',
			'This URL http://example.com is what you need',
			'This URL <a href="http://example.com">http://example.com</a> is what you need',
		);
	}

	public function testIgnoreURLInATag(): void {
		$this->assertLinkifyResult('IgnoreURLInATag', '<a>http://example.com/</a>', '<a>http://example.com/</a>');
	}

	public function testExcludes(): void {
		$this->assertLinkifyResult(
			'Excludes',
			'<a><span>http://example.com</span></a>',
			'<a><span>http://example.com</span></a>',
		);
	}
}
