# omega-hub (Discourse theme)

The theme for forum.duelistsunite.org, built on the Omega Hub design system.

## Layout

- `common/`, `desktop/`, `mobile/`: base styles and HTML.
- `stylesheets/`: the Duelists Unite layers, imported at the end of `common/common.scss`. Each one used to be its own theme component:
  - `du-readable-fonts.scss`: Figtree for small labels instead of Space Mono, with easier letter spacing. Figures stay in Oxanium, and code stays monospace.
  - `du-navigation-fixes.scss`: a "Duelists Unite" section in the ☰ menu, the header order, the header menu at 1024–1279px, and the hero "Download YGO Omega" button.
  - `du-hero-art.scss`: dragon art behind the hero and behind each category block, and KurAi and ShirAi facing off on wide screens. The art reveals on hover, or on scroll on touch screens.
  - `du-playful.scss`: one color-blind-safe accent (Okabe-Ito) and one animation per forum section, plus springy buttons and quick page fades.
  - `du-polish.scss`: the phone bottom bar, the "page not found" screen, and the current footer year.
- `javascripts/discourse/`: connectors (`omega-home`, `omega-hero`, `omega-category`…) and api-initializers (`omega-*` and `du-*`).
- `assets/`: logos, category icons, the hero art, the mascots, the 404 art and the sponsor stickers.

## Settings

The Nitro ads, the header menu (`header_links`) and the header icons, plus:

- `hero_art_style`: duotone, original or none.
- `show_mascots`: whether KurAi and ShirAi appear behind the hero stats.

## Deploy

Import the theme from this repository (Admin → Appearance → Themes → Install → From a git repository) and use *Check for updates* after each push.

Before the first update with these files, remove or disable the old components (DU Readable Fonts, DU Navigation Fixes, DU Hero Art, DU Playful Sections, DU Polish). Their code now lives here, and leaving them on would apply it twice.

Theme uploads must use the forum's allowed extensions (jpg/png/svg/woff…). WebP is not allowed, and uploads over about 1 MB are refused.
