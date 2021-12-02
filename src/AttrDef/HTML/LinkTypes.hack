/* Created by Nikita Ashok on 07/20/2020 */

namespace HTMLPurifier\AttrDef\HTML;
use namespace HTMLPurifier;
use namespace HH\Lib\{C, Str, Vec};
use namespace HH\Shapes;

/**
 * Validates a rel/rev link attribute against a directive of allowed values
 * @note We cannot use Enum because link types allow multiple
 *       values.
 * @note Assumes link types are ASCII text
 */
class HTMLPurifier_AttrDef_HTML_LinkTypes extends HTMLPurifier\HTMLPurifier_AttrDef {

	/**
	 * Name config attribute to pull.
	 * @type string
	 */
	protected string $name = '';

	/**
	 * @param string $name
	 */
	public function __construct(string $name) {
		$configLookup = dict[
			'rel' => 'AllowedRel',
			'rev' => 'AllowedRev',
		];
		if (!C\contains_key($configLookup, $name)) {
			\trigger_error('Unrecognized attribute name for link '.'relationship.', \E_USER_ERROR);
			return;
		}
		$this->name = $configLookup[$name];
	}

	/**
	 * @param string $string
	 * @param HTMLPurifier_Config $config
	 * @param HTMLPurifier_Context $context
	 * @return string
	 */
	public function validate(
		string $string,
		HTMLPurifier\HTMLPurifier_Config $config,
		HTMLPurifier\HTMLPurifier_Context $context,
	): string {
		$allowed = Shapes::toArray($config->def->defaults)['Attr.'.$this->name];
		if (!($allowed is dict<_, _>)) {
			throw new \Exception('Allowed should be a dict');
		}
		if (C\is_empty($allowed)) {
			return '';
		}

		$string = $this->parseCDATA($string);
		$parts = Str\split($string, ' ');

		// lookup to prevent duplicates
		$ret_lookup = dict[];
		foreach ($parts as $part) {
			$part = Str\lowercase(Str\trim($part));
			if (!C\contains_key($allowed, $part)) {
				continue;
			}
			$ret_lookup[$part] = true;
		}

		if (C\is_empty($ret_lookup)) {
			return '';
		}
		$string = Str\join(Vec\keys($ret_lookup), ' ');
		return $string;
	}
}
