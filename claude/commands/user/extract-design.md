---
name: extract-design
description: Extract design DNA from a website into a reusable specification with steerable variables
argument-hint: "[URL to analyze]"
---

# Design Extraction Workflow

Extract the design DNA from a production website into a reusable specification that can generate unique variations while preserving identity.

## Input

**URL**: $ARGUMENTS

## Core Concept: Identity vs. Structure

Before extracting, understand what you're separating:

- **Identity Variables**: Change these = different design. (accent color, font choice, hover treatment, generative algorithm)
- **Structural Constants**: Change these = broken design. (responsive breakpoints, accessibility, content hierarchy)

The goal is a spec where swapping identity variables produces recognizable variations, while structural constants ensure quality.

---

## Workflow

### Phase 1: Capture

Navigate and document the initial state.

```
1. browser_navigate → URL
2. browser_take_screenshot → full page (save as {domain}-initial.png)
3. browser_snapshot → DOM structure
```

If the page has a loading state, wait for it to complete before capturing.

### Phase 2: Extract Design Tokens

Use `browser_evaluate` to pull computed styles. Extract into these categories:

**Typography**
| Token | What to Extract |
|-------|-----------------|
| `FONT_PRIMARY` | font-family stack |
| `FONT_SECONDARY` | if different for headings/body |
| `TEXT_SIZE_BASE` | body font-size |
| `TEXT_SIZE_SCALE` | h1/h2/h3 sizes (note if clamp/responsive) |
| `TEXT_WEIGHT_BODY` | body font-weight |
| `TEXT_WEIGHT_HEADING` | heading font-weight |
| `TEXT_TRACKING` | letter-spacing (critical for identity) |
| `TEXT_LEADING` | line-height |
| `TEXT_TRANSFORM` | uppercase/lowercase/none |

**Colors**
| Token | What to Extract |
|-------|-----------------|
| `COLOR_BG` | body/page background |
| `COLOR_SURFACE` | card/container backgrounds |
| `COLOR_TEXT_PRIMARY` | main text color |
| `COLOR_TEXT_SECONDARY` | supporting text |
| `COLOR_TEXT_MUTED` | tertiary/disabled |
| `COLOR_ACCENT_PRIMARY` | brand/action color |
| `COLOR_ACCENT_SECONDARY` | secondary accent if present |
| `COLOR_BORDER` | divider/outline color |

**Spacing & Layout**
| Token | What to Extract |
|-------|-----------------|
| `SPACING_UNIT` | base unit (4px, 8px, etc.) |
| `CONTAINER_MAX_WIDTH` | content constraint |
| `GRID_COLUMNS` | if grid-based |
| `GRID_GAP` | gap value |
| `LAYOUT_PADDING` | container padding |

**Surfaces**
| Token | What to Extract |
|-------|-----------------|
| `SURFACE_RADIUS` | border-radius |
| `SURFACE_SHADOW` | box-shadow (or "none") |
| `SURFACE_BORDER` | border style (or "none") |
| `SURFACE_BLUR` | backdrop-filter if present |

### Phase 3: Discover Interactions

Hover over interactive elements and document what changes.

```
1. browser_hover → links, cards, buttons
2. browser_take_screenshot → each hover state
3. browser_evaluate → extract transition properties
```

Document:
| Token | What to Extract |
|-------|-----------------|
| `TRANSITION_DURATION` | timing (150ms, 300ms, etc.) |
| `TRANSITION_EASING` | curve (ease, cubic-bezier, etc.) |
| `HOVER_TREATMENT` | what changes (color, underline, scale, shadow, etc.) |
| `FOCUS_TREATMENT` | keyboard focus indicator |
| `ANIMATION_STYLE` | dominant animation type (slide, fade, scale, bounce) |

### Phase 4: Identify Generative/Dynamic Elements

Look for elements that change on load or interaction:

- Canvas elements (generative backgrounds)
- SVG filters (noise, displacement)
- CSS animations
- JavaScript-driven effects
- Randomization on page load

If found:
```
1. Identify the element type and trigger
2. Document what varies vs. what's constant
3. Describe the algorithm conceptually (don't copy obfuscated code)
```

| Token | What to Extract |
|-------|-----------------|
| `GENERATIVE_TYPE` | grid, particles, gradient, noise, static |
| `GENERATIVE_TRIGGER` | load, hover, scroll, time |
| `GENERATIVE_RANGE` | what varies (color hue, position, opacity, etc.) |

### Phase 5: Refresh and Compare

Reload the page 2-3 times to detect randomization.

```
1. browser_navigate → same URL (force reload)
2. browser_take_screenshot → save as {domain}-variation-{n}.png
3. Compare with initial screenshot
4. Document what changed vs. what stayed constant
```

### Phase 6: Classify Motif

Based on your extraction, classify into a primary motif:

| Motif | Typography | Colors | Surfaces | Interactions | Feeling |
|-------|------------|--------|----------|--------------|---------|
| `swiss-minimalism` | System UI, extreme size contrast, tight tracking | Near-white bg, black text, single accent | Flat, no shadows | Minimal (underline) | Clean, confident, mathematical |
| `brutalism` | Monospace, ALL CAPS, chunky | High contrast (black/yellow, white/red) | Raw borders, visible structure, no radius | Abrupt, no transitions | Honest, confrontational, raw |
| `terminal-cyber` | Monospace only (JetBrains, Fira, IBM Plex), uppercase | Black bg (#0a0a0a), neon green (#00ff41), amber (#ffb000) | Hard borders, ASCII box-drawing, CRT glow | Typewriter, blink cursor, scanlines | Hacker, retro-futurist, 80s sci-fi |
| `editorial` | Serif body, sans headings, refined scale | Off-white (#faf9f7), sophisticated grays | Elegant shadows, fine borders, subtle radius | Subtle, luxurious timing | Sophisticated, literary, premium |
| `maximalist` | Mixed type, decorative display fonts, variable weights | Rich, saturated, 4+ colors | Layered, textured, busy, chunky shadows | Playful, unexpected, bouncy | Bold, expressive, memorable |
| `glassmorphism` | Clean sans, medium weight, good contrast | Translucent surfaces, vibrant backdrops | Blur (8-20px), subtle borders, glow edges | Smooth fades, floating layers | Modern, layered, premium |
| `aurora-gradient` | Clean geometric sans, light weights | Mesh gradients, purple-pink-blue, luminous | Flowing color transitions, soft edges | Animated gradients, parallax | Ethereal, AI-era, futuristic |
| `dark-luxury` | Thin weights, generous tracking, subtle serif | Deep blacks (#000-#0a0a0a), minimal glow | Subtle borders, velvet textures, OLED blacks | Cinematic timing, restrained | Premium, exclusive, cinematic |
| `organic-biomorphic` | Rounded sans, hand-drawn options, friendly weights | Nature-inspired, soft pastels, earth tones | Blob shapes, curved containers, SVG masks | Morphing, gooey, fluid | Warm, human, approachable |

**Motif combinations** (common in production):
- `swiss-minimalism` + `aurora-gradient` = Modern SaaS hero (Vercel, Linear)
- `dark-luxury` + `glassmorphism` = Premium dark mode (Apple, high-end products)
- `editorial` + `organic-biomorphic` = Content platforms (Notion, newsletters)
- `brutalism` + `maximalist` = Creative agencies, portfolios
- `terminal-cyber` + `brutalism` = Developer tools, CLI apps, hacker aesthetic
- `terminal-cyber` + `dark-luxury` = Premium dev tools (Warp, Fig, Raycast)

Provide evidence for your classification. If a design combines motifs, identify the primary and note the secondary influence.

### Phase 7: Write the Specification

Output to `history/reverse-prompt-{domain}.md` with this structure:

```markdown
# Reverse Prompt: {Domain Name}

> Reverse-engineered from {URL} on {DATE}

## Design Identity Summary

{2-3 sentences capturing what makes this design THIS design. What tension does it create? What's the single most distinctive choice?}

## Structural Pattern

{ASCII diagram showing layout relationships, not pixel measurements}

## Extracted Variables

### Typography
| Variable | Value | Notes |
|----------|-------|-------|
| `{{FONT_PRIMARY}}` | {value} | {usage context} |
{...complete table}

### Colors
| Variable | Value | Usage |
|----------|-------|-------|
| `{{COLOR_BG}}` | {value} | {where used} |
{...complete table}

### Spacing & Layout
{...table}

### Surfaces
{...table}

### Interactions
{...table}

### Generative Elements
{...table, or "None" if static}

## Motif Classification

**Primary Motif**: `{motif-name}`

| Indicator | Evidence |
|-----------|----------|
| Typography | {what you observed} |
| Colors | {what you observed} |
| Surfaces | {what you observed} |
| Interactions | {what you observed} |

## Identity vs. Structure

**Identity Variables** (change these = different but valid design):
- {VAR_1}: {why it's identity}
- {VAR_2}: {why it's identity}

**Structural Constants** (change these = broken design):
- Responsive breakpoints
- Content hierarchy
- Accessibility requirements

## Motif Variations

Show how this design's structure adapts to 2-3 contrasting motifs:

### As {contrasting-motif-1}
- Typography: {what changes}
- Colors: {what changes}
- Surfaces: {what changes}
- Interactions: {what changes}

### As {contrasting-motif-2}
{...}

Available motifs: `swiss-minimalism`, `brutalism`, `terminal-cyber`, `editorial`, `maximalist`, `glassmorphism`, `aurora-gradient`, `dark-luxury`, `organic-biomorphic`

## Usage

\`\`\`
Generate a {component/page type} using this design system:

Context:
- Brand: {{BRAND_NAME}}
- Purpose: {{PURPOSE}}

Identity Variables:
- {{FONT_PRIMARY}}: [value]
- {{COLOR_ACCENT_PRIMARY}}: [value]
- {{HOVER_TREATMENT}}: [value]

Output should feel: {identity summary in one line}
\`\`\`

## Artifacts

- `{domain}-initial.png` - Initial state
- `{domain}-hover-{element}.png` - Hover states
- `{domain}-variation-{n}.png` - Randomization captures (if any)
```

---

## Output

The command produces:
1. Screenshots in `.playwright-mcp/` directory
2. Specification at `history/reverse-prompt-{domain}.md`
3. Summary in chat with key findings

## Extraction Checklist

Before declaring complete:

- [ ] Can someone recreate the *feeling* from just the Identity Summary?
- [ ] Are ALL hardcoded values extracted into variables?
- [ ] Is the motif classification backed by specific evidence?
- [ ] Do the motif variations actually make sense (mentally test them)?
- [ ] Is the usage prompt specific enough to generate consistent results?
- [ ] Is the usage prompt flexible enough to allow variation?
- [ ] Did you capture multiple states if the design has randomization?

## Notes

- Focus on visual output, not framework implementation
- If JavaScript is obfuscated, describe behavior not code
- Pay attention to "invisible" choices: spacing ratios, type scale progression, transition timing
- The spec should be implementation-agnostic (CSS, Tailwind, whatever)
