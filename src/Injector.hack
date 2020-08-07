/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

/**
* Injects tokens into the document while parsing for well-formedness.
* This enables "formatter-like" functionality such as auto-paragraphing,
* smiley-ification and linkification to take place.
*
* A note on how handlers create changes; this is done by assigning a new
* value to the $token reference. These values can take a variety of forms and
* are best described HTMLPurifier_Strategy_MakeWellFormed->processToken()
* documentation.
*/
abstract class HTMLPurifier_Injector
{

    // /**
    // * Advisory name of injector, this is for friendly error messages.
    // */
    public string $name;

    // // protected HTMLPurifier_HTMLDefinition $htmlDefinition;

    // /**
    //  * Reference to CurrentNesting variable in Context. This is an array
    //  * list of tokens that we are currently "inside"
    //  */
    // protected vec<HTMLPurifier_Token> $currentNesting = vec[];

    // /**
    //  * Reference to current token.
    //  * @type HTMLPurifier_Token
    //  */
    // protected HTMLPurifier_Token $currentToken;

    // /**
    //  * Reference to InputZipper variable in Context.
    //  * @type HTMLPurifier_Zipper
    //  */
    // protected HTMLPurifier_Zipper<HTMLPurifier_Token> $inputZipper;

    // /**
    //  * Array of elements and attributes this injector creates and therefore
    //  * need to be allowed by the definition. Takes form of
    //  * array('element' => array('attr', 'attr2'), 'element2')
    //  * @type array
    //  */
    // public $needed = array();

    // /**
    //  * Number of elements to rewind backwards (relative).
    //  * @type bool|int
    //  */
    // protected $rewindOffset = false;

}
