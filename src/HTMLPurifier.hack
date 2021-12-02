/* Created by Nikita Ashok and Jake Polacek on 08/04/2020 */
namespace HTMLPurifier;

use namespace HTMLPurifier\Strategy;
use namespace Facebook\TypeAssert;

/**
 * Facade that coordinates HTML Purifier's subsystems in order to purify HTML.
 *
 * @note There are several points in which configuration can be specified
 *       for HTML Purifier.  The precedence of these (from lowest to
 *       highest) is as follows:
 *          -# Instance: new HTMLPurifier($config)
 *          -# Invocation: purify($html, $config)
 *       These configurations are entirely independent of each other and
 *       are *not* merged (this behavior may change in the future).
 *
 * @todo We need an easier way to inject strategies using the configuration
 *       object.
 */
class HTMLPurifier {

	public string $version = '4.12.0';
	const string VERSION = '4.12.0';
	public HTMLPurifier_Config $config;
	//private vec<HTMLPurifier_Filter> = vec[];
	private static ?HTMLPurifier $instance;
	protected Strategy\HTMLPurifier_Strategy_Core $strategy;
	protected HTMLPurifier_Generator $generator;
	public HTMLPurifier_Context $context;
	public HTMLPurifier_Lexer $lexer;

	public function __construct(?HTMLPurifier_Config $config = null, ?HTMLPurifier_Policy $policy = null) {
		$this->config = $config ? $config : HTMLPurifier_Config::createDefault();
		$this->config = $policy ? $policy->configPolicy($this->config) : $this->config;
		$this->strategy = new Strategy\HTMLPurifier_Strategy_Core();
		$this->context = new HTMLPurifier_Context();
		$this->generator = new HTMLPurifier_Generator($this->config, $this->context);
		$this->lexer = HTMLPurifier_Lexer::create($this->config);
	}

	/**
	* Filters an HTML snippet/document to be XSS-free and standards-compliant.
	*
	* @param string $html String of HTML to purify
	* @param HTMLPurifier_Config $config Config object for this operation,
	*                if omitted, defaults to the config object specified during this
	*                object's construction. The parameter can also be any type
	*                that HTMLPurifier_Config::create() supports.
	*
	* @return string Purified HTML
	* @warning Errors/exceptions may be thrown when calling purify. In order to account
	*				for this, it is strongly suggested that purify is only called in a
	*				try/catch block to handle any errors/exceptions that may occur.
	*/
	public function purify(string $html, ?HTMLPurifier_Config $config = null): string {
		$config = TypeAssert\instance_of(
			HTMLPurifier_Config::class,
			$config ? HTMLPurifier_Config::create($config) : $this->config,
		);

		// implementation is partially environment dependent, partially configuration dependent
		//$lexer = HTMLPurifier_Lexer::create($config);
		//$context = new HTMLPurifier_Context();

		// setup HTML generator
		//$this->generator = TypeAssert\instance_of(HTMLPurifier_Generator::class, new HTMLPurifier_Generator($config, $context));
		$this->context->register('Generator', $this->generator);

		// setup id_accumulator context, necessary due to the fact that
		// AttrValidator can be called from many places
		$id_accumulator = HTMLPurifier_IDAccumulator::build($config, $this->context);
		$this->context->register('IDAccumulator', $id_accumulator);

		$html = HTMLPurifier_Encoder::convertToUTF8($html, $config, $this->context);

		// setup filters
		//nikita - filter flags is a dictionary
		// $filter_flags = $config->getBatch('Filter');
		// $custom_filters = $filter_flags['Custom'];
		// unset($filter_flags['Custom']);
		// $filters = array();
		// foreach ($filter_flags as $filter => $flag) {
		//     if (!$flag) {
		//         continue;
		//     }
		//     if (strpos($filter, '.') !== false) {
		//         continue;
		//     }

		//     $class = "HTMLPurifier_Filter_$filter";
		//     $filters[] = new $class();
		// }

		// foreach ($custom_filters as $filter) {
		//     // maybe "HTMLPurifier_Filter_$filter", but be consistent with AutoFormat
		//     $filters[] = $filter;
		// }
		// $filters = array_merge($filters, $this->filters);
		// // maybe prepare(), but later

		// for ($i = 0, $filter_size = count($filters); $i < $filter_size; $i++) {
		//     echo "what is preFilter \r\n";
		//     $html = $filters[$i]->preFilter($html, $config, $context);
		// }

		// purified HTML
		$tokens = $this->lexer->tokenizeHTML($html, $config, $this->context);
		$html = $this->generator->generateFromTokens(
			// list of tokens
			$this->strategy->execute(
				// list of un-purified tokens
				$tokens,
				$config,
				$this->context,
			),
		);
		$html = HTMLPurifier_Encoder::convertToUTF8($html, $config, $this->context);
		return $html;
	}
}
