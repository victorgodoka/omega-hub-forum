# Duelists Unite theme components

These are the theme components running on forum.duelistsunite.org on top of omega-hub (this theme).
They live in this folder for safekeeping and review. Discourse only imports files from the theme's
top-level folders (`common/`, `javascripts/`, `assets/`, ...), so nothing here affects omega-hub itself.

Each folder is a complete component: `about.json` at its root, plus `common/`, `javascripts/`,
`assets/` and `settings.yml` where needed.

| Folder | Live name | What it does |
|---|---|---|
| `du-readable-fonts` | DU Readable Fonts | Uses Figtree (the body font) for the hero title, stat numbers and small labels instead of Archivo / Space Mono, with easier letter spacing. Code blocks stay monospace. |
| `du-navigation-fixes` | DU Navigation Fixes | Adds a "Duelists Unite" section at the top of the ☰ menu (Download, Web Simulator, Combo Calculator, Banlist Creator, Card Creator, tournaments, stats, tier lists, Discord), because the header menu is hidden below 1280px. Keeps the header menu visible at 1024–1279px. Reorders the header to logo · menu … search · Log In / Sign Up · ☰. Adds a "Download YGO Omega" hero button. Opens the last dropdown leftwards. |
| `du-hero-art` | DU Hero Art | Dragon art behind the homepage hero (navy/cyan duotone, kept dark behind text), plus Kurai and ShirAI facing off with duel disks on wide screens. They are dark silhouettes at rest and reveal in colour on hover, or on scroll on touch screens. Settings: `hero_art_style` (duotone / original / none), `show_mascots`. Also shares the art as `--du-art` for other components. |
| `du-playful` | DU Playful Sections | Every section gets its own colour and animation. Omega spins, Website wobbles, Yu-Gi-Oh flips, Tournaments jumps, Dorm Wars clashes, Watercooler bobs. Category pages get a coloured frame, the category logo as an emblem, and tinted art. Buttons have a springy press, ☰ items pop in, and page changes fade quickly. CSS transform/opacity only; everything is off under `prefers-reduced-motion`. |
| `du-polish` | DU Polish | Phone bottom bar (Home · Latest · Download · Simulator · Menu). Hides the 2020 "About the … category" rows and the "N total" labels on homepage cards. A "page not found" screen with Kurai and ShirAI, which also fixes that page's sideways scroll on phones. Keeps the footer year current. Ad slots are left alone. |

## Install or update a component

1. Zip the component folder's contents, so that `about.json` is at the zip root.
2. Admin → Appearance → Themes & components → Components → Install → *From your device* → choose the zip.
   A component with the same name is updated in place.
3. Open the component → *Include component on these themes* → omega-hub.

Notes:
- Theme uploads must use the forum's allowed extensions (jpg/png/svg/woff…). WebP is not allowed here, which is why the art is quantized PNG/JPG.
- After updating a component, the forum can keep serving the old stylesheet for a while. To force a refresh,
  run in the rails console:
  `Theme.find(<component id>).notify_theme_change(with_scheme: false); Theme.find(<omega-hub id>).notify_theme_change(with_scheme: false); Stylesheet::Manager.clear_theme_cache!`

## Header menu

The header menu comes from omega-hub's `header_links` setting. That setting is stored on the forum, not in this repo.
The default in `settings.yml` mirrors the live menu as of 2026-11-24. The live menu's icons are forum uploads, so
they aren't part of the default. The ☰ "Duelists Unite" section in `du-navigation-fixes` uses the same tool names.
