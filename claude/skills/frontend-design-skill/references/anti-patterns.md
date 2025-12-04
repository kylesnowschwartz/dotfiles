# Anti-Patterns: Hallmarks of Generic AI-Generated Interfaces

These patterns indicate lazy, template-driven design. Avoid them.

## 1. The Inter/Roboto Default

System fonts masquerading as design choices. When every AI-generated site uses the same "safe" sans-serif, it signals zero creative consideration.

**Instead**: Choose fonts with character appropriate to the aesthetic direction.

## 2. Purple Gradient on White

The most overused AI color scheme. Purple-to-blue gradients on white backgrounds have become a cliché signaling "AI made this."

**Instead**: Commit to a distinctive palette that serves the brand/purpose.

## 3. Evenly-Spaced Card Grids

Every element the same size, same gap, same border radius. No hierarchy, no visual interest, no thought.

**Instead**: Vary card sizes, create visual hierarchy, break the grid intentionally.

## 4. Emoji as Icons

Using emojis as UI elements is amateur:
- "Launch" with a rocket emoji
- "Features" with sparkles
- "Ideas" with a lightbulb

**Instead**: Use proper SVG icons from a consistent icon set (Heroicons, Lucide, Phosphor, Tabler).

## 5. Scale-on-Hover Cards

Cards that `transform: scale(1.05)` on hover cause layout shift, feel broken, and indicate cargo-culted "interactivity."

**Instead**: Use color, shadow, or border changes that don't affect layout.

## 6. Invisible Borders in Light Mode

Using `border-white/10` or similar on white backgrounds creates invisible borders that look like bugs.

**Instead**: Use `border-gray-200` or darker in light mode, reserve low-opacity borders for dark mode.

## 7. Low-Contrast Muted Text

Gray-400 or lighter text for "secondary" content fails accessibility and looks washed out.

**Instead**: Use `slate-600` / `#475569` minimum for muted text.

## 8. Cookie-Cutter Hero Sections

The formula: Big headline, subtext underneath, two buttons (primary + ghost), gradient blob in the corner.

**Instead**: Design hero sections that serve the specific content and brand. Not every page needs the same structure.

## 9. Placeholder Content Aesthetic

Designs that look like they're waiting for "real" content. Lorem ipsum, stock photos, and generic copy produce generic results.

**Instead**: Design around actual content when possible; at minimum, use realistic placeholder content.

## 10. Framework Default Styling

Shipping with obvious Bootstrap, Material UI, or Tailwind UI defaults without customization.

**Instead**: Customize component styles to match the aesthetic direction. The framework is a tool, not a design system.
