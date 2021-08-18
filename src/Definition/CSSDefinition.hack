//created by Nikita Ashok on 7/8/2020
namespace HTMLPurifier\Definition;
use namespace HTMLPurifier;
use namespace HTMLPurifier\{AttrDef, ChildDef, Enums};
use namespace HTMLPurifier\AttrDef\CSS;
use namespace HH\Lib\C;

/**
 * Defines allowed CSS attributes and what their values are.
 * @see HTMLPurifier_HTMLDefinition
 */

class HTMLPurifier_CSSDefinition extends HTMLPurifier\HTMLPurifier_Definition {

    public ?Enums\DefinitionType $type = Enums\DefinitionType::CSS;

    /**
     * Assoc array of attribute name to definition object.
     * @type HTMLPurifier_AttrDef[]
     */
    public dict<string, HTMLPurifier\HTMLPurifier_AttrDef> $info = dict[];

    /**
     * Constructs the info array.  The meat of this class.
     * @param HTMLPurifier_Config $config
     */
    protected function doSetup(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->info['text-align'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['left', 'right', 'center', 'justify'],
            false
        );

        $border_style = new AttrDef\HTMLPurifier_AttrDef_Enum(
                vec[
                    'none',
                    'hidden',
                    'dotted',
                    'dashed',
                    'solid',
                    'double',
                    'groove',
                    'ridge',
                    'inset',
                    'outset'
                ],
                false
            );

            $this->info['border-bottom-style'] = $border_style;
            $this->info['border-right-style'] = $border_style;
            $this->info['border-left-style'] = $border_style;
            $this->info['border-top-style'] = $border_style;
        $this->info['border-style'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($border_style);

        $this->info['clear'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['none', 'left', 'right', 'both'],
            false
        );
        $this->info['float'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['none', 'left', 'right'],
            false
        );
        $this->info['font-style'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['normal', 'italic', 'oblique'],
            false
        );
        $this->info['font-variant'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['normal', 'small-caps'],
            false
        );

        $uri_or_none = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['none']),
                new CSS\HTMLPurifier_AttrDef_CSS_URI()
            ]
        );

        $this->info['list-style-position'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['inside', 'outside'],
            false
        );
        $this->info['list-style-type'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec[
                'disc',
                'circle',
                'square',
                'decimal',
                'lower-roman',
                'upper-roman',
                'lower-alpha',
                'upper-alpha',
                'none'
            ],
            false
        );
        $this->info['list-style-image'] = $uri_or_none;

        $this->info['list-style'] = new CSS\HTMLPurifier_AttrDef_CSS_ListStyle($config);

        $this->info['text-transform'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['capitalize', 'uppercase', 'lowercase', 'none'],
            false
        );
        $this->info['color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();

        $this->info['background-image'] = $uri_or_none;
        $this->info['background-repeat'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['repeat', 'repeat-x', 'repeat-y', 'no-repeat']
        );
        $this->info['background-attachment'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['scroll', 'fixed']
        );
        $this->info['background-position'] = new CSS\HTMLPurifier_AttrDef_CSS_BackgroundPosition();

        $this->info['background-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
                vec[
                    new AttrDef\HTMLPurifier_AttrDef_Enum(vec['transparent']),
                    new CSS\HTMLPurifier_AttrDef_CSS_Color()
                ]
        );

        $this->info['border-top-color'] = $this->info['background-color'];
        $this->info['border-bottom-color'] = $this->info['border-top-color'];
        $this->info['border-left-color'] = $this->info['border-top-color'];
        $this->info['border-right-color'] = $this->info['border-top-color'];
        $border_color = $this->info['border-top-color'];

        $this->info['background'] = new CSS\HTMLPurifier_AttrDef_CSS_Background($config);

        $this->info['border-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($border_color);

        $this->info['border-right-width'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
                vec[
                    new AttrDef\HTMLPurifier_AttrDef_Enum(vec['thin', 'medium', 'thick']),
                    new CSS\HTMLPurifier_AttrDef_CSS_Length('0') //disallow negative
                ]
        );
        $this->info['border-top-width'] = $this->info['border-right-width'];
        $this->info['border-bottom-width'] = $this->info['border-right-width'];
        $this->info['border-left-width'] = $this->info['border-right-width'];

        $border_width = $this->info['border-right-width'];

        $this->info['border-width'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($border_width);

        $this->info['letter-spacing'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['normal']),
                new CSS\HTMLPurifier_AttrDef_CSS_Length()
            ]
        );

        $this->info['word-spacing'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['normal']),
                new CSS\HTMLPurifier_AttrDef_CSS_Length()
            ]
        );

        $this->info['font-size'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(
                    vec[
                        'xx-small',
                        'x-small',
                        'small',
                        'medium',
                        'large',
                        'x-large',
                        'xx-large',
                        'larger',
                        'smaller'
                    ]
                ),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(),
                new CSS\HTMLPurifier_AttrDef_CSS_Length()
            ]
        );

        $this->info['line-height'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['normal']),
                new CSS\HTMLPurifier_AttrDef_CSS_Number(true), // no negatives
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0'),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true)
            ]
        );

        
        $this->info['margin-right'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length(),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto'])
            ]
        );

        $this->info['margin-top'] = $this->info['margin-right'];
        $this->info['margin-bottom'] = $this->info['margin-right'];
        $this->info['margin-left'] = $this->info['margin-right'];
        $margin = $this->info['margin-right'];

        $this->info['margin'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($margin);

        // non-negative
        $this->info['padding-right'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0'),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true)
            ]
        );

        $this->info['padding-top'] = $this->info['padding-right'];
        $this->info['padding-bottom'] = $this->info['padding-right'];
        $this->info['padding-left'] = $this->info['padding-right'];

        $padding = $this->info['padding-right'];

        $this->info['padding'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($padding);

        $this->info['text-indent'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length(),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage()
            ]
        );

        $trusted_wh = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0'),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto', 'initial', 'inherit'])
            ]
        );
        $trusted_min_wh = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0'),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['initial', 'inherit'])
            ]
        );
        $trusted_max_wh = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0'),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['none', 'initial', 'inherit'])
            ]
        );
        $max = $config->def->defaults['CSS.MaxImgLength'];

        if ($max is null) {
            $this->info['height'] = $trusted_wh;
            $this->info['width'] = $trusted_wh;
            $this->info['min-height'] = $trusted_min_wh;
            $this->info['min-width'] = $trusted_min_wh;
            $this->info['max-height'] = $trusted_max_wh;
            $this->info['max-width'] = $trusted_max_wh;
        } else {
            $this->info['height'] =  new AttrDef\HTMLPurifier_AttrDef_Switch(
                                            'img',
                                            // For img tags:
                                            new CSS\HTMLPurifier_AttrDef_CSS_Composite(
                                                vec[
                                                    new CSS\HTMLPurifier_AttrDef_CSS_Length('0', $max),
                                                    new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto'])
                                                ]
                                            ),
                                            // For everyone else:
                                            $trusted_wh
                                        );
            $this->info['width'] = $this->info['height'];
            $this->info['min-height'] =  new AttrDef\HTMLPurifier_AttrDef_Switch(
                                            'img',
                                            // For img tags:
                                            new CSS\HTMLPurifier_AttrDef_CSS_Composite(
                                                vec[
                                                    new CSS\HTMLPurifier_AttrDef_CSS_Length('0', $max),
                                                    new AttrDef\HTMLPurifier_AttrDef_Enum(vec['initial', 'inherit'])
                                                ]
                                            ),
                                            // For everyone else:
                                            $trusted_min_wh
                                        );
            $this->info['min-width'] = $this->info['min-height'];
            $this->info['max-height'] = new AttrDef\HTMLPurifier_AttrDef_Switch(
                                            'img',
                                            // For img tags:
                                            new CSS\HTMLPurifier_AttrDef_CSS_Composite(
                                                vec[
                                                    new CSS\HTMLPurifier_AttrDef_CSS_Length('0', $max),
                                                    new AttrDef\HTMLPurifier_AttrDef_Enum(vec['none', 'initial', 'inherit'])
                                                ]
                                            ),
                                            // For everyone else:
                                            $trusted_max_wh
                                        );
            $this->info['max-width'] = $this->info['max-height'];
        }

        $this->info['text-decoration'] = new CSS\HTMLPurifier_AttrDef_CSS_TextDecoration();

        $this->info['font-family'] = new CSS\HTMLPurifier_AttrDef_CSS_FontFamily();

        // this could use specialized code
        $this->info['font-weight'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec[
                'normal',
                'bold',
                'bolder',
                'lighter',
                '100',
                '200',
                '300',
                '400',
                '500',
                '600',
                '700',
                '800',
                '900'
            ],
            false
        );

        // MUST be called after other font properties, as it references
        // a CSSDefinition object
        $this->info['font'] = new CSS\HTMLPurifier_AttrDef_CSS_Font($config);

        // same here
        $this->info['border-right'] = new CSS\HTMLPurifier_AttrDef_CSS_Border($config);
        $this->info['border'] = $this->info['border-right'];
        $this->info['border-bottom'] = $this->info['border-right'];
        $this->info['border-top'] = $this->info['border-right'];
        $this->info['border-left'] = $this->info['border-right'];

        $this->info['border-collapse'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['collapse', 'separate']
        );

        $this->info['caption-side'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['top', 'bottom']
        );

        $this->info['table-layout'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['auto', 'fixed']
        );

        $this->info['vertical-align'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Enum(
                    vec[
                        'baseline',
                        'sub',
                        'super',
                        'top',
                        'text-top',
                        'middle',
                        'bottom',
                        'text-bottom'
                    ]
                ),
                new CSS\HTMLPurifier_AttrDef_CSS_Length(),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage()
            ]
        );

        $this->info['border-spacing'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple(new CSS\HTMLPurifier_AttrDef_CSS_Length(), 2);

        // These CSS properties don't work on many browsers, but we live
        // in THE FUTURE!
        $this->info['white-space'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['nowrap', 'normal', 'pre', 'pre-wrap', 'pre-line']
        );

        if ($config->def->defaults['CSS.Proprietary']) {
            $this->doSetupProprietary($config);
        }

        if ($config->def->defaults['CSS.AllowTricky']) {
            $this->doSetupTricky($config);
        }

        if ($config->def->defaults['CSS.Trusted']) {
            $this->doSetupTrusted($config);
        }

        $allow_important = $config->def->defaults['CSS.AllowImportant'];
        // wrap all attr-defs with decorator that handles !important
        foreach ($this->info as $k => $v) {
            $this->info[$k] = new CSS\HTMLPurifier_AttrDef_CSS_ImportantDecorator($v, $allow_important);
        }

        $this->setupConfigStuff($config);
    }

    /**
     * @param HTMLPurifier_Config $config
     */
    protected function doSetupProprietary(HTMLPurifier\HTMLPurifier_Config $config): void
    {
        // Internet Explorer only scrollbar colors
        $this->info['scrollbar-arrow-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();
        $this->info['scrollbar-base-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();
        $this->info['scrollbar-darkshadow-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();
        $this->info['scrollbar-face-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();
        $this->info['scrollbar-highlight-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();
        $this->info['scrollbar-shadow-color'] = new CSS\HTMLPurifier_AttrDef_CSS_Color();

        // vendor specific prefixes of opacity
        $this->info['-moz-opacity'] = new CSS\HTMLPurifier_AttrDef_CSS_AlphaValue();
        $this->info['-khtml-opacity'] = new CSS\HTMLPurifier_AttrDef_CSS_AlphaValue();

        // only opacity, for now
        $this->info['filter'] = new CSS\HTMLPurifier_AttrDef_CSS_Filter();

        // more CSS3
        $after_and_before = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec[
                'auto',
                'always',
                'avoid',
                'left',
                'right'
            ]
        );

        $this->info['page-break-after'] = $after_and_before;
        $this->info['page-break-before'] = $after_and_before;
        $this->info['page-break-inside'] = new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto', 'avoid']);

        $border_radius = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(true), // disallow negative
                new CSS\HTMLPurifier_AttrDef_CSS_Length('0') // disallow negative
            ]);

        $this->info['border-bottom-left-radius'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($border_radius, 2);
        $this->info['border-top-left-radius'] = $this->info['border-bottom-left-radius'];
        $this->info['border-top-right-radius'] = $this->info['border-bottom-left-radius'];
        $this->info['border-bottom-right-radius'] = $this->info['border-bottom-left-radius'];
        $this->info['border-radius'] = new CSS\HTMLPurifier_AttrDef_CSS_Multiple($border_radius, 4);

    }

    /**
     * @param HTMLPurifier_Config $config
     */
    protected function doSetupTricky(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->info['display'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec[
                'inline',
                'block',
                'list-item',
                'run-in',
                'compact',
                'marker',
                'table',
                'inline-block',
                'inline-table',
                'table-row-group',
                'table-header-group',
                'table-footer-group',
                'table-row',
                'table-column-group',
                'table-column',
                'table-cell',
                'table-caption',
                'none'
            ]
        );
        $this->info['visibility'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['visible', 'hidden', 'collapse']
        );
        $this->info['overflow'] = new AttrDef\HTMLPurifier_AttrDef_Enum(vec['visible', 'hidden', 'auto', 'scroll']);
        $this->info['opacity'] = new CSS\HTMLPurifier_AttrDef_CSS_AlphaValue();
    }

    /**
     * @param HTMLPurifier_Config $config
     */
    protected function doSetupTrusted(HTMLPurifier\HTMLPurifier_Config $config): void {
        $this->info['position'] = new AttrDef\HTMLPurifier_AttrDef_Enum(
            vec['static', 'relative', 'absolute', 'fixed']
        );

        $position_composite = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new CSS\HTMLPurifier_AttrDef_CSS_Length(),
                new CSS\HTMLPurifier_AttrDef_CSS_Percentage(),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto']),
            ]
        );

        $this->info['top'] = $position_composite;
        $this->info['left'] = $position_composite;
        $this->info['right'] = $position_composite;
        $this->info['bottom'] =  $position_composite;
        $this->info['z-index'] = new CSS\HTMLPurifier_AttrDef_CSS_Composite(
            vec[
                new AttrDef\HTMLPurifier_AttrDef_Integer(),
                new AttrDef\HTMLPurifier_AttrDef_Enum(vec['auto']),
            ]
        );
    }

    /**
     * Performs extra config-based processing. Based off of
     * HTMLPurifier_HTMLDefinition.
     * @param HTMLPurifier_Config $config
     * @todo Refactor duplicate elements into common class (probably using
     *       composition, not inheritance).
     */
    protected function setupConfigStuff(HTMLPurifier\HTMLPurifier_Config$config): void {
        // setup allowed elements
        $support = "(for information on implementing this, see the " .
            "support forums) ";
        $allowed_properties = $config->def->defaults['CSS.AllowedProperties'];
        if ($allowed_properties !== null) {
            foreach ($this->info as $name => $d) {
                if (C\contains_key($allowed_properties, $name) && !$allowed_properties[$name]) {
                    unset($this->info[$name]);
                }
                unset($allowed_properties[$name]);
            }
            // emit errors
            foreach ($allowed_properties as $name => $d) {
                $name = \htmlspecialchars($name);
                \trigger_error("Style attribute '$name' is not supported $support", \E_USER_WARNING);
            }
        }

        $forbidden_properties = $config->def->defaults['CSS.ForbiddenProperties'];
        if ($forbidden_properties !== null) {
            foreach ($this->info as $name => $d) {
                if (C\contains_key($forbidden_properties, $name)) {
                    unset($this->info[$name]);
                }
            }
        }
    }
}
