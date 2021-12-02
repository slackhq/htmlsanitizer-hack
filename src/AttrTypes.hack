// created by Nikita Ashok on 07/15/2020
namespace HTMLPurifier;

use namespace HTMLPurifier\AttrDef;
use namespace HH\Lib\Str;
/**
 * Provides lookup array of attribute types to HTMLPurifier_AttrDef objects
 */
class HTMLPurifier_AttrTypes {
	/**
	 * Lookup array of attribute string identifiers to concrete implementations.
	 * @type HTMLPurifier_AttrDef[]
	 */
	protected dict<string, HTMLPurifier_AttrDef> $info = dict[];

	/**
	 * Constructs the info array, supplying default implementations for attribute
	 * types.
	 */
	public function __construct() {
		// XXX This is kind of poor, since we don't actually /clone/
		// instances; instead, we use the supplied make() attribute. So,
		// the underlying class must know how to deal with arguments.
		// With the old implementation of Enum, that ignored its
		// arguments when handling a make dispatch, the IAlign
		// definition wouldn't work.

		//** HTML AttrDef classes still need to be implemented**

		// pseudo-types, must be instantiated via shorthand
		$this->info['Enum'] = new AttrDef\HTMLPurifier_AttrDef_Enum();
		//$this->info['Bool'] = new AttrDef\HTML\HTMLPurifier_AttrDef_HTML_Bool();

		$this->info['CDATA'] = new AttrDef\HTMLPurifier_AttrDef_Text();
		//$this->info['ID'] = new HTMLPurifier_AttrDef_HTML_ID();
		// $this->info['Length'] = new HTMLPurifier_AttrDef_HTML_Length();
		//$this->info['MultiLength'] = new HTMLPurifier_AttrDef_HTML_MultiLength();
		//$this->info['NMTOKENS'] = new HTMLPurifier_AttrDef_HTML_Nmtokens();
		//$this->info['Pixels']   = new HTMLPurifier_AttrDef_HTML_Pixels();
		$this->info['Text'] = new AttrDef\HTMLPurifier_AttrDef_Text();
		$this->info['URI'] = new AttrDef\HTMLPurifier_AttrDef_URI();
		$this->info['LanguageCode'] = new AttrDef\HTMLPurifier_AttrDef_Lang();
		//$this->info['Color']    = new HTMLPurifier_AttrDef_HTML_Color();
		$this->info['IAlign'] = self::makeEnum('top,middle,bottom,left,right');
		$this->info['LAlign'] = self::makeEnum('top,bottom,left,right');
		//$this->info['FrameTarget'] = new HTMLPurifier_AttrDef_HTML_FrameTarget();

		// unimplemented aliases
		$this->info['ContentType'] = new AttrDef\HTMLPurifier_AttrDef_Text();
		$this->info['ContentTypes'] = new AttrDef\HTMLPurifier_AttrDef_Text();
		$this->info['Charsets'] = new AttrDef\HTMLPurifier_AttrDef_Text();
		$this->info['Character'] = new AttrDef\HTMLPurifier_AttrDef_Text();

		// "proprietary" types
		// $this->info['Class'] = new HTMLPurifier_AttrDef_HTML_Class();

		// number is really a positive integer (one or more digits)
		// FIXME: ^^ not always, see start and value of list items
		$this->info['Number'] = new AttrDef\HTMLPurifier_AttrDef_Integer(false, false, true);
	}

	private static function makeEnum(string $in): HTMLPurifier_AttrDef {
		return new AttrDef\HTMLPurifier_AttrDef_Clone(new AttrDef\HTMLPurifier_AttrDef_Enum(Str\split($in, ',')));
	}

	/**
	 * Retrieves a type
	 * @param string $type String type name
	 * @return HTMLPurifier_AttrDef Object AttrDef for type
	 */
	public function get(string $type): ?HTMLPurifier_AttrDef {
		// determine if there is any extra info tacked on
		if (Str\search($type, '#') is nonnull) {
			list($type, $string) = Str\split($type, '#', 2);
		} else {
			$string = '';
		}

		if (!isset($this->info[$type])) {
			\trigger_error('Cannot retrieve undefined attribute type '.$type, \E_USER_ERROR);
			return null;
		}
		return $this->info[$type]->make($string);
	}

	/**
	 * Sets a new implementation for a type
	 * @param string $type String type name
	 * @param HTMLPurifier_AttrDef $impl Object AttrDef for type
	 */
	public function set(string $type, HTMLPurifier_AttrDef $impl): void {
		$this->info[$type] = $impl;
	}
}

// vim: et sw=4 sts=4
