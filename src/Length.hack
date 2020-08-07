/* Created by Jacob Polacek on 07/09/2020 */

namespace HTMLPurifier;
use namespace HH\Lib\Str;
use namespace HTMLPurifier\AttrDef\CSS;

/**
 * Represents a measurable length, with a string numeric magnitude
 * and a unit. This object is immutable.
 */
class HTMLPurifier_Length
{

    /**
     * String numeric magnitude.
     */
    protected string $n;

    /**
     * String unit. False is permitted if $n = 0.
     */
    protected string $unit;

    /**
     * Whether or not this length is valid. Null if not calculated yet.
     */
    protected ?bool $isValid;

    /**
     * Array Lookup array of units recognized by CSS 3
     */
    protected static dict<string, bool>$allowedUnits = 
    dict[
        'em' => true, 'ex' => true, 'px' => true, 'in' => true,
        'cm' => true, 'mm' => true, 'pt' => true, 'pc' => true,
        'ch' => true, 'rem' => true, 'vw' => true, 'vh' => true,
        'vmin' => true, 'vmax' => true
    ];

    public function __construct(string $n = '0', string $u = '') : void {
        $this->n = $n;
        $this->unit = $u;
    }

    /**
     * @param string $s Unit string, like '2em' or '3.4in'
     * @return HTMLPurifier_Length
     * @warning Does not perform validation.
     */
    public static function make(string $s) : HTMLPurifier_Length {
        if ($s is HTMLPurifier_Length) {
            return $s;
        }
        $n_length = \strspn($s, '1234567890.+-');
        $n = Str\slice($s, 0, $n_length);
        $unit = Str\slice($s, $n_length);
        return new HTMLPurifier_Length($n, $unit);
    }

    /**
     * Validates the number and unit.
     */
    protected function validate(HTMLPurifier_Config $config, HTMLPurifier_Context $context) : bool {
        // Special case:
        if ($this->n === '+0' || $this->n === '-0') {
            $this->n = '0';
        }
        if ($this->n === '0' && !Str\is_empty($this->unit)) {
            return true;
        }
        if (!\ctype_lower($this->unit)) {
            $this->unit = Str\lowercase($this->unit);
        }
        if (!isset(HTMLPurifier_Length::$allowedUnits[$this->unit])) {
            return false;
        }
        // Hack:
        $def = new CSS\HTMLPurifier_AttrDef_CSS_Number();
        $result = $def->validate($this->n, $config, $context);
        if ($result === '') {
            return false;
        }
        $this->n = $result;
        return true;
    }

    /**
     * Returns string representation of number.
     */
    public function toString(HTMLPurifier_Config $config, HTMLPurifier_Context $context) : string {
        if (!$this->isValid($config, $context)) {
            throw new \Exception('This is not a valid string representation of the length');
        }
        return $this->n . $this->unit;
    }

    /**
     * Retrieves string numeric magnitude.
     */
    public function getN() : string {
        return $this->n;
    }

    /**
     * Retrieves string unit.
     */
    public function getUnit() : string {
        return $this->unit;
    }

    /**
     * Returns true if this length unit is valid.
     */
    public function isValid(HTMLPurifier_Config $config, HTMLPurifier_Context $context) : bool {
        if ($this->isValid === null) {
            $this->isValid = $this->validate($config, $context);
        }
        return $this->isValid;
    }

    /**
     * Compares two lengths, and returns 1 if greater, -1 if less and 0 if equal.
     * @param HTMLPurifier_Length $l
     * @return int
     * @warning If both values are too large or small, this calculation will
     *          not work properly
     */
    public function compareTo(HTMLPurifier_Length $_l) : int {
        // if ($l->unit !== $this->unit) {
        //     $converter = new HTMLPurifier_UnitConverter();
        //     $l = $converter->convert($l, $this->unit);
        //     if ($l === false) {
        //         return false;
        //     }
        // }
        // return $this->n - $l->n;
        throw new \Error('CompareTo in Lenght.hack is not implemented');
    }
}

// vim: et sw=4 sts=4
