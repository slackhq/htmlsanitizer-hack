//created by Nikita Ashok on 07/22/20;
namespace HTMLPurifier\URIScheme;
use namespace HTMLPurifier;
use namespace HH\Lib\Str;

/**
 * Validates ftp (File Transfer Protocol) URIs as defined by generic RFC 1738.
 */
class HTMLPurifier_URIScheme_ftp extends HTMLPurifier\HTMLPurifier_URIScheme
{
    /**
     * @type int
     */
    public int $default_port = 21;

    /**
     * @type bool
     */
    public bool $browsable = true; // usually

    /**
     * @type bool
     */
    public bool $hierarchical = true;

    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
    public function doValidate(inout HTMLPurifier\HTMLPurifier_URI $uri, HTMLPurifier\HTMLPurifier_Config $config, HTMLPurifier\HTMLPurifier_Context $context): bool {
        $uri->query = '';

        // typecode check
        $semicolon_pos = Str\search($uri->path, ';'); // reverse
        if ($semicolon_pos is nonnull) {
            $type = Str\slice($uri->path, $semicolon_pos + 1); // no semicolon
            $uri->path = Str\slice($uri->path, 0, $semicolon_pos);
            $type_ret = '';
            if (Str\search($type, '=') is nonnull) {
                // figure out whether or not the declaration is correct
                list($key, $typecode) = Str\split($type, '=', 2);
                if ($key !== 'type') {
                    // invalid key, tack it back on encoded
                    $uri->path .= '%3B' . $type;
                } elseif ($typecode === 'a' || $typecode === 'i' || $typecode === 'd') {
                    $type_ret = ";type=$typecode";
                }
            } else {
                $uri->path .= '%3B' . $type;
            }
            $uri->path = Str\replace($uri->path, ';', '%3B');
            $uri->path .= $type_ret;
        }
        return true;
    }
}