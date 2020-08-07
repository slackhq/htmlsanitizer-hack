[//]: # (Created by Jake Polacek 07/31/2020)

# Hackify HTML Sanitizer
An HTML Sanitizer library that protects against cross-site scripting attacks by sanitizing a user’s HTML code. This is a [Hack](https://hacklang.org/) port of the PHP [HTML Purifier](http://htmlpurifier.org/) library created by Edward Z. Yang. The inspiration of the development for this library was to transition from PHP to Hack and provide a strongly typed HTML sanitizer, while maintaining the same functionality as the PHP version.

# Testing
run `bin/test`!

# Usage
Without policy specification for allowlist:
```php
$dirty_html = '<div>Body of my text';
print("DIRTY HTML: " . $dirty_html . "\r\n");
$purifier = new HTMLPurifier($config);
$clean_html = $purifier->purify($dirty_html);
print($clean_html) --> '<div>Body of my text</div>'
```
With policy specification for allowlist:
```php
$config = HTMLPurifier\HTMLPurifier_Config::createDefault();
$policy = new HTMLPurifier\HTMLPurifier_Policy(dict["div"=>vec["align"]]);
$purifier = new HTMLPurifier\HTMLPurifier($config, $policy);
$dirty_html = "<div align='center' title='hi'><b>Hello</b>";
$clean_html = $purifier->purify($dirty_html);
print($clean_html) --> "<div align='center'>Hello</div>"
```
