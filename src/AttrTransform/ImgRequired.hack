// must be called POST validation
namespace HTMLPurifier\AttrTransform;
use namespace HTMLPurifier;
use namespace HH\Lib\C;
use namespace HH\Lib\Experimental\File;
/**
 * Transform that supplies default values for the src and alt attributes
 * in img tags, as well as prevents the img tag from being removed
 * because of a missing alt tag. This needs to be registered as both
 * a pre and post attribute transform.
 */
class HTMLPurifier_AttrTransform_ImgRequired extends HTMLPurifier\HTMLPurifier_AttrTransform
{
    /**
     * @param array $attr
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return array
     */
    public function transform(
			dict<string, mixed> $attr,
			HTMLPurifier\HTMLPurifier_Config $config,
			HTMLPurifier\HTMLPurifier_Context $context
		): dict<string, mixed>
		{
        $src = true;
        if (!C\contains_key($attr, 'src')) {
            if ($config->def->defaults['Core.RemoveInvalidImg']) {
                return $attr;
            }
            $attr['src'] = $config->def->defaults['Attr.DefaultInvalidImage'];
            $src = false;
        }

        if (!C\contains_key($attr, 'alt')) {
            if ($src) {
                $alt = $config->def->defaults['Attr.DefaultImageAlt'];
                if ($alt === '') {
                    $src_path = new File\Path((string) $attr['src']);
                    $attr['alt'] = $src_path->getBaseName();
                } else {
                    $attr['alt'] = $alt;
                }
            } else {
                $attr['alt'] = $config->def->defaults['Attr.DefaultInvalidImageAlt'];
            }
        }
        return $attr;
    }
}
