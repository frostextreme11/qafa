# Design System Documentation: The Celestial Prism

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Celestial Prism."** 

This system moves beyond traditional Islamic app aesthetics—which often rely on heavy ornamentation—to embrace a future-forward, high-tech serenity. It treats the interface as a digital sanctuary where light, glass, and shadow converge. By utilizing glassmorphism and intentional asymmetry, we break the "template" look common in utility apps. The design system creates a sense of infinite depth, mimicking the night sky through layered translucency and sophisticated tonal shifts. Elements should feel like they are floating in a vacuum of prayerful silence, overlapping with purpose to guide the user’s eye through a curated editorial experience.

## 2. Colors & Surface Philosophy
The palette is rooted in the deep reaches of the cosmos (`#02161d`) and the life-giving vibrance of Emerald (`#3ce36a`) and Gold (`#ffdb3c`).

### The "No-Line" Rule
To maintain a premium feel, 1px solid borders are strictly prohibited for defining sections. Structure must be felt, not seen. Boundaries are defined through:
*   **Tonal Transitions:** Transitioning from `surface-container-low` to `surface-container-high`.
*   **Backdrop Blur:** Distinguishing a foreground element from the background via `backdrop-filter: blur(20px)`.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of frosted glass sheets.
*   **Level 0 (Base):** `surface` (`#02161d`) - The infinite foundation.
*   **Level 1 (Sections):** `surface-container-low` - Large structural areas.
*   **Level 2 (Cards/Modules):** `surface-container-high` - Primary interactive areas.
*   **Level 3 (Pop-overs/Modals):** `surface-container-highest` - Temporary, high-focus elements.

### The "Glass & Gradient" Rule
For main CTAs and Hero backgrounds, use a **Signature Texture**: a linear gradient from `primary` (`#3ce36a`) to `primary_container` (`#004f1c`) at a 135-degree angle. Floating elements must use a semi-transparent `surface_variant` with a 24px-40px blur to allow the deep midnight blues and emeralds to bleed through, creating "visual soul."

## 3. Typography
The typography strategy balances the architectural strength of **Manrope** with the technical clarity of **Inter**.

*   **Display & Headlines (Manrope):** Used for spiritual headers, verse numbers, and high-impact editorial statements. Manrope’s geometric nature provides a "High-Tech" feel. Use `display-lg` (3.5rem) with tighter tracking (-2%) to create an authoritative, premium look.
*   **Titles & Body (Inter):** Used for functional reading and micro-copy. Inter’s neutrality ensures that the complex glass textures of the UI do not distract from the sacred text or prayer times.
*   **Hierarchy as Identity:** Create "Editorial Rhythm" by pairing a `display-sm` headline with a significantly smaller `label-md` uppercase subtitle. This high-contrast scale is what separates this design system from a generic utility app.

## 4. Elevation & Depth
In this system, depth is a tool for focus, not just decoration.

*   **The Layering Principle:** Achieve "lift" by stacking tiers. Place a `surface-container-lowest` card inside a `surface-container-low` section. This creates a soft, recessed "carved" look that feels more modern than a standard drop shadow.
*   **Ambient Shadows:** When an element must float (like a Floating Action Button), use a shadow color tinted with `surface_tint` (`#3ce36a`) at 8% opacity with a 32px blur. This simulates light passing through green glass.
*   **The "Ghost Border":** For accessibility, use the `outline-variant` token at 15% opacity. This "Ghost Border" provides just enough definition to catch the light on the edge of a glass pane without creating a hard visual break.
*   **Asymmetric Breathing Room:** Do not center-align everything. Use the `xl` (1.5rem) roundedness scale on three corners and `none` (0px) on one corner of a card to create a signature "architectural" silhouette.

## 5. Components

### Buttons
*   **Primary:** A vibrant Emerald gradient (`primary` to `primary_container`) with `lg` (1rem) roundedness. Use `on_primary` for text.
*   **Secondary (Glass):** A semi-transparent `surface_bright` with a 20px blur and a "Ghost Border" of Gold (`secondary`).
*   **Tertiary:** Text-only using `tertiary` (`#45d8ed`) with an uppercase `label-md` style.

### Cards & Lists
*   **Prohibited:** Divider lines.
*   **Execution:** Separate list items using 12px of vertical white space or by alternating between `surface-container-low` and `surface-container-lowest`.
*   **Glass Cards:** Use for prayer time modules. Apply `backdrop-filter: blur(16px)` and a subtle `outline-variant` (10% opacity) top-border to mimic a light-catching edge.

### Input Fields
*   **Style:** Recessed glass. Use `surface_container_lowest` with a subtle inner shadow.
*   **Focus State:** The "Ghost Border" increases to 40% opacity using the `primary` emerald color.

### Chips (Prayer Tags/Filters)
*   **Selection Chips:** Use `secondary_container` (Gold) for active states to provide a "premium glow" against the dark background.
*   **Shape:** Always `full` (pill-shaped) to contrast against the more architectural `lg` and `xl` corners of the containers.

## 6. Do's and Don'ts

### Do
*   **Do** use overlapping elements. A glass card should slightly overlap a hero image or gradient to demonstrate the blur effect.
*   **Do** prioritize "negative space." High-end design is defined by what you leave out.
*   **Do** use gold (`secondary`) sparingly as a "divine spark"—only for the most important active states or accomplishments.

### Don't
*   **Don't** use pure black or pure white. Use `surface_dim` for backgrounds and `on_surface_variant` for secondary text to maintain the "Midnight" atmosphere.
*   **Don't** use standard "drop shadows" (0, 4, 4, 0). They look "cheap" in a glassmorphic system. Use large, diffused, tinted ambient glows.
*   **Don't** clutter the screen. If a screen feels busy, increase the background blur and the spacing scale.