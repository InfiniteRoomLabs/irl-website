# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Marketing site for Infinite Room Labs (Georgetown, KY). Astro 6 + Tailwind v4 + MDX, deployed to Cloudflare via `@astrojs/cloudflare` adapter. Production domain is `https://infiniteroomlabs.com`.

## Commands

| Command                  | Purpose                                                                                               |
|--------------------------|-------------------------------------------------------------------------------------------------------|
| `npm run dev`            | Astro dev server on http://localhost:4321                                                             |
| `npm run build`          | Production build to `./dist`                                                                          |
| `npm run preview`        | Serve `./dist` locally to verify build                                                                |
| `npm run astro <cmd>`    | Pass-through to Astro CLI (e.g. `npm run astro check`, `npm run astro add`)                           |
| `npm run generate-types` | Run `wrangler types` — regenerate `worker-configuration.d.ts` after editing `wrangler.jsonc` bindings |

Node `>=22.12.0`. No test runner, linter, or formatter is wired up yet — Prettier + ESLint exist only as devcontainer VS Code extensions.

## Architecture

### Rendering target: Cloudflare Workers (not Pages)
`astro.config.mjs` uses `@astrojs/cloudflare`, and `wrangler.jsonc` declares `main: "@astrojs/cloudflare/entrypoints/server"` with `./dist` mounted as the `ASSETS` binding. Build output is a Worker, not a static Pages bundle. The README's "Cloudflare Pages" deploy note is stale — deploy via Wrangler. `compatibility_flags: ["global_fetch_strictly_public"]` blocks server-side fetches to private/internal addresses.

### Content collections drive the site
`src/content.config.ts` defines four Zod-validated collections loaded via `glob` from `src/content/`:

- `services` — `{ title, summary, order, priceRange?, serviceType? }`
- `posts` — `{ title, description, pubDate, updatedDate?, tags[], draft }`
- `caseStudies` — `{ title, client, summary, problem, solution, outcome, techStack[], pubDate }`
- `faqs` — `{ question, category?, order }`

All collections accept `.md` and `.mdx`. Collection dirs currently exist but are empty — adding a file with bad frontmatter will fail the build, so match the schema exactly.

### SEO is component-driven
`src/components/seo/` holds JSON-LD blocks as Astro components, typed via `schema-dts` (`WithContext<Organization>` etc.). New schema types follow the same pattern: typed object → `set:html={JSON.stringify(schema)}` inside `<script type="application/ld+json">`. `astro-seo` and `@astrojs/sitemap` are installed for `<head>` meta and sitemap generation; `site:` in `astro.config.mjs` must stay accurate for sitemap URLs.

### Styling
Tailwind v4 via `@tailwindcss/vite` (no `tailwind.config.js` — config lives in CSS). Brand tokens are CSS custom properties in `src/styles/global.css`: `--font-display` (Bebas Neue), `--font-body` (Inter Variable), and the navy/red/blue "Fortress palette". Self-hosted fonts via `@fontsource` — no Google Fonts network calls.

### TypeScript
Extends `astro/tsconfigs/strict`. Includes `.astro/types.d.ts` (collection types) and `worker-configuration.d.ts` (Cloudflare bindings) — both are generated, do not edit by hand. Run `npm run generate-types` after binding changes.

## Conventions Specific to This Repo

- `src/layouts/` exists by convention only — no Astro magic. Page shells go here when added.
- `src/assets/` is for images that should pass through Astro's build-time optimizer; `public/` is for verbatim static files (favicon, robots.txt).
- The devcontainer mounts `node_modules` as a named volume (`irl-website-node-modules`) — host `node_modules` and container `node_modules` are intentionally separate.
- Fish is the default shell in the devcontainer.

## Parent-repo Conventions That Apply Here

See `~/projects/infinite-room-labs/CLAUDE.md` for org-wide rules. Most relevant:
- **UTF-8 only** in content files — no smart quotes, em/en dashes, or Office characters.
- **Mermaid for diagrams**, never ASCII art.
