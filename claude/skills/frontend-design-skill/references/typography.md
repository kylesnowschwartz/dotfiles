# Typography Reference

## Fonts to Avoid

These fonts signal "I didn't think about typography":

- Arial
- Helvetica
- Inter
- Roboto
- Open Sans
- Lato
- Source Sans Pro
- system-ui / -apple-system defaults

Not because they're bad fonts—they're fine. But they're the default choice, and default choices produce default-looking interfaces.

## Google Fonts Worth Exploring

Vary choices across projects. Never converge on the same fonts repeatedly.

### Display Fonts (Headlines, Hero Text)

 | Font             | Character                      | Good For                                      |
 | ------           | -----------                    | ----------                                    |
 | Fraunces         | Soft serif with optical sizing | Warm, approachable brands                     |
 | Playfair Display | High-contrast serif            | Editorial, luxury                             |
 | Instrument Serif | Modern serif                   | Contemporary, refined                         |
 | DM Serif Display | Classic display serif          | Traditional elegance                          |
 | Bodoni Moda      | High-contrast didone           | Fashion, luxury                               |
 | Clash Display    | Bold geometric sans            | Tech, modern                                  |
 | Cabinet Grotesk  | Rounded geometric              | Friendly, approachable                        |
 | Bebas Neue       | Condensed all-caps             | Impact, headlines                             |
 | Space Grotesk    | Geometric with quirks          | Tech, modern (use sparingly—getting overused) |

### Body Fonts (Readable at Small Sizes)

 | Font              | Character               | Good For             |
 | ------            | -----------             | ----------           |
 | Outfit            | Clean geometric sans    | Modern, versatile    |
 | Plus Jakarta Sans | Friendly geometric      | SaaS, apps           |
 | Satoshi           | Sharp geometric         | Tech, minimal        |
 | General Sans      | Neutral with character  | Versatile            |
 | DM Sans           | Geometric, low contrast | Clean interfaces     |
 | Libre Franklin    | Classic sans            | Editorial, long-form |
 | Work Sans         | Optimized for screens   | Apps, dashboards     |

### Monospace Fonts

 | Font           | Character             | Good For          |
 | ------         | -----------           | ----------        |
 | JetBrains Mono | Designed for code     | Developer tools   |
 | IBM Plex Mono  | Neutral, professional | Technical content |
 | Fira Code      | Ligatures for code    | Code editors      |
 | Space Mono     | Quirky, retro         | Retro-futuristic  |
 | Inconsolata    | Clean, readable       | Code display      |

### Quirky / Character Fonts

 | Font                | Character                    | Good For               |
 | ------              | -----------                  | ----------             |
 | Bricolage Grotesque | Variable with optical sizing | Expressive headlines   |
 | Anybody             | Variable width, playful      | Creative, experimental |
 | Rubik               | Rounded, friendly            | Playful interfaces     |
 | Syne                | Geometric, distinctive       | Creative, bold         |
 | Darker Grotesque    | Condensed, high contrast     | Editorial, posters     |

## Pairing Strategies

### Contrast Pairing
Pair a distinctive display font with a neutral body font.

Example: **Fraunces** (display) + **DM Sans** (body)

### Superfamily Pairing
Use fonts designed to work together.

Example: **IBM Plex Sans** + **IBM Plex Serif** + **IBM Plex Mono**

### Weight Contrast
Same font family, different weights for hierarchy.

Example: **Plus Jakarta Sans** at 800 (headlines) + 400 (body)

## Typography Scale

Establish clear hierarchy. The jump between levels should feel significant.

**Example scale (using 1.25 ratio)**:
- Hero: 72px / 4.5rem
- H1: 48px / 3rem
- H2: 36px / 2.25rem
- H3: 24px / 1.5rem
- Body: 16px / 1rem
- Small: 14px / 0.875rem
- Caption: 12px / 0.75rem

**Line height guidance**:
- Headlines: 1.1 - 1.2
- Body text: 1.5 - 1.7
- UI elements: 1.2 - 1.4

## Loading Fonts

### Google Fonts (recommended for prototypes)
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,700&family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
```

### CSS Variables for Consistency
```css
:root {
  --font-display: 'Fraunces', serif;
  --font-body: 'DM Sans', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```

### Font Loading Strategy
Use `font-display: swap` to prevent invisible text during load:
```css
@font-face {
  font-family: 'CustomFont';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap;
}
```
