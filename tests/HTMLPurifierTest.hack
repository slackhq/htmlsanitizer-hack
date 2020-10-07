/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */

namespace HTMLPurifier\_Private\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{Strategy, Token, Lexer};

class HTMLPurifierTest extends HackTest {
	
	public function testMissingEndTags() : void {
		echo "\nrunning testMissingEndTags()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<b>Bold';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Bold</b>');
		echo "finished.\n\n";
	}

	public function testMaliciousCodeRemoved() : void {
		echo "\ntestMaliciousCodeRemoved()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<img src="javascript:evil();" onload="evil();" />';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('');
		echo "finished.\n\n";
	}

	public function testMaliciousCodeRemovedWithText() : void {
		echo "\ntestMaliciousCodeRemovedWithText()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<img src="javascript:evil();" onload="evil();" />hello';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('hello');
		echo "finished.\n\n";
	}

	public function testIllegalNestingFixed() : void {
		echo "\ntestIllegalNestingFixed()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<b>Inline <del>context <div>No block allowed</div></del></b>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Inline <del>context No block allowed</del></b>');
		echo "finished.\n\n";
	}

	public function testDeprecatedTagsConverted() : void {
		echo "\ntestDeprecatedTagsConverted()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<center>Centered</center>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<center>Centered</center>');
		echo "finished.\n\n";
	}

	public function testCSSValidated() : void {
		echo "\ntestCSSValidated()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<span style="color:#COW;float:around;text-decoration:blink;">Text</span>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<span>Text</span>');
		echo "finished.\n\n";
	}

	public function testRichFormattingPreserved() : void {
		echo "\ntestRichFormattingPreserved()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

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
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<table><caption>
	Cool table
  </caption>
  <tfoot><tr><th>I can do so much!</th>
	</tr></tfoot><tbody><tr><td style="font-size:16pt;color:#F00;font-family:sans-serif;text-align:center;">Wow</td>
  </tr></tbody></table>');
	}

	public function testDOM() : void {
		echo "\nrunning testDOM()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$context = new HTMLPurifier\HTMLPurifier_Context();

		$html = "<b>Bold";
		$lexer = new Lexer\HTMLPurifier_Lexer_DOMLex();
		$tokens = $lexer->tokenizeHTML($html, $config, $context);
		
		$expected_tokens = vec[
			new Token\HTMLPurifier_Token_Start("b", dict[]),
			new Token\HTMLPurifier_Token_Text("Bold"),
			new Token\HTMLPurifier_Token_End("b", dict[])];

		expect($tokens)->toHaveSameContentAs($expected_tokens);
		echo "finished.\n";
	}

	public function testStrategies() : void {
		echo "\nrunning testStrategies()...";
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$context = new HTMLPurifier\HTMLPurifier_Context();

		$remove_foreign_elements = new Strategy\HTMLPurifier_Strategy_RemoveForeignElements();
		$make_well_formed = new Strategy\HTMLPurifier_Strategy_MakeWellFormed();
		$fix_nesting = new Strategy\HTMLPurifier_Strategy_FixNesting();
		$validate_attributes = new Strategy\HTMLPurifier_Strategy_ValidateAttributes();

		$tokens = vec[new Token\HTMLPurifier_Token_Start("b", dict[]),
			new Token\HTMLPurifier_Token_Text("Text"),
			new Token\HTMLPurifier_Token_End("b", dict[])];

		$rfe_tokens = $remove_foreign_elements->execute($tokens, $config, $context);
		$mwf_tokens = $make_well_formed->execute($tokens, $config, $context);
		$fn_tokens = $fix_nesting->execute($tokens, $config, $context);
		$va_tokens = $validate_attributes->execute($tokens, $config, $context);

		expect($rfe_tokens)->toHaveSameContentAs($tokens);
		expect($mwf_tokens)->toHaveSameContentAs($tokens);
		expect($fn_tokens)->toHaveSameContentAs($tokens);
		expect($va_tokens)->toHaveSameContentAs($tokens);
		echo "finished.\n";
	}

	public function testPolicyAllowListUnClean(): void {
		echo "\nrunning testPolicyAllowListUnClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$config->def->defaults['HTML.Allowed'] = 'a';
		$dirty_html = '<b>Hello';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('Hello');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListUnCleanWithPolicyDict(): void {
		echo "\nrunning testPolicyAllowListUnCleanWithPolicyDict()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
  		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict["a"=>vec[]]);
		$dirty_html = '<b>Hello';
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('Hello');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListClean(): void {
		echo "\nrunning testPolicyAllowListClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$config->def->defaults['HTML.Allowed'] = 'b';
		$dirty_html = '<b>Hello';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<b>Hello</b>');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListWithAttributesRemoveExtra(): void {
		echo "\nrunning testPolicyAllowListWithAttributesRemoveExtra...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$config->def->defaults['HTML.Allowed'] = "div[align]";
		$dirty_html = '<div align="center" title="hi">Hello';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<div align="center">Hello</div>');
		echo "finished.\n\n";
	}

	public function testPolicyAllowListCleanAndUnclean(): void {
		echo "\nrunning testPolicyAllowListClean()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
  		$config->def->defaults['HTML.Allowed'] = "div[align]";
  		$dirty_html = '<div align="center" title="hi"><b>Hello</b>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<div align="center">Hello</div>');
		echo "finished.\n\n";
	}


	public function testSanitizeHtmlWithIframeForVideoPolicySet(): void {
		echo "\nrunning testSanitizeHtmlWithIframeForVideoPolicySet()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
  		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict["iframe"=>vec["title","width","height","src","allowfullscreen"]]);
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);


		$dirty_html = '<iframe src="https://www.example.com/watch?v=M84hFmNhTQU" height="364" width="576"></iframe>';
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<iframe src="https://www.example.com/watch?v=M84hFmNhTQU" height="364" width="576"></iframe>');
		echo "finished.\n\n";
	}

	public function testSanitizeHtmlWithIframeForSearchProtocolsPolicySet(): void {
		echo "\nrunning testSanitizeHtmlWithIframeForSearchProtocolsPolicySet()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
  		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict["iframe"=>vec["title","width","height","src","allowfullscreen"]]);
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
		expect($clean_html)->toEqual('<iframe title="Wildlife" width="500" height="400" src="//www.example.com" allowfullscreen="true"></iframe>');

		$dirty_html = '<iframe
			title="Wildlife"
			width="500"
			height="400"
			src="https://www.example.com/"
			allowfullscreen=true
			></iframe>';		
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<iframe title="Wildlife" width="500" height="400" src="https://www.example.com/" allowfullscreen="true"></iframe>');
		echo "finished.\n\n";
	}

	public function testMunge(): void {
		echo "\nrunning testMunge()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$config->def->defaults["URI.Munge"] = "/redirect.php?url=%s&check=%t";
		$config->def->defaults["URI.MungeSecretKey"] = "foo";
		// print($config);
		$dirty_html = '<a href="http://localhost">foo</a>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		expect($clean_html)->toEqual('<a href="/redirect.php?url=http%3A%2F%2Flocalhost&amp;check=c0efad89696082f5cb925d28636b0f4260f346391c92c70c8e9eba72591c2a73">foo</a>');
	}

	public function testPercentageHeightWidth() : void {
		echo "\nrunning testPercentageHeightWidth()...";
		//porting over first config classes....
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();

		$dirty_html = '<iframe src="https://example.com/videoclip/abc123?autoplay=true&origin=slack" height="100%" width="100%" allow="fullscreen" allowfullscreen="true" frameborder="0"></iframe>';
		$purifier = new HTMLPurifier\HTMLPurifier($config);
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<iframe src="https://example.com/videoclip/abc123?autoplay=true&amp;origin=slack" height="100%" width="100%" allowfullscreen="true"></iframe>';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}

	public function testWebappPolicy() : void {
		echo "\nrunning testWebappPolicy()...";
		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict[
			'b' => vec[],
			'ul'=> vec[],
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
			'img' => vec['src', 'alt', 'class', 'width', 'height', 'srcset', 'sizes']
			]
		);
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		expect(true)->toNotBeNull();
		echo "finished.\n\n";
	}

	public function testSpecialCharacterValidateUTF8() : void {
		echo "\nrunning testWebappPolicy()...";
		$policy = new HTMLPurifier\HTMLPurifier_Policy(dict[
			'b' => vec[],
			'ul'=> vec[],
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
			'img' => vec['src', 'alt', 'class', 'width', 'height', 'srcset', 'sizes']
			]
		);
		$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
		$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
		$dirty_html = '<h2>Guest accounts and shared channels</h2>
<h3>Guest accounts</h3>
<p>These are great for working with someone who feels like a member of your organization but needs only limited access to Slack.</p>
<p><strong>It’s important to note that guest accounts:</strong></p>
<ul>
<li>Are available for paid workspaces. Guests can belong to a single channel or multiple channels.</li>
<li>Can be invited to your workspace just like regular members via the invitations page.</li>
<li>Have icons by their profile photos: a triangle for single-channel guests and a square for multi-channel guests.</li>
</ul>
<h3>Shared channels</h3>
<p>Two separate organizations can work together in Slack, each from within their own Slack workspace.</p>
<p><strong>The benefits of shared channels include:</strong></p>
<ul>
<li>Working with external parties is as straightforward and fluid as working with your own colleagues. </li>
<li>Both teams have a common place to collaborate, loop in the right people on an as-needed basis, and build a collective repository of knowledge that anyone on either team can add to and reference.</li>
<li>Both teams can send messages, share files, and access the channel history.</li>
<li>Any member of the shared channel can also direct-message (DM) any other member in the channel, even if they’re from the other team.</li>
</ul>
<h2>Should I create a guest account or use a shared channel?</h2>
<p><strong>If you’re working with&#8230;</strong></p>
<ul>
<li>An individual &#8211; Then use a guest account</li>
<li>A team &#8211; Then use a shared channel</li>
</ul>
<p>More and more organizations are moving toward shared channels for the additional control and flexibility they provide—especially when collaborating with two or more people at another company.</p>
<h2>Guests vs. shared channels comparison</h2>
[aside headline="Who are you working with?" description="" bullets="Guests: Someone who feels like a member of your organization but needs limited access to Slack, such as contractors and interns | Shared channels: An external organization, like clients, vendors and partners. Both organizations need to be on a paid Slack plan. " /]
<p>&nbsp;</p>
[aside headline="How many people are involved?" description="" bullets="Guests: Only one or two people from the guest organization | Shared channels: Multiple people from each company are involved, with the ability to add members as work scales" /]
<p>&nbsp;</p>
[aside headline="Data access" description="" bullets="Guests: Only the host organization has access to the communication and files when the guest account expires | Shared channels: Each company keeps a record of the communication and files after the channel is disconnected" /]
<p>&nbsp;</p>
[aside headline="Security" description="" bullets="Guests: Only workspace admins or owners can invite or manage guest accounts | Shared channels: Users can initiate a shared channel by sharing an invitation link with their external partner. Depending on your settings, admins on both sides must approve the shared channel and can disconnect the shared channel at any time" /]
<p>&nbsp;</p>
[aside headline="Cost" description="" bullets="Guests: Teams get 5 free single-channel guests per paid active member, and multi-channel guests are billed as regular users | Shared channels: Unlimited number of shared channels at no cost" /]
<p>&nbsp;</p>
[aside headline="Ease of access" description="" bullets="Guests: Guests need to log into your organization&rsquo;s workspace, rather than using their own Slack workspace | Shared channels: People from other companies can collaborate in the shared channel right away from their own Slack workspace" /]
<p>&nbsp;</p>
[aside headline="Custom emoji" description="" bullets="Guests: Guests will have access to your full library of emoji | Shared channels: Custom emoji can be used and will be displayed to both teams. The other team can +1 a custom emoji of yours but can&rsquo;t see your set in their emoji picker" /]
<p>&nbsp;</p>
[aside headline="Direct messages" description="" bullets="Guests: Guests can DM only members of the channel(s) that they&rsquo;re in | Shared channels: You can DM or group DM anyone in a shared channel, including external members" /]
<p>&nbsp;</p>
[aside headline="Invites / admin management" description="" bullets="Guests: Admins must manually provision guest accounts one by one. Admins can choose an automatic expiration date for each guest account  | Shared channels: Once the shared channel is created, both teams can invite others from their workspace to join the channel as projects evolve and additional people need access" /]';
		$clean_html = $purifier->purify($dirty_html);
		$expected_html = '<h2>Guest accounts and shared channels</h2>
<h3>Guest accounts</h3>
<p>These are great for working with someone who feels like a member of your organization but needs only limited access to Slack.</p>
<p><strong>It’s important to note that guest accounts:</strong></p>
<ul><li>Are available for paid workspaces. Guests can belong to a single channel or multiple channels.</li>
<li>Can be invited to your workspace just like regular members via the invitations page.</li>
<li>Have icons by their profile photos: a triangle for single-channel guests and a square for multi-channel guests.</li>
</ul><h3>Shared channels</h3>
<p>Two separate organizations can work together in Slack, each from within their own Slack workspace.</p>
<p><strong>The benefits of shared channels include:</strong></p>
<ul><li>Working with external parties is as straightforward and fluid as working with your own colleagues. </li>
<li>Both teams have a common place to collaborate, loop in the right people on an as-needed basis, and build a collective repository of knowledge that anyone on either team can add to and reference.</li>
<li>Both teams can send messages, share files, and access the channel history.</li>
<li>Any member of the shared channel can also direct-message (DM) any other member in the channel, even if they’re from the other team.</li>
</ul><h2>Should I create a guest account or use a shared channel?</h2>
<p><strong>If you’re working with…</strong></p>
<ul><li>An individual – Then use a guest account</li>
<li>A team – Then use a shared channel</li>
</ul><p>More and more organizations are moving toward shared channels for the additional control and flexibility they provide—especially when collaborating with two or more people at another company.</p>
<h2>Guests vs. shared channels comparison</h2>
[aside headline="Who are you working with?" description="" bullets="Guests: Someone who feels like a member of your organization but needs limited access to Slack, such as contractors and interns | Shared channels: An external organization, like clients, vendors and partners. Both organizations need to be on a paid Slack plan. " /]
<p> </p>
[aside headline="How many people are involved?" description="" bullets="Guests: Only one or two people from the guest organization | Shared channels: Multiple people from each company are involved, with the ability to add members as work scales" /]
<p> </p>
[aside headline="Data access" description="" bullets="Guests: Only the host organization has access to the communication and files when the guest account expires | Shared channels: Each company keeps a record of the communication and files after the channel is disconnected" /]
<p> </p>
[aside headline="Security" description="" bullets="Guests: Only workspace admins or owners can invite or manage guest accounts | Shared channels: Users can initiate a shared channel by sharing an invitation link with their external partner. Depending on your settings, admins on both sides must approve the shared channel and can disconnect the shared channel at any time" /]
<p> </p>
[aside headline="Cost" description="" bullets="Guests: Teams get 5 free single-channel guests per paid active member, and multi-channel guests are billed as regular users | Shared channels: Unlimited number of shared channels at no cost" /]
<p> </p>
[aside headline="Ease of access" description="" bullets="Guests: Guests need to log into your organization’s workspace, rather than using their own Slack workspace | Shared channels: People from other companies can collaborate in the shared channel right away from their own Slack workspace" /]
<p> </p>
[aside headline="Custom emoji" description="" bullets="Guests: Guests will have access to your full library of emoji | Shared channels: Custom emoji can be used and will be displayed to both teams. The other team can +1 a custom emoji of yours but can’t see your set in their emoji picker" /]
<p> </p>
[aside headline="Direct messages" description="" bullets="Guests: Guests can DM only members of the channel(s) that they’re in | Shared channels: You can DM or group DM anyone in a shared channel, including external members" /]
<p> </p>
[aside headline="Invites / admin management" description="" bullets="Guests: Admins must manually provision guest accounts one by one. Admins can choose an automatic expiration date for each guest account  | Shared channels: Once the shared channel is created, both teams can invite others from their workspace to join the channel as projects evolve and additional people need access" /]';
		expect($clean_html)->toEqual($expected_html);
		echo "finished.\n\n";
	}
}
