/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;
use namespace Facebook\TypeCoerce;
use namespace HTMLPurifier\DefinitionCache;

/**
 * Responsible for creating definition caches.
 */
class HTMLPurifier_DefinitionCacheFactory {

	protected dict<string, dict<string, DefinitionCache\HTMLPurifier_DefinitionCache_Serializer>> $caches =
		dict['Serializer' => dict[]];

	public function __construct() {
		# uses create instead of construct
	}

	public static function instance(
		?HTMLPurifier_DefinitionCacheFactory $prototype = null,
	): HTMLPurifier_DefinitionCacheFactory {
		return new HTMLPurifier_DefinitionCacheFactory();
	}

	public function create(
		string $type,
		HTMLPurifier_Config $config,
	): DefinitionCache\HTMLPurifier_DefinitionCache_Serializer {
		$method = $config->def->defaults['Cache.DefinitionImpl'];
		$this->caches[$method][$type] = new DefinitionCache\HTMLPurifier_DefinitionCache_Serializer($type);
		return $this->caches[$method][$type];
	}
}
