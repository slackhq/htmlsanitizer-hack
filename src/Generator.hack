/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;
use namespace Facebook\TypeAssert;
use namespace HH\Lib\{C, Str, Dict};

/**
 * Generates HTML from tokens.
 */
class HTMLPurifier_Generator {

    const TRIM_CHARLIST = " \t\n\r\0\x0B";

    //Whether or not generator should produce XML output.
    private bool $xhtml = true;

    //Whether or not generator should comment the insides of <script> tags.
    private bool $scriptFix = false;

    //Cache of HTML Definition during HTML output to determine whether or not attributes should be minimzed.
    private ?Definition\HTMLPurifier_HTMLDefinition $def;

    //Cache of %Output.SortAttr.
    private bool $sortAttr;

    //Cache of %Output.FlashCompat.
    private bool $flashCompat;

    //Cache of %Output.FixInnerHTML.
    private bool $innerHTMLFix;

    //Stack for keeping track of object information when outputting IE compatibility code.
    private vec<string> $flashStack = vec[];

    //Configuration for the generator
    protected HTMLPurifier_Config $config;


    public function __construct(HTMLPurifier_Config $config, HTMLPurifier_Context $context) {
        $this->config = $config;
        $this->scriptFix = $config->def->defaults['Output.CommentScriptContents'];
        $this->innerHTMLFix = $config->def->defaults['Output.FixInnerHTML'];
        $this->sortAttr = $config->def->defaults['Output.SortAttr'];
        $this->flashCompat = $config->def->defaults['Output.FlashCompat'];
        // This line takes ages to run
        $this->def = TypeAssert\instance_of(Definition\HTMLPurifier_HTMLDefinition::class, $config->getHTMLDefinition());
        $def_doctype = $this->def->doctype;
        if ($def_doctype is nonnull) {
            $this->xhtml = $def_doctype->xml;
        }
    }

    //Generates HTML from a vector of tokens.
    public function generateFromTokens(vec<HTMLPurifier_Token> $tokens): string {
        if (C\is_empty($tokens)) {
            return '';
        }

        //Basic algorithm
        $html = '';
        $size = C\count($tokens);
        for ($i = 0; $i < $size; $i++) {
            $curr_token = $tokens[$i];
            if ($curr_token is Token\HTMLPurifier_Token_Tag || $curr_token is Token\HTMLPurifier_Token_Text) {
                if ($this->scriptFix && $curr_token->name === 'script' && $i + 2 < $size && $tokens[$i+2] is Token\HTMLPurifier_Token_End) {
                    //script special case
                    $generated_from_token = $this->generateFromToken($tokens[$i]);
                    $i++;
                    $html .= $generated_from_token;
                    $generated_script_from_token = $this->generateScriptFromToken($tokens[$i]);
                    $i++;
                    $html .= $generated_script_from_token;
                }
            }
            $html .= $this->generateFromToken($tokens[$i]);
        }

        // Normalize newlines to system defined value
        if($this->config->def->defaults['Core.NormalizeNewlines']) {
            $nl = $this->config->def->defaults['Output.Newline'];
            if ($nl === '') {
                $nl = \PHP_EOL;
            }
            if ($nl !== "\n") {
                $html = Str\replace($nl, "\n", $html);
            }
        }
        return $html;
    }

    // Generates HTML from a single token.
    public function generateFromToken(HTMLPurifier_Token $token): string {
        if (!($token is HTMLPurifier_Token)) {
            echo "ERROR: Cannot generate HTML from non-HTMLPurifier_Token object";
            return '';
        } else if ($token is Token\HTMLPurifier_Token_Start) {
            $attr = $this->generateAttributes($token->attr, $token->name);
            if ($this->flashCompat) {
                if ($token->name == "object") {
                    throw new \Exception("Flashstack and stdClass not implemented");
                    // $flash = new \stdClass();
                    // $flash->attr = $token->attr;
                    // $flash->param = vec[];
                    // $this->flashStack = $flash;
                }
            }
            return '<' . $token->name . ($attr ? ' ' : '') . $attr . '>';
        } else if ($token is Token\HTMLPurifier_Token_End) {
            $_extra = '';
            if ($this->flashCompat) {
                if ($token->name == "object" && $this->flashStack) {
                    // doesn't do anything for now
                }
            }
            return $_extra . '</' . $token->name . '>';
        } else if ($token is Token\HTMLPurifier_Token_Empty) {
            if ($this->flashCompat && $token->name == "param" && $this->flashStack) {
                throw new \Exception("Flashstack not implemented");
                // $this->flashStack[C\count($this->flashStack)-1]->param[$token->attr['name']] = $token->attr['value'];
            }
            $attr = $this->generateAttributes($token->attr, $token->name);
            return '<' . $token->name . ($attr ? ' ' : '') . $attr .
                ( $this->xhtml ? ' /': '' ) // <br /> v. <br>
                . '>';
        } else if ($token is Token\HTMLPurifier_Token_Text) {
            return $this->escape($token->data, \ENT_NOQUOTES);
        } else if ($token is Token\HTMLPurifier_Token_Comment) {
            return '<!--' . $token->data . '-->';
        } else {
            return '';
        }
    }

    // Special case processor for the contents of script tags
    public function generateScriptFromToken(HTMLPurifier_Token $token): string {
        if (!($token is Token\HTMLPurifier_Token_Text)) {
            return $this->generateFromToken($token);
        }
        // Thanks <http://lachy.id.au/log/2005/05/script-comments>
        $data = \preg_replace('#//\s*$#', '', $token->data);
        return '<!--//--><![CDATA[//><!--' . "\n" . Str\trim($data) . "\n" . '//--><!]]>';
    }

    // Generates attribute declarations from attribute dictionary.
    public function generateAttributes(dict<string, mixed> $assoc_array_of_attributes, string $element = ''): string {
        $html = '';
        if ($this->sortAttr) {
            Dict\sort_by_key($assoc_array_of_attributes);
        }
        foreach ($assoc_array_of_attributes as $key => $value) {
            $value = (string)$value;
            if (!$this->xhtml) {
                // Remove namespaced attributes
                if (Str\search($key, ':') is nonnull) {
                    continue;
                }
                // Check if we should minimize the attribute: val="val" -> val
                $definition_check = $this->def;
                if ($element && $definition_check && $definition_check->info[$element]->attr[$key]->minimized) {
                    $html .= $key . ' ';
                    continue;
                }
            }
            // Workaround for Internet Explorer innerHTML bug.
            // Essentially, Internet Explorer, when calculating
            // innerHTML, omits quotes if there are no instances of
            // angled brackets, quotes or spaces.  However, when parsing
            // HTML (for example, when you assign to innerHTML), it
            // treats backticks as quotes.  Thus,
            //      <img alt="``" />
            // becomes
            //      <img alt=`` />
            // becomes
            //      <img alt='' />
            // Fortunately, all we need to do is trigger an appropriate
            // quoting style, which we do by adding an extra space.
            // This also is consistent with the W3C spec, which states
            // that user agents may ignore leading or trailing
            // whitespace (in fact, most don't, at least for attributes
            // like alt, but an extra space at the end is barely
            // noticeable).  Still, we have a configuration knob for
            // this, since this transformation is not necesary if you
            // don't process user input with innerHTML or you don't plan
            // on supporting Internet Explorer.
            if ($this->innerHTMLFix) {
                if (Str\search($value, '`') is nonnull) {
                    // check if correct quoting style would not already be
                    // triggered
                    // equivalent hack function (?)
                    if (\strcspn($value, '"\' <>') === Str\length($value)) {
                        // protect!
                        $value .= ' ';
                    }
                }
            }
            $html .= $key.'="'.$this->escape($value).'" ';
        }
        return Str\trim_right($html, $this::TRIM_CHARLIST);
    }

    // Escapes raw text data
    public function escape(string $string, int $quote = 0): string {
        // Workaround for APC bug on Mac Leopard reported by sidepodcast
        // http://htmlpurifier.org/phorum/read.php?3,4823,4846
        if ($quote is null) {
            $quote = \ENT_COMPAT;
        }
        return \htmlspecialchars($string, $quote, 'UTF-8');
    }
}
