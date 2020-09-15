/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\C;

<<__ConsistentConstruct>>
/**
 * Represents a language and defines localizable string formatting and
 * other functions, as well as the localized messages for HTML Purifier.
 */
 
class HTMLPurifier_Language {
    /**
    * ISO 639 language code of language. Prefers shortest possible version.
    */
    public string $code = 'en';

    /**
    * Shape containing three different keys, represented in string format
    * fallback: Fallback Language Code
    * messages: Array of localizable messages
    * errorNames: Array of localizable error codes
    */
    public dict<string, dict<string, string>> $string_to_var = dict[
        'fallback' => dict['fallback' => 'false'],
        'messages' => dict[],
        'errorNames' => dict[]
        ];

    /**
    * True is no message file was found for this language, so English is being
    * used instead. Check this if you'd like to notify the user that they've
    * used a non-supported language.
    */
    public bool $error = false;

    /**
    * Has the language object been loaded yet?
    * @todo Make it private, fix usage in HTMLPurifier_LanguageTest
    */
    public bool $_loaded = false;

    protected ?HTMLPurifier_Config $config;
    protected ?HTMLPurifier_Context $context;

    public function __construct(HTMLPurifier_Config $config, HTMLPurifier_Context $context) {
        $this->config = $config;
        $this->context = $context;
    }

    /**
     * Loads language object with necessary info from factory cache
     * @note This is a lazy loader
     */
    public function load() : void {
        if ($this->_loaded) {
            return;
        }
        $factory = HTMLPurifier_LanguageFactory::instance();
        $factory->loadLanguage($this->code);
        foreach ($factory->keys as $key) {
            if (C\contains_key($this->string_to_var, $key)) {
                $this->string_to_var[$key] = $factory->cache[$this->code][$key];
            }
        }

        $this->_loaded = true;
    }

    /**
    * Retrieves a localized message.
    * @todo: Look at what type messages should be 
    */
    public function getMessage(string $key) : string {
        if (!$this->_loaded) {
            $this->load();
        }
        if(!C\contains_key($this->string_to_var['messages'], $key)){
            return "[$key]";
        }
        return $this->string_to_var['messages'][$key];
    }

    /**
    * Retrieves a localised error name.
    */
    public function getErrorName(int $int) : string {
        if (!$this->_loaded) {
            $this->load();
        }
        // if (!isset($this->errorNames[$int])) {
        //     return "[Error: $int]";
        // }
        // return $this->errorNames[$int];
        return '';
    }

    /**
    * Converts an array list into a string readable representation
    */
    public function listify(dict<string, string> $dict) : string {
        $sep = $this->getMessage('Item separator');
        $sep_last = $this->getMessage('Item separator last');
        $ret = '';
        $c = C\count($dict);
        $i = 0;
        foreach ($dict as $_key => $value) {
            if ($i == 0) {
            } else if ($i + 1 < $c) {
                $ret .= $sep;
            } else {
                $ret .= $sep_last;
            }
            $ret .= $value;
            $i++;
        }
        return $ret;
    }

    /**
    * Formats a localised message with passed parameters
    * @todo from original documentation - Implement conditionals?
    */
    public function formatMessage(string $key, vec<string> $args = vec[]) : void{
        return;
    }
}
