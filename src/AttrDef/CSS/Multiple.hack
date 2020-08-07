/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

/**
 * Framework class for strings that involve multiple values.
 *
 * Certain CSS properties such as border-width and margin allow multiple
 * lengths to be specified.  This class can take a vanilla border-width
 * definition and multiply it, usually into a max of four.
 *
 * @note Even though the CSS specification isn't clear about it, inherit
 *       can only be used alone: it will never manifest as part of a multi
 *       shorthand declaration.  Thus, this class does not allow inherit.
 */
class HTMLPurifier_AttrDef_CSS_Multiple extends HTMLPurifier\HTMLPurifier_AttrDef {
    /**
     * Instance of component definition to defer validation to.
     */
    public HTMLPurifier\HTMLPurifier_AttrDef $single;

    /**
     * Max number of values allowed.
     */
    public int $max;

    public function __construct(HTMLPurifier\HTMLPurifier_AttrDef $single, int $max = 4) : void {
        $this->single = $single;
        $this->max = $max;
    }

    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        $string = $this->mungeRgb($this->parseCDATA($string));
        if ($string === '') {
            return '';
        }
        $parts = Str\split($string, ' '); // parseCDATA replaced \r, \t and \n
        $length = C\count($parts);
        $final = '';
        for ($i = 0, $num = 0; $i < $length && $num < $this->max; $i++) {
            if (\ctype_space($parts[$i])) {
                continue;
            }
            $result = $this->single->validate($parts[$i], $config, $context);
            if ($result !== '') {
                $final .= $result . ' ';
                $num++;
            }
        }
        if ($final === '') {
            return '';
        }
        return Str\trim_right($final);
    }
}
