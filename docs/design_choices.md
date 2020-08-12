[//]: # (Created by Jake Polacek on 07/31/2020)

# Design Choices

### DOMLex.hack
* PHP version uses a queue data structure object to keep iterate through tokens, using a vec instead.
### DirectLex.hack
* `scriptCallback` function parameter $matches array, defining it to only take in strings
### Lexer.hack
* Line 14, directly called `get` on Config without checking if its an instance of the Config class because Hacklang is type checked
* Leaving out PHP5 lexer class support and Direct lexer implementation (only implementing the DOMLex in this version)
### Token.hack
* In the `get` function, a switch case is used to create new to get the token type.

### ConfigSchema.hack
* Making defaults a shape instead of a dict. When using a dict, because there were different types of values, we had to make the value type mixed, meaning that the type checking was put off until run time. Now with a shape, we can explicitly state what each type should be.

### FixNesting.hack
* Using a Stack that takes in a shape with 4 items instead of an array of array of 4 elements - this allows us to deal with the mixed types in the array more easily.

### Encode.hack
* Changed any of the return false statements to return ‘’ because the return type is supposed to be false and ‘’ == false
* In `cleanUTF8` two changes were made:
The ‘force_php’ was removed because it was an optional parameter, and nowhere in the repo was cleanUTF8() ever called with a second boolean parameter. Additionally, `force_php` was never used anywhere in the function.
Anything that does not enter the if statement that matches the regex triggers an error. The code after the if statement cleaned the UTF-8 string, and if anything doesn’t match the regex, then that is a string that we should not even consider unfurling anyways. The fact that only 1% of cases does not match the regex is further reasoning behind why it makes sense to trigger an error and not support unfurling in those cases. If there is an issue supporting any approved unfurls that meet this cse, the error will be triggered and we can adjust as needed.
Changed any instances of `static $iconv = null;` to use `StaticIconv::iconv_bool` because statics are not permitted in Hack. The same goes for `StaticCode` and `StaticEncodings`.


### Language.hack **Note that this is partially finished - the class was rarely used**
* Changed type of `$fallback` from `bool | string` to just `string`.
* Could have used mixed types to support bool and string, but would prefer to just use the string `false` instead of allowing for types we don’t want to see/accept.
* Changed type of `$errorNames` from array to `dict<int, string>`. This makes sense because `getErrorName()` took in an int and returned a string, so we should make the keys ints and the values strings.
* Changed the format of the for loop in listify.
Had to be done in order to more easily and clearly access the messages dict.
* Swapped `‘fallback’`, `‘messages’`, and `‘errorNames’` for a dict that had those as strings
At several points, the PHP code used strings to refer to the variables, which is not permitted in Hack. The most straightforward way to work around this was a dict where the values could be retrieved by making the keys the variable names. There might be a better way to do this.

### LanguageFactory.hack **Note that this is partially finished - the class was rarely used**
* Temporarily changed the type of `$mergeable_keys_list` to `vec<vec<mixed>>`.
Might make sense to change to dict later.

### IDAccumulator.hack
* Changed `$ids` to be of type `dict<string, bool>`.
We want to keep track of the ids added, and we want to make sure that the ids are all strings, and original PHP code stored ids with a true value.

### MakeWellFormed.hack
* There are several instances where `array_pop()` is called, just for reference purposes it seems (usually it’s pushed right back on without doing much/anything else to the stack).
* NOTE: there are decent portions of this file that are currently unimplemented and may need to be uncommented and implemented later on to achieve the same functionality as the original library

### src/URI.hack
* Changed null checks for string and int types to explicitly check for `''` and `0`, respectively.

### Context.hack
* I had to switch up the implementation of register() - The PHP version used Refs, so it’s very possible that we might have to overwrite some values manually. A case of this is `$current_token` in `ValidateAttributes.hack`.


### AttrDef/CSS/Background.hack (and all other AttrDef/CSS files)
* Switched the return type of validate() to string instead of bool | string, so any `return false` was replaced with `return ‘’`.

### AttrDef/CSS/ListStyle.hack
* Explicit null checks.
* Defined tag object `list-style-position`, `list-style-type`, and `list-style-image` in the constructor of this class.

### AttrDef/CSS/Color.hack
There was some weirdness with trying to find the min/max of a string and an int (craziness of weakly typed languages) that was going to send us further down the rabbit hole - for now, we just throw a Not Implemented exception if the validate function for this object is ever called.
The first second if block (starting with \preg_matches_with) is commented out so the code automatically goes into the else statement - we did this in order to get some cases working but were unsure how to deal with the min/max of a string and int in hack

### src/Length.hack
Changed the signature of validate to contain config and context because the CSS_number validate needed them.
Throwing exception instead of returning false in toString() 

### src/ChildDef/Table.hack
* We changed the way that `validate()` works - in PHP, refs were used to populate the desired arrays, resetting the accumulator directly by updating the reference. However, we don’t have references, so we decided to make a `dict<string, vec>` where the keys corresponded to the names of the referenced arrays, and the vectors themselves corresponded to the arrays. We then iterate through the same control flow, but replacing any references in favor of setting a "current_key” and then populating the corresponding vector in the dictionary.

### HTMLModuleManager.hack
* Changed type of `$module` parameter in `registerModule` and `addModule` to be an `HTMLPurifier_HTMLModule` because the ability to use a string as input would have meant we need to do some funky PHP stuff that isn’t supported in Hack (like instantiating a new class like `$m = new $module;`).


# Future Improvements #
* Fixing the constructor for `HTMLPurifier_ElementDef`.
* Implementing some sort of switch statement if there are some patterns for the other parameters of `ElementDef`. For example, instead of putting the whole new `ChildDef\HTMLPurifier_ChildDef_...` in every constructor, just have the input to the `ElementDef` constructor be “Required”, and then a case within the switch statement that sets the `Child` to a new `ChildDef_Required`.
* Finish incorporating the usage of the `RemoveSpansWithoutAttributes` and `SafeObject` injectors. For now, these injectors are not allowed to be turned on in the configuration because they do not behave in the same manner as the original PHP implementaition. Note that the injectors are purly aesthetic and do not affect the security aspects of the library.


# Not implemented #

## Directories
* AttrTransform/*
    * Note that the child classes have not been implemented as the configurations do not process entire attribute arrays.
* DefinitionCache
    * Decorator - Is not implemented because we never decorate the cache.
* Filter/*
    * Some of the Filter implementation was too PHP specific to be well ported over to Hack.
* HTMLModule/*
    * With the configuration implemented, no HTMLModule code was ever hit. The child classes are not implemented for this reason.
* TagTransform/*
    * Note that the child classes have not been implemented as the configurations do not process entire tag arrays.
* VarParser/*
    * These classes are never used due to our implementation.

## Files
* Bootstrap
    * Not needed because constants were set in another manner.
* ChildDef/StrictBlockquote and ChildDef/Custom
    * Not implemented because we do not want to allow this type of ChildDef
* DefinitionCache
    * Not needed because of the way we defined the ConfigSchema.
* Filter
    * Some of the Filter implementation was too PHP specific to be well ported over to Hack.
* TagTransform
    * The configurations do not process entire tag arrays.
