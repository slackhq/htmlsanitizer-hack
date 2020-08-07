/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

abstract class HTMLPurifier_Token {
    public int $line = 0;
    public int $col = 0;
    public vec<string> $armor = vec[];

    public bool $skip = false;
    public bool $rewind = false;
    public bool $carryover = false;

    public function get(string $n): string {
        if ($n === 'type') {
            \trigger_error('Deprecated type property called; use instanceof', \E_USER_NOTICE);
            switch (\get_class($this)) {
                case 'HTMLPurifier_Token_Start':
                    return 'start';
                case 'HTMLPurifier_Token_Empty':
                    return 'empty';
                case 'HTMLPurifier_Token_End':
                    return 'end';
                case 'HTMLPurifier_Token_Text':
                    return 'text';
                case 'HTMLPurifier_Token_Comment':
                    return 'comment';
                default:
                    return '';
            }
        }
        return '';
    }

    public function position(int $l = 0, int $c = 0): void {
        $this->line = $l;
        $this->col = $c;
    }

    public function rawPosition(int $l, int $c): void {
        if ($c === -1) {
            $l++;
        }
        $this->line = $l;
        $this->col = $c;
    }

    abstract public function toNode(): HTMLPurifier_Node;

}
