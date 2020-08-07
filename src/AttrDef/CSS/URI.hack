/* Created by Jacob Polacek 07/09/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\Str;

/**
 * Validates a URI in CSS syntax, which uses url('http://example.com')
 * @note While theoretically speaking a URI in a CSS document could
 *       be non-embedded, as of CSS2 there is no such usage so we're
 *       generalizing it. This may need to be changed in the future.
 * @warning Since HTMLPurifier_AttrDef_CSS blindly uses semicolons as
 *          the separator, you cannot put a literal semicolon in
 *          in the URI. Try percent encoding it, in that case.
 */
class HTMLPurifier_AttrDef_CSS_URI extends AttrDef\HTMLPurifier_AttrDef_URI {

    public function __construct() : void {
        parent::__construct(true); // always embedded
    }

    public function validate(string $uri_string, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        // parse the URI out of the string and then pass it onto
        // the parent object

        $uri_string = $this->parseCDATA($uri_string);
        if (Str\search($uri_string, 'url(') !== 0) {
            return '';
        }
        $uri_string = Str\slice($uri_string, 4);
        if (Str\length($uri_string) === 0) {
            return '';
        }
        $new_length = Str\length($uri_string) - 1;
        if ($uri_string[$new_length] != ')') {
            return '';
        }
        $uri_string_substr = Str\slice($uri_string, 0, $new_length);
        $uri = Str\trim($uri_string_substr);

        if (!Str\is_empty($uri) && ($uri[0] == "'" || $uri[0] == '"')) {
            $quote = $uri[0];
            $new_length = Str\length($uri) - 1;
            if ($uri[$new_length] !== $quote) {
                return '';
            }
            $uri = Str\slice($uri, 1, $new_length - 1);
        }

        $uri = $this->expandCSSEscape($uri);

        $result = parent::validate($uri, $config, $context);

        if ($result === '') {
            return '';
        }

        // extra sanity check; should have been done by URI
        $result = Str\replace_every($result, dict['"' => "", "\\" => "", "\n" => "", "\x0c" => "", "\r" => ""]);

        // suspicious characters are ()'; we're going to percent encode
        // them for safety.
        $result = Str\replace_every($result, dict['(' => '%28', ')' => '%29', "'" => '%27']);

        // there's an extra bug where ampersands lose their escaping on
        // an innerHTML cycle, so a very unlucky query parameter could
        // then change the meaning of the URL.  Unfortunately, there's
        // not much we can do about that...
        return "url(\"$result\")";
    }
}
