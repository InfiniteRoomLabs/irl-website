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
- Wired up Tailwind v4 (`@import 'tailwindcss'` was missing from the CSS
  entry, so utilities weren't being emitted at all). Added
  `src/styles/theme.css` with a `@theme` block exposing Fortress tokens
  as utility classes (`bg-surface`, `text-fg-2`, `border-rule`,
  `font-display`, `tracking-eyebrow`, `bg-gradient-bar`, `bg-glow-red`,
  `max-w-shell`, `ease-standard`).
- Splash page rewritten to use Tailwind utilities for layout, spacing,
  typography, and color, with custom CSS reduced to a single
  `prefers-reduced-motion` block scoped to `.splash`. `LogoCombo.astro`
  is now self-contained Tailwind utilities; `.logo-combo` removed from
  `shell.css`.

### 404 page
- Added `src/pages/404.astro` — same chrome / hero shape as the splash so
  unmatched routes land somewhere on-brand instead of CF's default error
  page. SSR (`prerender = false`) so the punchline rotates per request
  through a curated list of pithy nerd jokes ("Wrong room.", "Stack trace
  ends here.", "Null pointer.", "Schrödinger's path.", "No such file or
  directory.", etc.) — body copy adapts to match each punchline. Status
  set explicitly to 404. Single CTA back to `/`, secondary mailto
  reference to `hello@infiniteroomlabs.com`.
- 404 response carries `Cache-Control: public, max-age=300, s-maxage=300`
  so Cloudflare's edge cache absorbs repeat hits on the same path. Worker
  cost stays bounded under scanner storms; punchline rotation still works
  for fresh URLs (each unique path cached independently).

### Custom domains
- `wrangler.jsonc` now attaches `infiniteroomlabs.com` and
  `www.infiniteroomlabs.com` as Worker Custom Domains via the `routes`
  array. `wrangler deploy` provisions the DNS records and TLS certs.
- Pre-deploy DNS cleanup (manual, Cloudflare dashboard): removed the
  Porkbun-era A records at apex, the `www` CNAME to Porkbun parking,
  and the wildcard `*` CNAME to Porkbun parking. SendGrid, MX
  (Cloudflare Email Routing), DKIM/SPF/DMARC, and ACME challenge
  records preserved.
- Follow-up: add a Redirect Rule in the Cloudflare dashboard to send
  `www.infiniteroomlabs.com/*` to `https://infiniteroomlabs.com/$1`
  (301 permanent) so apex is the SEO canonical.

### Splash rollout — pre-launch (D-1..D-6)
- Public mailto + meta description + JSON-LD `contactPoint.email` + OG card
  caption swapped from `wes@infiniteroomlabs.com` to
  `hello@infiniteroomlabs.com`. Wes adds the matching Cloudflare Email
  Routing rule (forward to personal Gmail) before the splash goes public.
- Removed "Soft launch" suffix from the nav meta strip; reads "LEX, KY · ET".
- Reworked hero copy: dropped the "Paid discovery / written milestones / full
  IP transfer on completion" triplet (recurring AI-pattern phrasing) in favor
  of "I scope before I build. You own everything when it's done." — same
  meaning, different voice, doesn't pattern-match across pages.
- Same anti-pattern-match pass applied to the meta description and the
  JSON-LD `description` field.
- Added `scripts/build-og.sh` to regenerate `/public/og-default.png` from
  `/public/og-default.svg` via Inkscape (auto-bootstraps Bebas Neue + IBM
  Plex Sans into ~/.fonts on a fresh machine). Wired into `npm run build`
  as a `prebuild` hook so the OG card stays in sync with the SVG source.
  When neither Inkscape nor rsvg-convert is installed (e.g. Cloudflare
  Pages build environment), the script logs a skip message and exits 0,
  letting CI rely on the committed PNG.
- Added `docs/plans/2026-05-03-splash-deployment.md` capturing the
  pre-rollout decisions log, manual Cloudflare dashboard checklist, and
  follow-up TODOs (move email forwarders into IaC, designer-quality OG card,
  reintroduce social profile links, DMARC tightening).

### Splash rollout (post-review)
Post-review pass against feedback from the content, marketing, and SEO
specialists before public soft launch:
- **Title tag** changed to `Solo Technical Consultancy — Lexington, KY |
  Infinite Room Labs` (keyword + location lead, brand anchor at the end).
- **Meta description** rewritten: leads with what IRL does, names the
  practice areas, surfaces the engagement model and the contact email.
- **og:image** now points at `/public/og-default.png` (1200×630 brand
  card, generated from `/public/og-default.svg` via Inkscape). Previous
  `favicon.svg` would have rendered no card on LinkedIn / Twitter / iMessage.
- **JSON-LD** upgraded:
  `@type` → `['LocalBusiness', 'ProfessionalService']`,
  `@id` anchor added,
  `legalName` set,
  `areaServed` corrected from invalid `{type: 'State'}` to `'Worldwide'`,
  `priceRange`, `contactPoint`, and `knowsAbout` array added.
  `sameAs` (LinkedIn, GitHub) deferred until profiles are cleaned up.
- **Splash copy** — dropped the "full site is shipping soon" opener
  (front-loaded apology); "Email is the front door" → "Start with an
  email."; "you own everything at the end" → "full IP transfer on
  completion" until SOW boilerplate locks the wording.
- **Mailto** carries `?subject=Inquiry%20%5BIRL-splash%5D` so inbound
  source attribution works without analytics scripts.
- **Indexing posture**: index-now (no noindex). Domain aging + crawl
  equity outweigh thin-content risk on a single well-structured page.
- **Operational follow-ups (not code)**: enable Cloudflare Web Analytics
  in the Pages project; set calendar reminders to fast-track full site
  ahead of the Q3 2026 stamp; clean up LinkedIn + GitHub presence
  before re-introducing them as `sameAs` and as visible links.

### Notes
- The full multi-page site (services, how-i-work, pricing, faq, ecosystem,
  about, contact) lives on `feature/full-site` and will replace the splash
  page on main when content is ready.
