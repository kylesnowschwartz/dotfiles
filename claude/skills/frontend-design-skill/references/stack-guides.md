# Stack-Specific Implementation Guides

## Vanilla HTML/CSS/JS (Default)

The simplest approach. No build step, no framework overhead.

### Setup
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Title</title>
  <!-- Tailwind via CDN for rapid prototyping -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            primary: '#...',
          },
          fontFamily: {
            display: ['Font Name', 'serif'],
            body: ['Font Name', 'sans-serif'],
          }
        }
      }
    }
  </script>
  <!-- Or write semantic CSS -->
  <style>
    :root {
      --color-primary: #...;
      --font-display: 'Font Name', serif;
    }
  </style>
</head>
```

### Theming with CSS Variables
```css
:root {
  --color-bg: #ffffff;
  --color-text: #0f172a;
  --color-primary: #3b82f6;
  --color-muted: #64748b;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #0f172a;
    --color-text: #f8fafc;
  }
}
```

### Animations (CSS-only)
```css
@keyframes fade-in {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-in {
  animation: fade-in 0.5s ease-out forwards;
}

/* Staggered delays */
.delay-1 { animation-delay: 0.1s; }
.delay-2 { animation-delay: 0.2s; }
.delay-3 { animation-delay: 0.3s; }

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .animate-in {
    animation: none;
    opacity: 1;
  }
}
```

### Scroll Animations (Vanilla JS)
```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('animate-in');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
```

---

## React / Next.js

### Styling Options

Pick ONE approach and use it consistently:

1. **Tailwind CSS** - Utility classes, fast prototyping
2. **CSS Modules** - Scoped styles, no runtime cost
3. **styled-components** - CSS-in-JS, dynamic styles

### Animation with Motion (framer-motion)

```bash
npm install motion
```

```tsx
import { motion } from 'motion/react';

// Fade in on mount
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5 }}
>
  Content
</motion.div>

// Staggered children
<motion.ul
  initial="hidden"
  animate="visible"
  variants={{
    visible: { transition: { staggerChildren: 0.1 } }
  }}
>
  {items.map(item => (
    <motion.li
      key={item.id}
      variants={{
        hidden: { opacity: 0, y: 20 },
        visible: { opacity: 1, y: 0 }
      }}
    >
      {item.name}
    </motion.li>
  ))}
</motion.ul>
```

### Next.js Specifics

**Image optimization**:
```tsx
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Descriptive alt text"
  width={1200}
  height={600}
  priority // for above-the-fold images
/>
```

**Font optimization** (Next.js 13+):
```tsx
// app/layout.tsx
import { Fraunces, DM_Sans } from 'next/font/google';

const fraunces = Fraunces({
  subsets: ['latin'],
  variable: '--font-display',
});

const dmSans = DM_Sans({
  subsets: ['latin'],
  variable: '--font-body',
});

export default function RootLayout({ children }) {
  return (
    <html className={`${fraunces.variable} ${dmSans.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

**Server vs Client Components**:
- Server components: Static content, data fetching
- Client components: Interactivity, animations, state

```tsx
'use client'; // Add this for interactive components

import { useState } from 'react';
```

---

## Vue / Nuxt

### Scoped Styles
```vue
<style scoped>
.component {
  /* Automatically scoped to this component */
}
</style>
```

### CSS Variables for Theming
```vue
<style>
:root {
  --color-primary: #3b82f6;
}
</style>
```

### Transitions
```vue
<template>
  <Transition name="fade">
    <div v-if="show">Content</div>
  </Transition>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
```

### Staggered List Transitions
```vue
<template>
  <TransitionGroup name="list" tag="ul">
    <li v-for="(item, index) in items" :key="item.id" :style="{ '--i': index }">
      {{ item.name }}
    </li>
  </TransitionGroup>
</template>

<style>
.list-enter-active {
  transition: all 0.5s ease;
  transition-delay: calc(var(--i) * 0.1s);
}
.list-enter-from {
  opacity: 0;
  transform: translateY(20px);
}
</style>
```

### Composition API Pattern
```vue
<script setup>
import { ref, computed } from 'vue';

const count = ref(0);
const doubled = computed(() => count.value * 2);
</script>
```

---

## Svelte / SvelteKit

### Scoped Styles (Default)
```svelte
<style>
  /* Automatically scoped */
  .card {
    padding: 1rem;
  }
</style>
```

### Built-in Transitions
```svelte
<script>
  import { fade, fly, slide } from 'svelte/transition';
  let visible = true;
</script>

<button on:click={() => visible = !visible}>Toggle</button>

{#if visible}
  <div transition:fade={{ duration: 300 }}>
    Fades in and out
  </div>

  <div in:fly={{ y: 20, duration: 500 }} out:fade>
    Flies in, fades out
  </div>
{/if}
```

### Staggered Animations
```svelte
<script>
  import { fly } from 'svelte/transition';
  let items = [...];
</script>

{#each items as item, i}
  <div
    in:fly={{ y: 20, delay: i * 100, duration: 500 }}
  >
    {item.name}
  </div>
{/each}
```

### Svelte 5 Runes
```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);

  function increment() {
    count++;
  }
</script>
```

### Spring Animations
```svelte
<script>
  import { spring } from 'svelte/motion';

  let coords = spring({ x: 0, y: 0 }, {
    stiffness: 0.1,
    damping: 0.25
  });
</script>

<div
  on:mousemove={(e) => coords.set({ x: e.clientX, y: e.clientY })}
  style="transform: translate({$coords.x}px, {$coords.y}px)"
>
  Follows cursor smoothly
</div>
```

---

## Common Patterns Across Stacks

### Responsive Breakpoints
```css
/* Mobile first */
.container { padding: 1rem; }

/* Tablet */
@media (min-width: 768px) {
  .container { padding: 2rem; }
}

/* Desktop */
@media (min-width: 1024px) {
  .container { padding: 4rem; max-width: 1200px; }
}
```

### Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Dark Mode Toggle
```javascript
// Check system preference
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

// Toggle class on html element
document.documentElement.classList.toggle('dark', prefersDark);

// Manual toggle
function toggleTheme() {
  document.documentElement.classList.toggle('dark');
  localStorage.setItem('theme',
    document.documentElement.classList.contains('dark') ? 'dark' : 'light'
  );
}
```
