/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;
use Facebook\TypeAssert;

/**
 * Injector that auto paragraphs text in the root node based on
 * double-spacing.
 * @todo Ensure all states are unit tested, including variations as well.
 * @todo Make a graph of the flow control for this Injector.
 */
class HTMLPurifier_Injector_AutoParagraph extends HTMLPurifier\HTMLPurifier_Injector
{
    /**
     * @type string
     */
    public string $name = 'AutoParagraph';

    /**
     * @type array
     */
    public dict<string, vec<string>> $needed = dict['p' => vec[]];

    /**
     * @return HTMLPurifier_Token_Start
     */
    private function _pStart() : Token\HTMLPurifier_Token_Start{
        $par = new Token\HTMLPurifier_Token_Start('p');
        $par->armor[] = 'MakeWellFormed_TagClosedError';
        return $par;
    }

    /**
     * @param HTMLPurifier_Token_Text $token
     */
    public function handleText(HTMLPurifier\HTMLPurifier_Token $token) : mixed {
        if (!($token is Token\HTMLPurifier_Token_Text)) {
            throw new \Exception("Token needs to have a data field");
        }
        $text = $token->data;
        // Does the current parent allow <p> tags?
        if ($this->allowsElement('p')) {
            if (!C\count($this->currentNesting) || Str\search($text, "\n\n")) {
                // Note that we have differing behavior when dealing with text
                // in the anonymous root node, or a node inside the document.
                // If the text as a double-newline, the treatment is the same;
                // if it doesn't, see the next if-block if you're in the document.

                $i = 0;
                $nesting = 0;
                $current = $token;
                if (!$this->forwardUntilEndToken(inout $i, inout $current, inout $nesting) && $token->is_whitespace) {
                    // State 1.1: ...    ^ (whitespace, then document end)
                    //               ----
                    // This is a degenerate case
                } else {
                    if (!$token->is_whitespace || $this->_isInline(inout $current)) {
                        // State 1.2: PAR1
                        //            ----

                        // State 1.3: PAR1\n\nPAR2
                        //            ------------

                        // State 1.4: <div>PAR1\n\nPAR2 (see State 2)
                        //                 ------------
                        $token = vec[$this->_pStart()];
                        $this->_splitText($text, inout $token);
                    } else {
                        // State 1.5: \n<hr />
                        //            --
                    }
                }
            } else {
                // State 2:   <div>PAR1... (similar to 1.4)
                //                 ----

                // We're in an element that allows paragraph tags, but we're not
                // sure if we're going to need them.
                if ($this->_pLookAhead()) {
                    // State 2.1: <div>PAR1<b>PAR1\n\nPAR2
                    //                 ----
                    // Note: This will always be the first child, since any
                    // previous inline element would have triggered this very
                    // same routine, and found the double newline. One possible
                    // exception would be a comment.
                    $token = vec[$this->_pStart(), $token];
                } else {
                    // State 2.2.1: <div>PAR1<div>
                    //                   ----

                    // State 2.2.2: <div>PAR1<b>PAR1</b></div>
                    //                   ----
                }
            }
            // Is the current parent a <p> tag?
        } elseif (!C\count($this->currentNesting)) {
            $currentNestingToken = $this->currentNesting[C\count($this->currentNesting) - 1];
            if (($currentNestingToken is Token\HTMLPurifier_Token_Tag || $currentNestingToken is Token\HTMLPurifier_Token_Text) &&
                $currentNestingToken->name == 'p') {
                // State 3.1: ...<p>PAR1
                //                  ----

                // State 3.2: ...<p>PAR1\n\nPAR2
                //                  ------------
                $token = vec[];
                $this->_splitText($text, inout $token);
                // Abort!
            } else {
                throw new \Exception("Token in handleText in AutoParagraph needs to have a name field");
            }
        } else {
            // State 4.1: ...<b>PAR1
            //                  ----

            // State 4.2: ...<b>PAR1\n\nPAR2
            //                  ------------
        }
        return $token;
    }

    /**
     * @param HTMLPurifier_Token $token
     */
    public function handleElement(HTMLPurifier\HTMLPurifier_Token $token) : mixed {
        // We don't have to check if we're already in a <p> tag for block
        // tokens, because the tag would have been autoclosed by MakeWellFormed.
        if ($this->allowsElement('p')) {
            if (!C\is_empty($this->currentNesting)) {
                if ($this->_isInline(inout $token)) {
                    // State 1: <div>...<b>
                    //                  ---
                    // Check if this token is adjacent to the parent token
                    // (seek backwards until token isn't whitespace)
                    $i = 0;
                    $prev = $token;
                    $this->backward(inout $i, inout $prev);

                    if (!$prev is Token\HTMLPurifier_Token_Start) {
                        // Token wasn't adjacent
                        if ($prev is Token\HTMLPurifier_Token_Text &&
                            Str\slice($prev->data, -2) === "\n\n"
                        ) {
                            // State 1.1.4: <div><p>PAR1</p>\n\n<b>
                            //                                  ---
                            // Quite frankly, this should be handled by splitText
                            $token = vec[$this->_pStart(), $token];
                        } else {
                            // State 1.1.1: <div><p>PAR1</p><b>
                            //                              ---
                            // State 1.1.2: <div><br /><b>
                            //                         ---
                            // State 1.1.3: <div>PAR<b>
                            //                      ---
                        }
                    } else {
                        // State 1.2.1: <div><b>
                        //                   ---
                        // Lookahead to see if <p> is needed.
                        if ($this->_pLookAhead()) {
                            // State 1.3.1: <div><b>PAR1\n\nPAR2
                            //                   ---
                            $token = vec[$this->_pStart(), $token];
                        } else {
                            // State 1.3.2: <div><b>PAR1</b></div>
                            //                   ---

                            // State 1.3.3: <div><b>PAR1</b><div></div>\n\n</div>
                            //                   ---
                        }
                    }
                } else {
                    // State 2.3: ...<div>
                    //               -----
                }
            } else {
                if ($this->_isInline(inout $token)) {
                    // State 3.1: <b>
                    //            ---
                    // This is where the {p} tag is inserted, not reflected in
                    // inputTokens yet, however.
                    $token = vec[$this->_pStart(), $token];
                } else {
                    // State 3.2: <div>
                    //            -----
                }

                $i = 0;
                $prev = TypeAssert\matches<HTMLPurifier\HTMLPurifier_Token>($token);
                if ($this->backward(inout $i, inout $prev)) {
                    if (!$prev is Token\HTMLPurifier_Token_Text) {
                        // State 3.1.1: ...</p>{p}<b>
                        //                        ---
                        // State 3.2.1: ...</p><div>
                        //                     -----
                        if (!($token is vec<_>)) {
                            $token = vec[$token];
                        }
                        \array_unshift(inout $token, new Token\HTMLPurifier_Token_Text("\n\n"));
                    } else {
                        // State 3.1.2: ...</p>\n\n{p}<b>
                        //                            ---
                        // State 3.2.2: ...</p>\n\n<div>
                        //                         -----
                        // Note: PAR<ELEM> cannot occur because PAR would have been
                        // wrapped in <p> tags.
                    }
                }
            }
        } else {
            // State 2.2: <ul><li>
            //                ----
            // State 2.4: <p><b>
            //               ---
        }
        return $token;
    }

    <<__Override>>
    public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token) : void {
    }

    /**
     * Splits up a text in paragraph tokens and appends them
     * to the result stream that will replace the original
     * @param string $data String text data that will be processed
     *    into paragraphs
     * @param HTMLPurifier_Token[] $result Reference to array of tokens that the
     *    tags will be appended onto
     */
    private function _splitText(string $data, inout vec<HTMLPurifier\HTMLPurifier_Token> $result) : void {
        $raw_paragraphs = Str\split($data, "\n\n");
        $paragraphs = vec[]; // without empty paragraphs
        $needs_start = false;
        $needs_end = false;

        $c = C\count($raw_paragraphs);
        if ($c == 1) {
            // There were no double-newlines, abort quickly. In theory this
            // should never happen.
            $result[] = new Token\HTMLPurifier_Token_Text($data);
            return;
        }
        for ($i = 0; $i < $c; $i++) {
            $par = $raw_paragraphs[$i];
            if (Str\trim($par) !== '') {
                $paragraphs[] = $par;
            } else {
                if ($i == 0) {
                    // Double newline at the front
                    if (C\is_empty($result)) {
                        // The empty result indicates that the AutoParagraph
                        // injector did not add any start paragraph tokens.
                        // This means that we have been in a paragraph for
                        // a while, and the newline means we should start a new one.
                        $result[] = new Token\HTMLPurifier_Token_End('p');
                        $result[] = new Token\HTMLPurifier_Token_Text("\n\n");
                        // However, the start token should only be added if
                        // there is more processing to be done (i.e. there are
                        // real paragraphs in here). If there are none, the
                        // next start paragraph tag will be handled by the
                        // next call to the injector
                        $needs_start = true;
                    } else {
                        // We just started a new paragraph!
                        // Reinstate a double-newline for presentation's sake, since
                        // it was in the source code.
                        \array_unshift(inout $result, new Token\HTMLPurifier_Token_Text("\n\n"));
                    }
                } elseif ($i + 1 == $c) {
                    // Double newline at the end
                    // There should be a trailing </p> when we're finally done.
                    $needs_end = true;
                }
            }
        }

        // Check if this was just a giant blob of whitespace. Move this earlier,
        // perhaps?
        if (C\is_empty($paragraphs)) {
            return;
        }

        // Add the start tag indicated by \n\n at the beginning of $data
        if ($needs_start) {
            $result[] = $this->_pStart();
        }

        // Append the paragraphs onto the result
        foreach ($paragraphs as $par) {
            $result[] = new Token\HTMLPurifier_Token_Text($par);
            $result[] = new Token\HTMLPurifier_Token_End('p');
            $result[] = new Token\HTMLPurifier_Token_Text("\n\n");
            $result[] = $this->_pStart();
        }

        // Remove trailing start token; Injector will handle this later if
        // it was indeed needed. This prevents from needing to do a lookahead,
        // at the cost of a lookbehind later.
        $resultLength = C\count($result);
        $result = Vec\take($result, $resultLength - 1);

        // If there is no need for an end tag, remove all of it and let
        // MakeWellFormed close it later.
        if (!$needs_end) {
            $result = Vec\take($result, $resultLength - 2); // removes \n\n
            $result = Vec\take($result, $resultLength - 3); // removes </p>
        }
    }

    /**
     * Returns true if passed token is inline (and, ergo, allowed in
     * paragraph tags)
     * @param HTMLPurifier_Token $token
     * @return bool
     */
    private function _isInline(inout HTMLPurifier\HTMLPurifier_Token $token) : bool {
        $def = $this->htmlDefinition;
        if ($def is null) {
            throw new \Exception("Definition should be nonnull in autoparagrah.");
        }
        if (!($token is Token\HTMLPurifier_Token_Text || $token is Token\HTMLPurifier_Token_Tag)) {
            throw new \Exception("Token should have a name field in autoparagraph.");
        }
        return C\contains_key($def->info['p']->child->elements, $token->name);
    }

    /**
     * Looks ahead in the token list and determines whether or not we need
     * to insert a <p> tag.
     * @return bool
     */
    private function _pLookAhead() : bool {
        if ($this->currentToken is Token\HTMLPurifier_Token_Start) {
            $nesting = 1;
        } else {
            $nesting = 0;
        }
        $ok = false;
        $i = 0;
        $current = TypeAssert\matches<HTMLPurifier\HTMLPurifier_Token>($this->currentToken);
        while ($this->forwardUntilEndToken(inout $i, inout $current, inout $nesting)) {
            $result = $this->_checkNeedsP($current);
            if ($result !== null) {
                $ok = $result;
                break;
            }
        }
        return $ok;
    }

    /**
     * Determines if a particular token requires an earlier inline token
     * to get a paragraph. This should be used with _forwardUntilEndToken
     * @param HTMLPurifier_Token $current
     * @return bool
     */
    private function _checkNeedsP(HTMLPurifier\HTMLPurifier_Token $current) : ?bool {
        if ($current is Token\HTMLPurifier_Token_Start) {
            if (!$this->_isInline(inout $current)) {
                // <div>PAR1<div>
                //      ----
                // Terminate early, since we hit a block element
                return false;
            }
        } elseif ($current is Token\HTMLPurifier_Token_Text) {
            if (Str\search($current->data, "\n\n")) {
                // <div>PAR1<b>PAR1\n\nPAR2
                //      ----
                return true;
            } else {
                // <div>PAR1<b>PAR1...
                //      ----
            }
        }
        return null;
    }
}
