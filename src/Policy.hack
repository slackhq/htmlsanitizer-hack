//created by Nikita Ashok on 07/20/2020;
/* Holds the policy for specifying allowed elements and attributes. */

namespace HTMLPurifier;
use namespace HH\Lib\{C, Str};

class HTMLPurifier_Policy {
    public dict<string, vec<string>> $allowed_tags_attributes = dict[];

    public function __construct(dict<string, vec<string>> $allowed_tags_attributes) {
        $this->allowed_tags_attributes = $allowed_tags_attributes;
    }

    public function configPolicy(HTMLPurifier_Config $config): HTMLPurifier_Config {
        $html_allowed = "";
        /* Get Tags and Attributes from policy objects and convert it to htmlpurifier html allowed config
         * format: element1[attr1|attr2],element2.... 
         */
        $allowedTagsAttributes = $this->allowed_tags_attributes;
        if (!C\is_empty($allowedTagsAttributes)) {
            foreach ($allowedTagsAttributes as $tag => $list_attrb) {
                $html_allowed = $html_allowed.",".$tag;
                if (!C\is_empty($list_attrb)) {
                    $a_attributes = vec[];                    
                    foreach ($list_attrb as $attrb){
                        $a_attributes[] = $attrb;
                    }
                    $s_attribute = Str\join($a_attributes, "|");
                    if ($s_attribute !== "")
                        $html_allowed = $html_allowed."[".$s_attribute."]";
                }
            }
            if ($html_allowed !== ""){
                $html_allowed = Str\slice($html_allowed, 1);
            }
        }
        $config->def->defaults['HTML.Allowed'] = $html_allowed;
        return $config;
    }
}