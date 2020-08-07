/* Created by Jacob Polacek on 06/17/2020 */

namespace HTMLPurifier\Strategy;
use namespace HTMLPurifier;

/**
 * Composite strategy that runs multiple strategies on tokens.
 */
abstract class HTMLPurifier_Strategy_Composite extends HTMLPurifier\HTMLPurifier_Strategy {

    /**
     * List of strategies to run tokens through.
     */
    protected vec<HTMLPurifier\HTMLPurifier_Strategy> $strategies = vec[];

    <<__Override>>
    public function execute(vec<HTMLPurifier\HTMLPurifier_Token> $tokens, 
        HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context) : 
        vec<HTMLPurifier\HTMLPurifier_Token> {
        foreach ($this->strategies as $strategy) {
            $tokens = $strategy->execute($tokens, $config, $context);
        }
        return $tokens;
    }
}