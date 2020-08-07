/* Created by Jacob Polacek 07/08/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Represents a Length as defined by CSS.
 */
class HTMLPurifier_AttrDef_CSS_Length extends HTMLPurifier\HTMLPurifier_AttrDef {

    /**
     * @type HTMLPurifier_Length|string
     */
    protected ?HTMLPurifier\HTMLPurifier_Length $min;

    /**
     * @type HTMLPurifier_Length|string
     */
    protected ?HTMLPurifier\HTMLPurifier_Length $max;

    /**
     * @param HTMLPurifier_Length|string $min Minimum length, or null for no bound. String is also acceptable.
     * @param HTMLPurifier_Length|string $max Maximum length, or null for no bound. String is also acceptable.
     */
    public function __construct(?string $min = null, ?string $max = null) : void {
        $this->min = $min !== null ? HTMLPurifier\HTMLPurifier_Length::make($min) : null;
        $this->max = $max !== null ? HTMLPurifier\HTMLPurifier_Length::make($max) : null;
    }

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
    public function validate(string $string, HTMLPurifier\HTMLPurifier_Config $config, 
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        $string = $this->parseCDATA($string);

        // Optimizations
        if ($string === '') {
            return '';
        }
        if ($string === '0') {
            return '0';
        }
        if (Str\length($string) === 1) {
            return '';
        }

        $length = HTMLPurifier\HTMLPurifier_Length::make($string);
        if (!$length->isValid($config, $context)) {
            return '';
        }

        if ($this->min) {
            $c = $length->compareTo($this->min);
            if ($c < 0) {
                return '';
            }
        }
        if ($this->max) {
            $c = $length->compareTo($this->max);
            if ($c > 0) {
                return '';
            }
        }
        return $length->toString($config, $context);
    }
}
