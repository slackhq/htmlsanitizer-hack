/* Created by Jacob Polacek 07/09/2020 */

namespace HTMLPurifier\AttrDef\CSS;
use namespace HTMLPurifier;
use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\{C, Str};

/**
 * Microsoft's proprietary filter: CSS property
 * @note Currently supports the alpha filter. In the future, this will
 *       probably need an extensible framework
 */
class HTMLPurifier_AttrDef_CSS_Filter extends HTMLPurifier\HTMLPurifier_AttrDef {

    protected AttrDef\HTMLPurifier_AttrDef_Integer $intValidator;

    public function __construct() : void {
        $this->intValidator = new AttrDef\HTMLPurifier_AttrDef_Integer();
    }

    <<__Override>>
    public function validate(string $value, HTMLPurifier\HTMLPurifier_Config $config,
        HTMLPurifier\HTMLPurifier_Context $context) : string {
        $value = $this->parseCDATA($value);
        if ($value === 'none') {
            return $value;
        }
        // if we looped this we could support multiple filters
        $function_length = \strcspn($value, '(');
        $func_len_substr = Str\slice($value, 0, $function_length);
        $function = Str\trim($func_len_substr);
        if ($function !== 'alpha' &&
            $function !== 'Alpha' &&
            $function !== 'progid:DXImageTransform.Microsoft.Alpha'
        ) {
            return '';
        }
        $cursor = $function_length + 1;
        $parameters_length = \strcspn($value, ')', $cursor);
        $parameters = Str\slice($value, $cursor, $parameters_length);
        $params = Str\split($parameters, ',');
        $ret_params = vec[];
        $lookup = dict[];
        foreach ($params as $param) {
            list($key, $value) = Str\split($param, '=');
            $key = Str\trim($key);
            $value = Str\trim($value);
            if (C\contains_key($lookup, $key)) {
                continue;
            }
            if ($key !== 'opacity') {
                continue;
            }
            $value = $this->intValidator->validate($value, $config, $context);
            if ($value === '') {
                continue;
            }
            $int = (int)$value;
            if ($int > 100) {
                $value = '100';
            }
            if ($int < 0) {
                $value = '0';
            }
            $ret_params[] = "$key=$value";
            $lookup[$key] = true;
        }
        $ret_parameters = Str\join($ret_params, ',');
        $ret_function = "$function($ret_parameters)";
        return $ret_function;
    }
}
