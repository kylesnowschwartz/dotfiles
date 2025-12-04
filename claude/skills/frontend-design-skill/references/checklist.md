# Pre-Delivery Checklist

Verify these items before delivering frontend code.

## Creative Quality

- [ ] Aesthetic direction is clear and intentional
- [ ] At least one memorable/distinctive element exists
- [ ] Typography choices have character (not Inter/Roboto/Arial)
- [ ] Color palette is cohesive with clear hierarchy
- [ ] Layout has intentional composition (not just stacked sections)

## Visual Polish

- [ ] No emojis used as UI icons
- [ ] All icons from consistent icon set with uniform sizing
- [ ] Brand logos verified correct (if applicable)
- [ ] Hover states provide feedback without layout shift
- [ ] Animations are smooth and purposeful

## Technical Quality

- [ ] All clickable elements have `cursor-pointer`
- [ ] Transitions use appropriate timing (150-300ms)
- [ ] Focus states visible for keyboard navigation
- [ ] Responsive at 320px, 768px, 1024px, 1440px
- [ ] No horizontal scroll on mobile
- [ ] Fixed elements don't obscure content

## Accessibility

- [ ] Text contrast meets 4.5:1 minimum (body) / 3:1 (large text)
- [ ] Light mode glass/transparent elements visible
- [ ] All images have alt text
- [ ] Form inputs have labels
- [ ] `prefers-reduced-motion` respected
- [ ] Semantic HTML elements used (nav, main, article, button vs div)

## Light/Dark Mode (if applicable)

### Light Mode
- [ ] Text uses high-contrast colors (`slate-900` / `#0F172A`)
- [ ] Muted text at `slate-600` / `#475569` minimum
- [ ] Glass effects at `bg-white/80` or higher opacity
- [ ] Borders at `border-gray-200` or darker

### Dark Mode
- [ ] Sufficient contrast against dark backgrounds
- [ ] Glass effects at `bg-white/10` to `bg-white/20`
- [ ] Borders at `border-white/10` to `border-white/20`

## Final Verification

- [ ] Tested in both Chrome and Firefox (minimum)
- [ ] No console errors
- [ ] All links/buttons functional
- [ ] Forms submit correctly (if applicable)
- [ ] Images load and display at correct sizes
