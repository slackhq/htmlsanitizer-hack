/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier\DefinitionCache;

use namespace HTMLPurifier;
use namespace HH\Lib\Str;
use namespace HH\Shapes;

class HTMLPurifier_DefinitionCache_Serializer {

	public string $type;

	public function __construct(string $type): void {
		$this->type = $type;
	}

	/**
	 * Tests whether or not a key is old with respect to the configuration's
	 * version and revision number.
	 * @param string $key Key to test
	 * @param HTMLPurifier_Config $config Instance of HTMLPurifier_Config to test against
	 * @return bool
	 */
	public function isOld(string $key, HTMLPurifier\HTMLPurifier_Config $config): bool {
		if (\substr_count($key, ',') < 2) {
			return true;
		}
		$explode = Str\split(',', $key, 3);
		$version = $explode[0];
		$hash = $explode[1];
		$revision = $explode[2];
		$compare = \version_compare($version, $config->version);
		// version mismatch, is always old
		if ($compare !== 0) {
			return true;
		}
		// versions match, ids match, check revision number
		// if ($hash == $config->getBatchSerial($this->type) &&
		//     $revision < TypeAssert\int($config->get($this->type . '.DefinitionRev'))) {
		//     return true;
		// }
		if ($hash === $config->getBatchSerial($this->type) && $revision === '') {
			return true;
		}
		return false;
	}

	/**
	 * Generates a unique identifier for a particular configuration
	 * @param HTMLPurifier_Config $config Instance of HTMLPurifier_Config
	 * @return string
	 */
	public function generateKey(HTMLPurifier\HTMLPurifier_Config $config): string {
		$type_rev = Shapes::toArray($config->def->defaults)[$this->type.'.DefinitionRev'];
		if (!($type_rev is int)) {
			throw new \Exception('The type rev is not a string');
		}
		return $config->version.
			','. // possibly replace with function calls
			(string)$config->getBatchSerial($this->type).
			','.
			(string)$type_rev;
	}

	/**
	 * Checks if a definition's type jives with the cache's type
	 * @note Throws an error on failure
	 * @param HTMLPurifier_Definition $def Definition object to check
	 * @return bool true if good, false if not
	 */
	public function checkDefType(HTMLPurifier\HTMLPurifier_Definition $def): bool {
		if ($def->type !== $this->type) {
			// trigger_error("Cannot use definition of type {$def->type} in cache for {$this->type}");
			echo "Cannot use definition of type ".(string)$def->type." in cache for {$this->type}";
			return false;
		}
		return true;
	}

	/**
	 * @param HTMLPurifier_Definition $def
	 * @param HTMLPurifier_Config $config
	 * @return int|bool
	 */
	public function add(HTMLPurifier\HTMLPurifier_Definition $def, HTMLPurifier\HTMLPurifier_Config $config): int {
		if (!$this->checkDefType($def)) {
			return 0;
		}
		$file = $this->generateFilePath($config);
		if (\file_exists($file)) {
			return 0;
		}
		if (!$this->_prepareDir($config)) {
			return 0;
		}
		return $this->_write($file, \fb_serialize($def), $config);
	}

	/**
	 * @param HTMLPurifier_Definition $def
	 * @param HTMLPurifier_Config $config
	 * @return int|bool
	 */
	public function set(HTMLPurifier\HTMLPurifier_Definition $def, HTMLPurifier\HTMLPurifier_Config $config): int {
		if (!$this->checkDefType($def)) {
			return 0;
		}
		$file = $this->generateFilePath($config);
		if (!$this->_prepareDir($config)) {
			return 0;
		}
		return $this->_write($file, \fb_serialize($def), $config);
	}

	/**
	 * @param HTMLPurifier_Definition $def
	 * @param HTMLPurifier_Config $config
	 * @return int|bool
	 */
	public function replace(HTMLPurifier\HTMLPurifier_Definition $def, HTMLPurifier\HTMLPurifier_Config $config): int {
		if (!$this->checkDefType($def)) {
			return 0;
		}
		$file = $this->generateFilePath($config);
		if (!\file_exists($file)) {
			return 0;
		}
		if (!$this->_prepareDir($config)) {
			return 0;
		}
		return $this->_write($file, \fb_serialize($def), $config);
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool|HTMLPurifier_Config
	 */
	public function get(HTMLPurifier\HTMLPurifier_Config $config): HTMLPurifier\HTMLPurifier_Definition {
		$file = $this->generateFilePath($config);
		// if (!\file_exists($file)) {
		//     throw new \Error("file doesn't exist");
		// }
		// $__unused = null;
		// $object = \fb_unserialize(\file_get_contents($file), inout $__unused);
		// return $object;
		$object = new HTMLPurifier\Definition\HTMLPurifier_HTMLDefinition(); // here's the line that takes a while
		return $object;
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool
	 */
	public function remove(HTMLPurifier\HTMLPurifier_Config $config): bool {
		$file = $this->generateFilePath($config);
		if (!\file_exists($file)) {
			return false;
		}
		return \unlink($file);
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool
	 */
	public function flush(HTMLPurifier\HTMLPurifier_Config $config): bool {
		if (!$this->_prepareDir($config)) {
			return false;
		}
		$dir = $this->generateDirectoryPath($config);
		$dh = \opendir($dir);
		// Apparently, on some versions of PHP, readdir will return
		// an empty string if you pass an invalid argument to readdir.
		// So you need this test.  See #49.
		if (false === $dh) {
			return false;
		}

		// Check this it may be wrong
		$filename = \readdir($dh);
		while (false !== $filename) {
			if ($filename) {
				continue;
			}
			if ($filename[0] === '.') {
				continue;
			}
			\unlink($dir.'/'.$filename);
		}
		\closedir($dh);
		return true;
	}

	/**
	 * @param HTMLPurifier_Config $config
	 * @return bool
	 */
	public function cleanup(HTMLPurifier\HTMLPurifier_Config $config): bool {
		if (!$this->_prepareDir($config)) {
			return false;
		}
		$dir = $this->generateDirectoryPath($config);
		$dh = \opendir($dir);
		// See #49 (and above).
		if (false === $dh) {
			return false;
		}
		$filename = \readdir($dh);
		while (false !== $filename) {
			if (!$filename) {
				$filename = \readdir($dh);
				continue;
			}
			if ($filename[0] === '.') {
				$filename = \readdir($dh);
				continue;
			}
			$key = Str\slice($filename, 0, Str\length($filename) - 4);
			if ($this->isOld($key, $config)) {
				\unlink($dir.'/'.$filename);
			}
			$filename = \readdir($dh);
		}
		\closedir($dh);
		return true;
	}

	/**
	 * Generates the file path to the serial file corresponding to
	 * the configuration and definition name
	 * @param HTMLPurifier_Config $config
	 * @return string
	 * @todo Make protected
	 */
	public function generateFilePath(HTMLPurifier\HTMLPurifier_Config $config): string {
		$key = $this->generateKey($config);
		return $this->generateDirectoryPath($config).'/'.$key.'.ser';
	}

	/**
	 * Generates the path to the directory contain this cache's serial files
	 * @param HTMLPurifier_Config $config
	 * @return string
	 * @note No trailing slash
	 * @todo Make protected
	 */
	public function generateDirectoryPath(HTMLPurifier\HTMLPurifier_Config $config): string {
		$base = $this->generateBaseDirectoryPath($config);
		return $base.'/'.$this->type;
	}

	/**
	 * Generates path to base directory that contains all definition type
	 * serials
	 * @param HTMLPurifier_Config $config
	 * @return mixed|string
	 * @todo Make protected
	 */
	public function generateBaseDirectoryPath(HTMLPurifier\HTMLPurifier_Config $config): string {
		$base = $config->def->defaults['Cache.SerializerPath'];
		$dir = \dirname(__FILE__);
		$base = ($base === '') ? $dir.'/Serializer' : $base;
		return $base;
	}

	/**
	 * Convenience wrapper function for file_put_contents
	 * @param string $file File name to write to
	 * @param string $data Data to write into file
	 * @param HTMLPurifier_Config $config
	 * @return int|bool Number of bytes written if success, or false if failure.
	 */
	private function _write(string $file, string $data, HTMLPurifier\HTMLPurifier_Config $config): int {
		$result = \file_put_contents($file, $data);
		if ($result !== false) {
			// set permissions of the new file (no execute)
			$chmod = $config->def->defaults['Cache.SerializerPermissions'];
			if ($chmod is nonnull) {
				// \chmod($file, $chmod & 0666);
			}
		}
		return $result;
	}

	/**
	 * Prepares the directory that this type stores the serials in
	 */
	private function _prepareDir(HTMLPurifier\HTMLPurifier_Config $config): bool {
		$directory = $this->generateDirectoryPath($config);
		$chmod = $config->def->defaults['Cache.SerializerPermissions'];
		if ($chmod is null) {
			if (!\mkdir($directory) && !\is_dir($directory)) {
				// trigger_error(
				//     'Could not create directory ' . $directory . '',
				//     E_USER_WARNING
				// );
				return false;
			}
			return true;
		}
		if (!\is_dir($directory)) {
			$base = $this->generateBaseDirectoryPath($config);
			if (!\is_dir($base)) {
				// trigger_error(
				//     'Base directory ' . $base . ' does not exist,
				//     please create or change using %Cache.SerializerPath',
				//     E_USER_WARNING
				// );
				return false;
			} else if (!$this->_testPermissions($base, $chmod)) {
				return false;
			}
			if (!\mkdir($directory, $chmod) && !\is_dir($directory)) {
				// trigger_error(
				//     'Could not create directory ' . $directory . '',
				//     E_USER_WARNING
				// );
				return false;
			}
			if (!$this->_testPermissions($directory, $chmod)) {
				return false;
			}
		} else if (!$this->_testPermissions($directory, $chmod)) {
			return false;
		}
		return true;
	}

	/**
	 * Tests permissions on a directory and throws out friendly
	 * error messages and attempts to chmod it itself if possible
	 */
	private function _testPermissions(string $dir, int $chmod): bool {
		// early abort, if it is writable, everything is hunky-dory
		if (\is_writable($dir)) {
			return true;
		}
		if (!\is_dir($dir)) {
			// generally, you'll want to handle this beforehand
			// so a more specific error message can be given
			// trigger_error(
			//     'Directory ' . $dir . ' does not exist',
			//     E_USER_WARNING
			// );
			return false;
		}
		if (\function_exists('posix_getuid') && $chmod is nonnull) {
			// POSIX system, we can give more specific advice
			if (\fileowner($dir) === \posix_getuid()) {
				// we can chmod it ourselves
				$chmod = $chmod | 0700;
				if (\chmod($dir, $chmod)) {
					return true;
				}
			} else if (\filegroup($dir) === \posix_getgid()) {
				$chmod = $chmod | 0070;
			} else {
				// PHP's probably running as nobody, so we'll
				// need to give global permissions
				$chmod = $chmod | 0777;
			}
			// trigger_error(
			//     'Directory ' . $dir . ' not writable, ' .
			//     'please chmod to ' . decoct($chmod),
			//     E_USER_WARNING
			// );
		} else {
			// generic error message
			// trigger_error(
			//     'Directory ' . $dir . ' not writable, ' .
			//     'please alter file permissions',
			//     E_USER_WARNING
			// );
		}
		return false;
	}
}

// vim: et sw=4 sts=4
