---
name: frontend-design
description: This skill should be used when the user asks to "build a landing page", "create a dashboard", "design a component", "make a website", "build a UI", "create a portfolio site", "design a form", "build a card component", "improve my website", or requests any frontend interface work. Provides creative direction and systematic implementation standards for distinctive, production-grade interfaces.
---

# Frontend Design

Create distinctive, production-grade interfaces that avoid generic "AI slop" aesthetics. This skill combines creative vision with systematic execution.

## Design Process

### Step 1: Extract Context

Before writing code, identify:
- **Product type**: SaaS, e-commerce, portfolio, dashboard, landing page, blog, mobile app
- **Industry**: Healthcare, fintech, gaming, education, beauty, creative, etc.
- **Audience**: Technical users, consumers, enterprise, creative professionals
- **Stack**: React, Vue, Next.js, Svelte, or vanilla HTML/CSS/JS (default)
- **Mood**: What feeling should the interface evoke?

### Step 2: Commit to an Aesthetic Direction

Select a clear conceptual direction. Execute with conviction—the key is intentionality, not intensity.

 | Direction              | Characteristics                                                         |
 | -----------            | -----------------                                                       |
 | Brutally minimal       | Extreme reduction, monochrome, stark typography, maximum whitespace     |
 | Maximalist chaos       | Layered elements, clashing colors, visual density, controlled overwhelm |
 | Retro-futuristic       | CRT aesthetics, scan lines, neon on dark, terminal fonts                |
 | Organic/natural        | Soft edges, earthy palettes, flowing shapes, hand-drawn elements        |
 | Luxury/refined         | Restrained elegance, serif typography, generous space, subtle details   |
 | Playful/toy-like       | Rounded forms, bright primaries, bouncy animations, oversized elements  |
 | Editorial/magazine     | Strong grid, dramatic type scale, pull quotes, image-centric            |
 | Brutalist/raw          | Exposed structure, system fonts used intentionally, anti-design         |
 | Art deco/geometric     | Symmetry, gold accents, repeating patterns, ornamental borders          |
 | Industrial/utilitarian | Exposed mechanics, warning colors, functional aesthetic                 |

### Step 3: Define the Memorable Element

Identify the ONE thing someone will remember about this interface:
- An unusual scroll interaction
- A striking color combination
- Typography that commands attention
- A micro-interaction that delights
- An unexpected layout choice

If no memorable element exists, the design is incomplete—it's just assembled components.

---

## Core Guidelines

### Typography

Choose fonts with character. Pair a distinctive display font with a refined body font.

**Never use**: Arial, Helvetica, Inter, Roboto, Open Sans, system-ui defaults

**Establish hierarchy**: Hero text should feel dramatically different from body copy, not just "slightly bigger."

### Color & Theme

- Commit to a dominant color with sharp accents (avoid evenly-distributed palettes)
- Define palette in CSS variables (`:root`) for consistency
- Design both light and dark modes intentionally—never just invert

**Light mode**: High-contrast text (`slate-900`), `bg-white/80`+ for glass effects, visible borders (`gray-200`+)

**Dark mode**: Lower opacity glass effects (`bg-white/10-20`), `border-white/10-20`

### Motion

Philosophy: One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.

**Timing**:
- Micro-interactions: 150-200ms
- Element transitions: 200-300ms
- Page transitions: 300-500ms
- Never exceed 500ms for UI feedback

Respect `prefers-reduced-motion`.

### Spatial Composition

Break the grid intentionally:
- Asymmetric layouts for visual tension
- Overlapping elements for depth
- Floating elements with breathing room (`top-4 left-4 right-4` not `top-0`)
- Commit to generous whitespace OR controlled density

### Visual Atmosphere

Avoid solid color backgrounds. Create depth with gradient meshes, subtle noise/grain, geometric patterns, layered transparencies, dramatic shadows, decorative borders.

---

## Implementation Standards

### Icons

 | Do                                                               | Don't                   |
 | ----                                                             | -------                 |
 | Use SVG icons from consistent sets (Heroicons, Lucide, Phosphor) | Use emojis as UI icons  |
 | Fixed viewBox (24x24), consistent sizing (w-5/w-6)               | Mix icon sizes randomly |
 | Research brand logos from Simple Icons                           | Guess logo paths        |

### Interactions

 | Do                                               | Don't                                    |
 | ----                                             | -------                                  |
 | `cursor-pointer` on ALL clickable elements       | Default cursor on interactive cards      |
 | Visual feedback on hover (color, shadow, border) | No hover indication                      |
 | `transition-colors duration-200`                 | Instant or sluggish (>500ms) transitions |
 | Visible focus states for keyboard navigation     | Hover-only states                        |

### Layout

 | Do                                         | Don't                                  |
 | ----                                       | -------                                |
 | Account for fixed navbar height in content | Let content hide behind fixed elements |
 | Consistent max-width containers            | Mix container widths arbitrarily       |
 | Test at 320px, 768px, 1024px, 1440px       | Check only one viewport                |
 | No horizontal scroll on mobile             | Ignore overflow                        |

### Accessibility

- Color contrast: 4.5:1 minimum for body text, 3:1 for large text
- All images have meaningful `alt` text
- Form inputs have associated labels
- Semantic HTML elements (nav, main, article, button)

---

## Additional Resources

### Reference Files

Consult these for detailed guidance:

- **`references/anti-patterns.md`** - Common AI-generated aesthetic mistakes to avoid
- **`references/checklist.md`** - Pre-delivery verification checklist
- **`references/typography.md`** - Font recommendations and pairing guidance
- **`references/stack-guides.md`** - Framework-specific implementation notes

---

## Final Note

The goal is **distinctive**, not "acceptable." Every interface should feel designed by someone with taste and intention, not assembled from a template library.

Break conventions when it serves the design. Follow conventions when they genuinely help users.
