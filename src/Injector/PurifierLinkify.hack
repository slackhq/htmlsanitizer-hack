/* Created by Jacob Polacek on 08/10/2020 */

namespace HTMLPurifier\Injector;
use namespace HH\Lib\{C, Str, Vec};
use namespace HTMLPurifier;
use namespace HTMLPurifier\Token;

/**
 * Injector that converts configuration directive syntax %Namespace.Directive
 * to links
 */
class HTMLPurifier_Injector_PurifierLinkify extends HTMLPurifier\HTMLPurifier_Injector
{
    /**
     * @type string
     */
    public string $name = 'PurifierLinkify';

    /**
     * @type string
     */
    public string $docURL = '';

    /**
     * @type array
     */
    public dict<string, vec<string>> $needed = dict['a' => vec['href']];

    /**
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    public function prepare(HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context) : string {
        $this->docURL = $config->def->defaults['AutoFormat.PurifierLinkify.DocURL'];
        return parent::prepare($config, $context);
    }

    /**
     * @param HTMLPurifier_Token $token
     */
    public function handleText(HTMLPurifier\HTMLPurifier_Token $token) : mixed {
        if (!$this->allowsElement('a')) {
            return $token;
        }
        if ($token is Token\HTMLPurifier_Token_Text && !Str\contains($token->data, '%')) {
            return $token;
        }
        
        if (!($token is Token\HTMLPurifier_Token_Text)) {
            throw new \Exception("Token should have a data field in handleText in Linkify.hack");
        }
        $bits = \preg_split('#%([a-z0-9]+\.[a-z0-9]+)#Si', $token->data, -1, \PREG_SPLIT_DELIM_CAPTURE);
        $token = vec[];

        // $i = index
        // $c = count
        // $l = is link
        for ($i = 0, $c = C\count($bits), $l = false; $i < $c; $i++, $l = !$l) {
            if (!$l) {
                if ($bits[$i] === '') {
                    continue;
                }
                $token[] = new Token\HTMLPurifier_Token_Text($bits[$i]);
            } else {
                $token[] = new Token\HTMLPurifier_Token_Start(
                    'a',
                    dict['href' => Str\replace($this->docURL, '%s', $bits[$i])]
                );
                $token[] = new Token\HTMLPurifier_Token_Text('%' . $bits[$i]);
                $token[] = new Token\HTMLPurifier_Token_End('a');
            }
        }
        return $token;
    }

    <<__Override>>
    public function handleEnd(HTMLPurifier\HTMLPurifier_Token $token) : void {
    }

    <<__Override>>
    public function handleElement(HTMLPurifier\HTMLPurifier_Token $token) : void {
    }
}
