/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\Lexer;

use namespace HTMLPurifier;
use namespace HH\Lib\{C, Regex, Str};
use namespace HTMLPurifier\Token;

/**
 * Parser that uses Hacklang DOMNode.
 */
class HTMLPurifier_Lexer_DOMLex extends HTMLPurifier\HTMLPurifier_Lexer {
	private HTMLPurifier\HTMLPurifier_TokenFactory $factory;

	//set up factory
	public function __construct() {
		parent::__construct();
		$this->factory = new HTMLPurifier\HTMLPurifier_TokenFactory();
	}

	public function muteErrorHandler(): void {
	}

	public function tokenizeHTML(
		string $html,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): vec<HTMLPurifier\HTMLPurifier_Token> {
		$html = $this->normalize($html, $config, $context);
		// attempt to armor stray angled brackets that cannot possibly
		// form tags and thus are probably being used as emoticons
		if ($config->def->defaults['Core.AggressivelyFixLt']) {
			$__unused_var = null;
			$char = '[^a-z!\/]';
			$comment = re"/<!--(?<comment>.*?)(?:[^-->$^<!--]+|(?R))*+(?<close>-->|\z)/is";
			$html = Regex\replace_with(
				$html,
				$comment,
				$match ==> $this->callbackArmorCommentEntities($match['comment'], $match['close']),
			);
			do {
				$old = $html;
				$html = \preg_replace("/<($char)/i", '&lt;\\1', $html);
			} while ($html !== $old);
			$html = Regex\replace_with(
				$html,
				$comment,
				$match ==> $this->callbackUndoCommentSubst($match['comment'], $match['close']),
			);
		}

		//preprocess html, essential for UTF-8
		$html = $this->wrapHTML($html, $config, $context);

		$doc = new \DOMDocument();
		$doc->encoding = 'UTF-8';

		$options = 0;
		// if ($config->get('Core.AllowParseManyTags') && \defined('LIBXML_PARSEHUGE')) {
		//     //bit wise OR operator
		//     //need to clarify what we need to set libxml_pargehuge
		//     $options = $options | \LIBXML_PARSEHUGE;
		// }

		\set_error_handler(meth_caller(HTMLPurifier_Lexer_DOMLex::class, 'muteErrorHandler'));
		$doc->loadHTML($html, $options);
		\restore_error_handler();
		$body = $doc->getElementsByTagName('html')
			->item(0)
			-> //<html>
			getElementsByTagName('body')
			->item(0); //<body> 
		$div = $body->getElementsByTagName('div')->item(0); //<div>

		$tokens = vec[];
		$this->tokenizeDOM($div, inout $tokens, $config);

		if ($div->nextSibling) {
			$body->removeChild($div);
			$this->tokenizeDOM($body, inout $tokens, $config);
		}

		return $tokens;
	}

	public function tokenizeDOM(
		\DOMNode $node,
		inout vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		HTMLPurifier\HTMLPurifier_Config $config,
	): void {
		$level = 0;
		$nodesQueue = new \SplQueue();
		$nodesQueue->push($node);
		$nodes = dict[$level => $nodesQueue];
		$closingNodes = dict[];

		do {
			while (!$nodes[$level]->isEmpty()) {
				$node = $nodes[$level]->dequeue();
				$collect = $level > 0 ? true : false;
				$needEndingTag = $this->createStartNode($node, inout $tokens, $collect, $config);
				if ($needEndingTag) {
					$nodesAtlevel = new \SplStack();
					$closingNodes[$level] = $nodesAtlevel;
					$nodesAtlevel->push($node);
				}
				if ($node->childNodes && $node->childNodes->length) {
					$level += 1;
					$nodes[$level] = new \SplQueue();
					foreach ($node->childNodes as $childNode) {
						$nodes[$level]->enqueue($childNode);
					}
				}
			}
			$level -= 1;
			if ($level && C\contains_key($closingNodes, $level)) {
				// while ($node = $closingNodes[$level]->pop()) {
				//     $this->createEndNode($node, inout $tokens);
				// }
				while (!$closingNodes[$level]->isEmpty()) {
					$node = $closingNodes[$level]->pop();
					$this->createEndNode($node, inout $tokens);
				}
			}
		} while ($level > 0);
	}

	protected function getData(\DOMNode $node): string {
		return $node->textContent;
	}

	protected function getTagName(\DOMNode $node): string {
		return $node->nodeName;
		//why not localName?
	}

	/*takes in node to be tokenized, array list of already tokenized tokens and bool collect which says whether 
	* start and close are collected, set to false at first recursion because we are dealing with the implicit DIV tag
	*/
	protected function createStartNode(
		\DOMNode $node,
		inout vec<HTMLPurifier\HTMLPurifier_Token> $tokens,
		bool $collect,
		HTMLPurifier\HTMLPurifier_Config $config,
	): bool {
		if ($node->nodeType === \XML_TEXT_NODE) {
			$data = $this->getData($node);
			if ($data) {
				$tokens[] = $this->factory->createText($data);
			}
			return false;
		} else if ($node->nodeType === \XML_CDATA_SECTION_NODE) {
			# undo libxml's special treatment of <script> and <style> tags
			$last = C\lastx($tokens);
			//php version uses node->data, Hack doesn't have data field
			$data = $node->nodeValue;
			if ($last is Token\HTMLPurifier_Token_Start && ($last->name == 'script' || $last->name == 'style')) {
				$new_data = Str\trim($data);
				if (Str\slice($new_data, 0, 4) === '<!--') {
					$data = Str\slice($new_data, 4);
					if (Str\slice($data, -3) === '-->') {
						$data = Str\slice($data, 0, -3);
					}
				}
			}
			$tokens[] = $this->factory->createText($this->parseText($data, $config));
			return false;
		} else if ($node->nodeType !== \XML_ELEMENT_NODE) {
			return false;
		}

		$attr = $node->hasAttributes() ? $this->transformAttrToAssoc($node->attributes) : dict<string, string>[];
		//not sure if hack domnode's have tag name
		$tag_name = $this->getTagName($node);
		if (!$tag_name) {
			$numChildren = $node->childNodes->length;
			if ($numChildren === 0) {
				return false;
			}
			return true;
		}

		if (!$node->childNodes->length) {
			if ($collect) {
				$tokens[] = $this->factory->createEmpty($tag_name, $attr);
			}
			return false;
		} else {
			if ($collect) {
				$tokens[] = $this->factory->createStart($tag_name, $attr);
			}
			return true;
		}
	}

	protected function createEndNode(\DOMNode $node, inout vec<HTMLPurifier\HTMLPurifier_Token> $tokens): void {
		$tag_name = $this->getTagName($node);
		$tokens[] = $this->factory->createEnd($tag_name);
	}

	// Converts a DOMNamedNodeMap of DOMAttr objects into an assoc array.
	protected function transformAttrToAssoc(?\DOMNamedNodeMap<\DOMAttr> $node_map): dict<string, string> {
		$node_map = $node_map;
		if ($node_map is null) {
			throw new \Exception('Node Map should be nonnull, but it is null');
		}
		if ($node_map->length === 0) {
			return dict[];
		}
		$array = dict[];
		foreach ($node_map as $key => $value) {
			$array[$key] = $value->nodeValue;
		}

		return $array;
	}

	//callback function for undoing escaping of stray 
	public function callbackUndoCommentSubst(string $comment_content, string $closing_marker): string {
		return '<!--'.Str\replace_every($comment_content, dict['&amp;' => '&', '&lt' => '<']).$closing_marker;
	}

	// callback function that entity-izes ampersands in comments so that callbackUndoCommentSubst doesn't clobber them
	public function callbackArmorCommentEntities(string $comment_content, string $closing_marker): string {
		return '<!--'.Str\replace('&', '&amp;', $comment_content).$closing_marker;
	}

	//wraps an HTML fragment in the necessary HTML
	protected function wrapHTML(
		string $html,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $_context,
		?bool $use_div = true,
	): string {
		$def = $config->getDefinition('HTML');
		$ret = '';

		//if it contains a definition and definition doctype, check its public and system strings to append
		if ($def && ($def->doctype) && ($def->doctype->dtdPublic || $def->doctype->dtdSystem)) {
			$ret .= '<!DOCTYPE html ';
			if ($def->doctype->dtdPublic) {
				$ret .= 'PUBLIC "'.$def->doctype->dtdPublic.'" ';
			}
			if ($def->doctype->dtdSystem) {
				$ret .= '"'.$def->doctype->dtdSystem.'" ';
			}
			$ret .= '>';
		}

		$ret .= '<html><head>';
		$ret .= '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
		// No protection if $html contains a stray </div>!
		$ret .= '</head><body>';
		if ($use_div) $ret .= '<div>';
		$ret .= $html;
		if ($use_div) $ret .= '</div>';
		$ret .= '</body></html>';
		return $ret;
	}
}
