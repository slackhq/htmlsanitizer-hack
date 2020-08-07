/* Created by Nikita Ashok on 07/22/2020 */
namespace HTMLPurifier\AttrDef\URI;
use namespace HTMLPurifier;

abstract class HTMLPurifier_AttrDef_URI_Email extends HTMLPurifier\HTMLPurifier_AttrDef
{

    /**
     * Unpacks a mailbox into its display-name and address
     * @param string $string
     * @return mixed
     */
    public function unpack(string $_string): void
    {
        // needs to be implemented
    }

}