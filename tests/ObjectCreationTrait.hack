namespace HTMLPurifier\_Private\Tests;

use type HTMLPurifier\{HTMLPurifier_Lexer, HTMLPurifier_Config, HTMLPurifier_ConfigSchema, HTMLPurifier_Context};

trait ObjectCreationTrait {
    private function makeLexer(): HTMLPurifier_Lexer {
        return new HTMLPurifier_Lexer();
    }
    private function makeConfig(): HTMLPurifier_Config {
        return new HTMLPurifier_Config($this->makeConfigSchema());
    }
    private function makeConfigSchema(): HTMLPurifier_ConfigSchema {
        return new HTMLPurifier_ConfigSchema();
    }
    private function makeContext(): HTMLPurifier_Context {
        return new HTMLPurifier_Context();
    }
}