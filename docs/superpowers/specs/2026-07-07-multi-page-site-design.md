# Multi-page site design — 2026-07-07

Expand irl-website from the single splash page to a five-route site: splash home, About, Projects gallery, per-project detail pages, and Contact. The splash stays lean; new pages carry the depth. Positioning follows the DevOps/platform identity established in the 2026-07-07 hero repositioning commit (97fc24f).

## Goals

- Showcase systems thinking through four concrete projects without re-crowding the home page.
- Give buyers and hiring managers a verifiable human behind the LLC (full name, GitHub, LinkedIn).
- Keep every word of public copy compliant with the public-copy-guard rules, including the claim-window constraints.

## Routes

| Route | Source | Content |
|---|---|---|
| `/` | existing `src/pages/index.astro` | Unchanged hero. Header gains nav links: About, Projects, Contact. |
| `/about` | new `src/pages/about.astro` | Three sections gleaned from `feature/full-site`: `/01 Origin`, `/02 The operation`, `/03 How I work`, plus one pull-quote block. Full name "Wes Gilleland" with GitHub and LinkedIn links. |
| `/projects` | new `src/pages/projects/index.astro` | Card gallery rendered from the `projects` collection, ordered by `order`. |
| `/projects/[slug]` | new `src/pages/projects/[slug].astro` | Frontmatter-driven header (title, tagline, role, tech, optional repo link) + rendered MDX body. |
| `/contact` | new `src/pages/contact.astro` | Email CTA (existing mailto pattern), a "what to include in your email" section, and async-first expectations copy. No form. |

## Content model

New `projects` collection in `src/content.config.ts`, following the existing glob-loader pattern:

```ts
const projects = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/projects' }),
  schema: z.object({
    title: z.string(),
    tagline: z.string(),      // one-line hook shown on the card
    summary: z.string(),      // 2-3 sentence card body
    role: z.string(),         // e.g. "Author", "Fork maintainer"
    tech: z.array(z.string()).default([]),
    repoUrl: z.string().url().optional(),
    order: z.number().default(0),
  }),
});
```

Launch entries (one `.mdx` each under `src/content/projects/`):

1. **claudesync** — TypeScript SDK/CLI/MCP monorepo. Theme: building tools for the tools. Has `repoUrl`.
2. **agent-ops** — Claude Code plugin marketplace with gated workflows. Theme: systems that make agents behave. Has `repoUrl`.
3. **homelab-platform** — k3s, Helm-via-Ansible, Vault, CNPG Postgres, Prometheus/Grafana/Loki, Bitwarden-to-Vault-to-Kubernetes secrets pipeline. Theme: running what I sell. Case study prose only, no repo link.
4. **featmap-fork** — MCP server and API-key auth added to an upstream open-source app. Theme: extending systems I did not write. Has `repoUrl` if the fork is public; otherwise case-study prose.

## Components and layout

- New pages use the existing `BaseLayout.astro` (nav and footer are already prop-driven). Nav links and footer sitemap links live in one shared constant (`src/nav.ts`) imported by the splash header and every BaseLayout page, so the link list cannot drift between layouts.
- The splash keeps `SplashLayout.astro`; its header gains the three nav links inline.
- Two components rebuilt from `feature/full-site` patterns as Tailwind-utility components matching main's idiom (the branch's `pages.css` is not ported — one styling system only):
  - `PageHead.astro` — eyebrow, display title, sub-paragraph, glow background.
  - `CTABlock.astro` — closing email CTA used on About, Projects, Contact.
- New `ProjectCard.astro` — gallery card: title, tagline, summary, tech list, link to detail page.

## Copy pipeline (applies to every page)

1. Draft copy.
2. Run through the `human-voice` skill; iterate until the AI-slop score is as low as achievable.
3. Scan with `public_copy_scan.py` (self-employment repo); must exit clean.
4. Claim-window voice rules: undated case-study framing, no availability or open-to-work language, no "currently building," no sustained-productivity claims.
5. Guard-specific rewrites for About: the origin section drops the role-ended/runway/non-solicitation material from the old branch entirely.

## SEO

Each page sets `title` and `description` via BaseLayout props. Sitemap coverage is automatic via `@astrojs/sitemap`. No per-page OG images at launch.

## Error handling

Unknown `/projects/*` slugs fall through to the existing 404 (`getStaticPaths` covers only collection entries). Bad frontmatter fails the build by design (Zod schema), so a malformed project file cannot ship silently.

## Verification

- `pnpm run build` clean.
- Guard scan clean on all new copy.
- Browser pass at 1440px and 390px across all five routes: nav works, cards link, detail pages render, no contrast regressions (fg tokens already AA after 97fc24f).

## Out of scope

Contact form (revisit if email volume justifies it), blog/posts collection usage, services/pricing/faq/how-i-work/ecosystem pages from the old branch, per-page OG images, analytics.
