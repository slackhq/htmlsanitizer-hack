/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;
use namespace HH\Lib\C;
/**
 * Registry object that contains info about the current context.
 */
class HTMLPurifier_Context {
    private dict<string, mixed> $storage = dict[];
    public function __construct() {
        //
    }

    public function register(string $name, mixed $ref): void {
        $this->storage[$name] = $ref;
    }

    public function get(string $name, ?bool $ignore_error = false): mixed {
        if (C\contains_key($this->storage, $name)) {
            return $this->storage[$name];
        } else {
            return null;
        }
    }

    public function destroy(string $name): void {
        if (C\contains_key($this->storage, $name)) {
            \unset($this->storage[$name]);
        }
    }
}

