/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HH\Lib\{Dict, File, Str, Vec};
use namespace HTMLPurifier\Language\Messages;

<<__ConsistentConstruct>>
/**
 * Class responsible for generating HTMLPurifier_Language objects, managing
 * caching and fallbacks.
 * @note Thanks to MediaWiki for the general logic, although this version
 *       has been entirely rewritten
 * @todo Serialized cache for languages
 */
class HTMLPurifier_LanguageFactory {

	/**
	* Cache of language code information used to load HTMLPurifier_Language objects.
	* Structure is: $factory->cache[$language_code][$key] = $value
	*/
	public dict<string, dict<string, dict<string, string>>> $cache = dict[];

	/**
	* Valid keys in the HTMLPurifier_Language object. Designates which
	* variables to slurp out of a message file.
	*/
	public vec<string> $keys = vec['fallback', 'messages', 'errorNames'];

	/**
	* Instance to validate language codes.
	*/
	// protected ?HTMLPurifier_AttrDef_Lang $validator;

	/**
	* Cached copy of dirname(__FILE__), directory of current file without
	* trailing slash
	*/
	protected string $dir = '';

	/** 
	* Keys whose contents are a hash map and can be merged.
	* @todo Make sure to change from keyset for type safety
	*/
	protected dict<string, bool> $mergeable_keys_map = dict['messages' => true, 'errorNames' => true];

	/**
	* Keys who contents are a list and can be merged.
	*/
	protected dict<string, bool> $mergeable_keys_list = dict[];

	/**
	*/
	private dict<string, HTMLPurifier_Language> $string_class_map =
		dict[/*'HTMLPurifier_Language_en_x_test' => HTMLPurifier_Language_en_x_test*/];

	/**
	* Retrieve sole instance of the factory.
	*/
	public static function instance(?HTMLPurifier_LanguageFactory $prototype = null): HTMLPurifier_LanguageFactory {
		$instance = null;
		if ($prototype !== null) {
			$instance = $prototype;
		} else if ($instance === null || $prototype == true) {
			$instance = new HTMLPurifier_LanguageFactory();
		}
		return $instance;
	}

	/**
	* Creates a language object, handles class fallbacks
	*/
	public function create(
		HTMLPurifier_Config $config,
		HTMLPurifier_Context $context,
		string $code = 'false',
	): HTMLPurifier_Language {
		if ($code === 'false') {
			// $code = $this->validator->validate(
			// $config->get('Core.Language'),
			// $config,
			// $context
			// );
		} else {
			// $code = $this->validator->validate($code, $config);
		}

		if ($code === 'false') {
			$code = 'en'; // malformed code become English
		}

		// What does a valid Hack classname look like?
		$pcode = Str\replace($code, '-', '_');
		$depth = 0; // recursion protection

		/**
		* Is there really any other possibility for $code? 
		*/
		//if ($code == 'en') {
		$lang = $this->create($config, $context);
		//} else {
		//     $class = 'HTMLPurifier_Language_'.$pcode;
		//     $file = $this->dir.'/Language/classes/'.$code.'.hack';

		//     // Does it make sense to just hard code for the one actual case of this?
		//     // HTMLPurifer/Language/messages
		//     if (\file_exists($file) || \class_exists($class, false)) {
		//         // this is a concerning line
		//         // how do we instantiate a new instance of a class from a string?
		//         // Best bet is some sorta dictionary, but raises question of what are necessary classes?
		//         // Just instantiating a new factory for now
		//         $class_type = $this->string_class_map[$class];
		//         $lang = $class_type;
		//     } else {
		//         // Go fallback
		//         $raw_fallback = $this->getFallbackFor($code);
		//         $fallback = $raw_fallback ?? 'en';
		//         $depth++;
		//         $lang = $this->create($config, $context, $fallback);
		//         if (!$raw_fallback) {
		//             $lang->error = true;
		//         }
		//         $depth--;
		//     }
		// }
		$lang->code = $code;
		return $lang;
	}

	/**
	* Returns the fallback language for language
	* @note Loads the original language into cache
	*/
	public function getFallbackFor(string $code): string {
		$this->loadLanguage($code);
		return $this->cache[$code]['fallback']['fallback'];
	}

	/** 
	* Loads language into the cache, handles message file and fallbacks
	*/
	public function loadLanguage(string $code): void {
		$languages_seen = dict<string, bool>[];

		// abort if we've already loaded code
		if (\isset($this->cache[$code])) {
			return;
		}

		// generate filename
		$filename = $this->dir.'/Language/messages/'.$code.'.hack';

		// default fallback : maybe be overwritten by the ensuing include
		$fallback = ($code != 'en') ? 'en' : 'false';

		// load primary localization
		if (!\file_exists($filename)) {
			// skip the include. We'll rely only on fallback
			$filename = $this->dir.'/Language/messages/en.hack';
			$cache = dict<string, dict<string, string>>[];
		} else {
			$cache = Messages\Consts::COMPACT;
		}

		// load fallback localisation
		if ($fallback !== 'false') {
			// infinite recursion guard
			if (isset($languages_seen[$code])) {
				\trigger_error(
					'Circular fallback reference in language '.$code, //.E_USER_ERROR
				);
				$fallback = 'en';
			}
			$languages_seen[$code] = true;

			// Load the fallback recursively
			$this->loadLanguage($fallback);
			$fallback_cache = $this->cache[$fallback];

			// Merge fallback with current language
			foreach ($this->keys as $key) {
				if (isset($cache[$key]) && isset($fallback_cache[$key])) {
					if (isset($this->mergeable_keys_map[$key])) {
						$cache[$key] = Dict\merge($cache[$key], $fallback_cache[$key]);
					} else if (isset($this->mergeable_keys_list[$key])) {
						$cache[$key] = Dict\merge($fallback_cache[$key], $cache[$key]);
					}
				} else {
					$cache[$key] = $fallback_cache[$key];
				}
			}
		}

		// Save the cache for later retrieval
		$this->cache[$code] = $cache;
		return;
	}
}
