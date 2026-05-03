# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Fortress design system foundation: tokens (`src/styles/tokens.css`), shell
  utilities (`src/styles/shell.css`), and self-hosted IBM Plex Sans/Mono +
  Bebas Neue fonts in `public/fonts/`.
- Base components: `Nav.astro` (optional `links` prop, mobile toggle script),
  `Footer.astro` (optional sitemap and legal columns), `ThresholdMark.astro`,
  `BaseLayout.astro` (configurable chrome via `navLinks`, `footerSitemapLinks`,
  `showFooterLegal` props).
- `OrganizationSchema.astro` JSON-LD updated to Lexington, KY.
- `splash-prompt.md` follow-up brief for the Claude Design teaser page.
- `just` devcontainer feature replaces broken apt install.
- `CLAUDE.md` with project conventions for future Claude Code sessions.
- Splash page at `/` (`src/pages/index.astro`) — HeroA-based stripped
  sibling of the eventual full home, rendered with `SplashLayout.astro`,
  `LogoCombo.astro`, and `src/styles/splash.css`. Mailto-only CTA, no
  nav links, stripped footer. Replaces the scaffold placeholder.
- `.logo-combo` lockup utility added to `shell.css` (mark + wordmark,
  shared between splash chrome and the full-site nav after merge).

### Changed
- `Dockerfile` no longer attempts to apt-install `just` (not in Bookworm
  repos); installed via `ghcr.io/guiyomh/features/just:0` devcontainer
  feature instead.
- `src/styles/global.css` reduced to a thin import seam over tokens + shell.
- `.gitignore` now excludes `.wrangler/` local state.

### Notes
- The full multi-page site (services, how-i-work, pricing, faq, ecosystem,
  about, contact) lives on `feature/full-site` and will replace the splash
  page on main when content is ready.
