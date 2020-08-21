/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, Definition};
use namespace HH\Lib\{C, Str};

/**
 * Validates an integer representation of pixels according to the HTML spec.
 */
class HTMLPurifier_AttrDef_HTML_Pixels extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * @type int
     */
    protected ?int $max;

    /**
     * @param int $max
     */
    public function __construct(?int $max = null)
    {
        $this->max = $max;
    }

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): string {
        $string = Str\trim($string);
        if ($string === '0') {
            return $string;
        }
        if ($string === '') {
            return '';
        }
        $length = Str\length($string);
        $is_percent = false;
        if (Str\slice($string, $length - 2) == 'px') {
            $string = Str\slice($string, 0, $length - 2);
        }
        else if (Str\slice($string, $length - 1) === '%') {
            $string = Str\slice($string, 0, $length - 1) . "p";
            $percent = new AttrDef\CSS\HTMLPurifier_AttrDef_CSS_Percentage();
            return $percent->validate($string, $config, $context);
        }
        if (!\ctype_digit($string)) {
            return '';
        }
        $int = (int)$string;

        if ($int < 0) {
            return '0';
        }

        // upper-bound value, extremely high values can
        // crash operating systems, see <http://ha.ckers.org/imagecrash.html>
        // WARNING, above link WILL crash you if you're using Windows

        if ($this->max !== null && $int > $this->max) {
            return (string)$this->max;
        }
        return (string)$int;
    }

    /**
     * @param string $string
     * @return HTMLPurifier_AttrDef
     */
    public function make(string $string): HTMLPurifier\HTMLPurifier_AttrDef {
        if ($string === '') {
            $max = 0;
        } else {
            $max = (int)$string;
        }
        return new HTMLPurifier_AttrDef_HTML_Pixels($max);
    }
}