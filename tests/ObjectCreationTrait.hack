namespace HTMLPurifier\_Private\Tests;

use type HTMLPurifier\{HTMLPurifier_Lexer, HTMLPurifier_Config, HTMLPurifier_ConfigSchema, HTMLPurifier_Context};
use type HTMLPurifier\Lexer\HTMLPurifier_Lexer_DOMLex;

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
	private function makeDOMLex(): HTMLPurifier_Lexer_DOMLex {
		return new HTMLPurifier_Lexer_DOMLex();
	}
}
