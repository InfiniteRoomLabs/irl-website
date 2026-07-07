# Multi-Page Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand irl-website from the single splash page to five routes: `/`, `/about`, `/projects`, `/projects/[slug]`, `/contact`, driven by a new `projects` content collection.

**Architecture:** New pages use the existing `BaseLayout.astro` (prop-driven Nav/Footer). A shared `NAV_LINKS` constant feeds both the splash header (which swaps its hand-rolled header for the existing `Nav` component) and BaseLayout pages. Projects live in a Zod-validated MDX collection; the gallery and detail route render from it. Two presentation components (`PageHead`, `CTABlock`) are rebuilt from `feature/full-site` patterns using Tailwind utilities to match main's idiom.

**Tech Stack:** Astro 6, Tailwind v4 (`@theme` tokens), MDX, Cloudflare adapter (static prerender by default), pnpm.

## Global Constraints

- **Branch:** all work on `feature/multi-page`. Do not commit to `main` (changelog-guard hook blocks it anyway).
- **Package manager:** pnpm only (`pnpm run build`, `pnpm run dev`). Never npm/npx.
- **Copy pipeline (every page and every content file):** (1) draft, (2) run the `human-voice` skill on the copy and iterate until its score is as low as achievable, (3) scan with `cd ~/projects/infinite-room-labs/self-employment && echo "<copy>" | uv run --no-project python scripts/public_copy_scan.py -` — must print `clean`, (4) claim-window voice: undated case-study framing, no availability/open-to-work language, no "currently building", no response-time SLAs, no sustained-productivity claims.
- **Copy in this plan is draft copy.** The human-voice + guard steps may reword it. Structure and facts must survive; phrasing may change.
- **UTF-8/ASCII rule:** no smart quotes or em dashes in source files. The `·`, `→`, `↗` glyphs already used by the site are allowed.
- **Styling:** Tailwind utility classes with the Fortress tokens (`bg-surface`, `text-fg-2`, `font-display`, `tracking-eyebrow`, `bg-gradient-bar`, `bg-glow-red`, `max-w-shell`, `border-rule`). Do not port `pages.css` from `feature/full-site`.
- **No test runner exists.** Verification is `pnpm run build` (Zod validates frontmatter, routes must compile) plus grep checks on `dist/` output and a browser pass in the final task.
- **Contact info:** `hello@infiniteroomlabs.com`. Name: Wes Gilleland. GitHub: `https://github.com/Deathnerd`. LinkedIn: `https://www.linkedin.com/in/george-gilleland-71793bb0`.

---

### Task 1: Shared nav constant + splash header swap

**Files:**
- Create: `src/nav.ts`
- Modify: `src/pages/index.astro` (header block, lines ~8-18)

**Interfaces:**
- Produces: `NAV_LINKS: { href: string; label: string }[]` exported from `src/nav.ts`. Every later page task imports it.

- [ ] **Step 1: Create `src/nav.ts`**

```ts
export interface NavLink {
  href: string;
  label: string;
}

export const NAV_LINKS: NavLink[] = [
  { href: '/about', label: 'About' },
  { href: '/projects', label: 'Projects' },
  { href: '/contact', label: 'Contact' },
];
```

- [ ] **Step 2: Swap the splash's hand-rolled header for the `Nav` component**

In `src/pages/index.astro`, replace the entire `<header class="bg-surface border-b border-rule shrink-0">...</header>` block with:

```astro
<Nav links={NAV_LINKS} />
```

and update the frontmatter imports:

```astro
---
import SplashLayout from '../layouts/SplashLayout.astro';
import Nav from '../components/Nav.astro';
import { NAV_LINKS } from '../nav';
---
```

Remove the now-unused `LogoCombo` import. (`Nav` renders its own brand lockup via `ThresholdMark` and handles active states and the mobile menu toggle; its `s-nav` styles come from `shell.css`, already loaded through `global.css`.)

- [ ] **Step 3: Build and verify**

Run: `pnpm run build`
Expected: completes without errors.

Run: `grep -c 'href="/about"' dist/client/index.html`
Expected: `1` or more (nav link present in prerendered splash).

- [ ] **Step 4: Commit**

```bash
git add src/nav.ts src/pages/index.astro
git commit -m "feat(nav): shared NAV_LINKS constant, splash header uses Nav component"
```

---

### Task 2: PageHead and CTABlock components

**Files:**
- Create: `src/components/PageHead.astro`
- Create: `src/components/CTABlock.astro`

**Interfaces:**
- Produces: `PageHead` props `{ eyebrow: string; title: string; sub?: string }` (title/sub accept inline HTML via `set:html`). `CTABlock` props `{ eyebrow?: string; title: string }` with a slot for body copy. All page tasks consume both.

- [ ] **Step 1: Create `src/components/PageHead.astro`**

```astro
---
interface Props {
  eyebrow: string;
  title: string;
  sub?: string;
}
const { eyebrow, title, sub } = Astro.props;
---
<section class="relative px-12 pt-20 pb-12 overflow-hidden max-md:px-5 max-md:pt-10 max-md:pb-8">
  <div class="absolute inset-0 pointer-events-none bg-glow-red"></div>
  <div class="relative max-w-shell mx-auto w-full">
    <div class="font-mono text-[11px] tracking-widest-2 text-fg-2 uppercase flex gap-4 items-center max-md:text-[10px]">
      <span class="block w-8 h-px bg-accent max-md:hidden" aria-hidden="true"></span>
      <span>{eyebrow}</span>
    </div>
    <h1
      class="font-display font-normal text-fg-1 mt-6 leading-[0.9] tracking-[0.02em] uppercase text-balance text-[clamp(48px,7vw,96px)]"
      set:html={title}
    />
    {sub && (
      <p
        class="mt-6 font-sans font-extralight text-[clamp(16px,1.3vw,20px)] leading-[1.5] text-fg-2 max-w-[62ch]"
        set:html={sub}
      />
    )}
    <div class="h-[3px] bg-gradient-bar mt-8 w-full"></div>
  </div>
</section>
```

- [ ] **Step 2: Create `src/components/CTABlock.astro`**

```astro
---
interface Props {
  eyebrow?: string;
  title: string;
}
const { eyebrow = 'Next step', title } = Astro.props;
---
<section class="px-12 py-16 max-md:px-5 max-md:py-10">
  <div class="max-w-shell mx-auto w-full border-t border-rule pt-10">
    <div class="font-mono text-[11px] tracking-widest-2 text-fg-2 uppercase">{eyebrow}</div>
    <h2
      class="font-display font-normal text-fg-1 uppercase mt-4 leading-[0.95] tracking-[0.02em] text-[clamp(36px,5vw,64px)]"
      set:html={title}
    />
    <p class="mt-5 font-sans font-extralight text-[clamp(16px,1.3vw,20px)] leading-[1.5] text-fg-2 max-w-[56ch] m-0">
      <slot />
    </p>
    <a
      href="mailto:hello@infiniteroomlabs.com?subject=Inquiry%20%5BIRL%5D"
      class="mt-7 inline-flex items-center gap-3.5 bg-accent hover:bg-accent-hover text-fg-1 font-sans font-semibold text-sm tracking-[0.04em] uppercase px-6 py-[18px] no-underline transition-colors duration-100 ease-standard"
    >
      hello@infiniteroomlabs.com
      <span aria-hidden="true">→</span>
    </a>
  </div>
</section>
```

- [ ] **Step 3: Build to verify the components compile**

Run: `pnpm run build`
Expected: completes without errors (components are not yet referenced; this catches syntax errors only).

- [ ] **Step 4: Commit**

```bash
git add src/components/PageHead.astro src/components/CTABlock.astro
git commit -m "feat(components): PageHead and CTABlock in Tailwind idiom"
```

---

### Task 3: Projects collection + four content entries

**Files:**
- Modify: `src/content.config.ts`
- Create: `src/content/projects/claudesync.mdx`
- Create: `src/content/projects/agent-ops.mdx`
- Create: `src/content/projects/homelab-platform.mdx`
- Create: `src/content/projects/featmap-fork.mdx`

**Interfaces:**
- Produces: `projects` collection; entry `id` equals the filename without extension (glob loader), used by Task 5's route params. Frontmatter shape: `{ title, tagline, summary, role, tech[], repoUrl?, order }`.

- [ ] **Step 1: Add the collection to `src/content.config.ts`**

Add after the `faqs` definition and register in the export:

```ts
const projects = defineCollection({
    loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/projects' }),
    schema: z.object({
        title: z.string(),
        tagline: z.string(),
        summary: z.string(),
        role: z.string(),
        tech: z.array(z.string()).default([]),
        repoUrl: z.string().url().optional(),
        order: z.number().default(0),
    }),
});

export const collections = { services, posts, caseStudies, faqs, projects };
```

(Replace the existing `export const collections` line.)

- [ ] **Step 2: Confirm public repo URLs**

Run: `gh repo view Deathnerd/claudesync --json url -q .url; gh repo view InfiniteRoomLabs/agent-ops --json url -q .url`

Use whichever URLs resolve as `repoUrl` in the matching entries below. If a repo 404s or is private, omit `repoUrl` from that entry entirely (the schema makes it optional; the detail page hides the source link).

- [ ] **Step 3: Create `src/content/projects/claudesync.mdx`**

```mdx
---
title: claudesync
tagline: A typed bridge to an API that does not officially exist
summary: claude.ai has no public API for its web conversations, projects, or artifacts. claudesync maps that unofficial surface into a typed TypeScript SDK, a CLI, and an MCP server, so the same contract serves humans and agents.
role: Author
tech: [TypeScript, MCP, Docker, monorepo]
repoUrl: https://github.com/Deathnerd/claudesync
order: 1
---

## The problem

Everything you write in claude.ai — conversations, projects, artifacts — lives behind a web app with no official API. If you want your own data in your own workflows, you get a browser tab and a copy button.

## The system

claudesync treats the unofficial API as a contract worth engineering against: mapped, typed, and wrapped once, then consumed three ways.

- **SDK** — a typed TypeScript client that owns authentication (session cookie handling) and the request surface. Every consumer goes through it; nothing talks to the raw API twice.
- **CLI** — list organizations, projects, and conversations; pull content and artifacts to disk.
- **MCP server** — the same operations exposed to AI agents, so an agent can search and read claude.ai history as a first-class tool.

One API layer, three consumers, packaged with Docker so setup is a single command.

## Why it matters

Undocumented systems are still systems. The job was making an unknown surface knowable — reverse-engineering the endpoints, encoding them as types so drift shows up at compile time, and building the tooling other workflows can depend on.
```

- [ ] **Step 4: Create `src/content/projects/agent-ops.mdx`**

```mdx
---
title: agent-ops
tagline: A plugin marketplace that makes AI agents follow process
summary: A Claude Code plugin marketplace organizing agents, skills, commands, and hooks by business domain, with a registry index and gated workflows. Process encoded as enforceable structure, not tribal knowledge.
role: Author
tech: [Claude Code, plugins, YAML registry, hooks]
repoUrl: https://github.com/InfiniteRoomLabs/agent-ops
order: 2
---

## The problem

Agentic coding fails the same way undisciplined teams fail: skipped review, drive-by commits, conventions that exist only in someone's head. Prompting an agent to "follow best practices" is hope, not engineering.

## The system

agent-ops is a private Claude Code marketplace: plugins organized by business domain (core, engineering, operations, research, finance), each contributing agents, skills, commands, and hooks.

- **Registry as index** — a single `registry.yaml` catalogs every active component with tags, so both humans and agents can discover what exists and what it is for.
- **Hooks as guardrails** — pre-tool-use hooks block the failure modes outright: commits to protected branches without changelog entries, staged-plus-commit in one step, denylisted public copy. The agent does not get asked to behave; the system refuses the misbehavior.
- **Gated workflows** — multi-step processes (spec, plan, implement, review) where each gate must pass before the next opens.

## Why it matters

The interesting problem in agentic engineering is not making agents capable — it is making them *governable*. This is the difference between using AI and operating it.
```

- [ ] **Step 5: Create `src/content/projects/homelab-platform.mdx`**

```mdx
---
title: Homelab platform
tagline: Running what I sell, with production habits
summary: A Kubernetes platform run like a client environment. Helm deploys driven by Ansible, secrets synced from a single source of truth into Vault and Kubernetes, and three-pillar observability. A case study in operating discipline at lab scale.
role: Operator
tech: [Kubernetes, Helm, Ansible, Vault, PostgreSQL, Prometheus, Grafana, Loki, Terraform]
order: 3
---

## The problem

Consultants routinely recommend infrastructure they have never operated. I wanted every recommendation I make backed by the experience of running it: the upgrade that breaks, the secret that rotates, the alert that fires at the wrong time.

## The system

A k3s Kubernetes cluster running a real service fleet — source control, identity, databases, monitoring, storage — with the same rules a client environment would get:

- **No drift** — every service deploys through Helm charts driven by Ansible playbooks. There is no `kubectl apply` from a laptop; the repo is the environment.
- **One source of truth for secrets** — a password manager feeds a sync pipeline that renders secrets into both Ansible Vault and Kubernetes Secrets, with rotation-policy checks on a schedule. Nothing is pasted, nothing lives in two places.
- **Operated PostgreSQL** — CloudNativePG for real database lifecycle: replicas, backups, upgrades as code.
- **Three pillars** — Prometheus metrics, Loki logs, Grafana dashboards and alerting, watching the golden signals.
- **Split-horizon DNS** — internal services resolve through an internal DNS zone generated from the same service inventory that drives deployment.

## Why it matters

None of this is exotic. That is the point: the discipline is the product. It is a lab, run with production habits — and knowing the difference between a lab and production is exactly what you hire for.
```

- [ ] **Step 6: Create `src/content/projects/featmap-fork.mdx`**

```mdx
---
title: featmap fork
tagline: Teaching someone else's app to speak agent
summary: An upstream open-source story-mapping tool, extended with an MCP server and API-key authentication so AI agents can operate story maps first-class. A study in extending a codebase in its own idiom.
role: Fork maintainer
tech: [Go, React, MCP, SQL]
order: 4
---

## The problem

Story mapping is a thinking tool, and agents are increasingly part of the thinking. The upstream app is a solid Go + React story-mapping tool with no API surface an agent could use — browser-only, session-authenticated.

## The system

The fork adds an agent-grade surface without disturbing the product underneath:

- **MCP server** — story maps, workflows, features, milestones, and personas exposed as tools, including the bulk operations agents actually need (create fifty features in one call, not fifty calls).
- **API-key auth** — account-scoped keys, hashed at rest, presented as bearer tokens. Workspace selection is a per-call argument, so one key serves any workspace the account can reach.
- **Upstream-friendly** — the additions follow the existing codebase's structure and conventions, so the fork stays rebaseable instead of becoming a hostile divergence.

## Why it matters

Most engineering is not greenfield. Reading an unfamiliar codebase, finding its idiom, and extending it without breaking its assumptions is the daily job — this is that job, in public.
```

- [ ] **Step 7: Copy pipeline on all four entries**

Run the `human-voice` skill over each `.mdx` body; iterate until the score is as low as achievable. Then scan each file:

Run: `cd ~/projects/infinite-room-labs/self-employment && for f in ~/projects/infinite-room-labs/irl-website/src/content/projects/*.mdx; do uv run --no-project python scripts/public_copy_scan.py "$f"; done`
Expected: `clean` four times. Rephrase and re-scan any hit.

- [ ] **Step 8: Build to validate schemas**

Run: `pnpm run build`
Expected: completes without errors (Zod rejects malformed frontmatter at build time; a failure here means a frontmatter typo).

- [ ] **Step 9: Commit**

```bash
git add src/content.config.ts src/content/projects/
git commit -m "feat(content): projects collection with four launch entries"
```

---

### Task 4: ProjectCard + gallery page

**Files:**
- Create: `src/components/ProjectCard.astro`
- Create: `src/pages/projects/index.astro`

**Interfaces:**
- Consumes: `NAV_LINKS` (Task 1), `PageHead`/`CTABlock` (Task 2), `projects` collection (Task 3).
- Produces: `ProjectCard` props `{ project: CollectionEntry<'projects'> }`; card links to `/projects/${project.id}/` — Task 5 must serve that route shape.

- [ ] **Step 1: Create `src/components/ProjectCard.astro`**

```astro
---
import type { CollectionEntry } from 'astro:content';

interface Props {
  project: CollectionEntry<'projects'>;
}
const { project } = Astro.props;
const { title, tagline, summary, tech } = project.data;
---
<a
  href={`/projects/${project.id}/`}
  class="flex flex-col border border-rule bg-surface-elevated p-8 no-underline hover:border-rule-strong transition-colors duration-100 ease-standard max-md:p-5"
>
  <h3 class="font-display font-normal text-[28px] tracking-[0.06em] uppercase text-fg-1 m-0">{title}</h3>
  <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2 mt-2">{tagline}</div>
  <p class="font-sans font-extralight text-[16px] leading-[1.5] text-fg-2 mt-4 mb-0 flex-1">{summary}</p>
  <div class="font-mono text-[10px] tracking-wider-2 uppercase text-fg-muted mt-6">{tech.join(' · ')}</div>
</a>
```

- [ ] **Step 2: Create `src/pages/projects/index.astro`**

```astro
---
import { getCollection } from 'astro:content';
import BaseLayout from '../../layouts/BaseLayout.astro';
import PageHead from '../../components/PageHead.astro';
import ProjectCard from '../../components/ProjectCard.astro';
import CTABlock from '../../components/CTABlock.astro';
import { NAV_LINKS } from '../../nav';

const projects = (await getCollection('projects')).sort(
  (a, b) => a.data.order - b.data.order,
);
---
<BaseLayout
  title="Projects — Infinite Room Labs"
  description="Four builds that show the systems thinking behind Infinite Room Labs: agent tooling, a governed plugin marketplace, an operated Kubernetes platform, and an upstream fork done right."
  navLinks={NAV_LINKS}
  footerSitemapLinks={NAV_LINKS}
  sourcePath="src/pages/projects/index.astro"
>
  <main id="main">
    <PageHead
      eyebrow="Projects"
      title="Systems,<br />not snippets."
      sub="Each of these exists because a system was missing. Together they show how I work: map the unknown, encode the process, run the result."
    />
    <section class="px-12 py-10 max-md:px-5 max-md:py-6">
      <div class="max-w-shell mx-auto grid grid-cols-2 gap-6 max-md:grid-cols-1">
        {projects.map((project) => <ProjectCard project={project} />)}
      </div>
    </section>
    <CTABlock title="Want this kind of<br />thinking on your stack?">
      Describe the system that hurts. I will reply in writing.
    </CTABlock>
  </main>
</BaseLayout>
```

- [ ] **Step 3: Copy pipeline on the page copy**

Run the `human-voice` skill over the PageHead sub, description, and CTA copy; iterate. Then:

Run: `cd ~/projects/infinite-room-labs/self-employment && echo "Each of these exists because a system was missing. Together they show how I work: map the unknown, encode the process, run the result. Describe the system that hurts. I will reply in writing." | uv run --no-project python scripts/public_copy_scan.py -`
Expected: `clean` (re-scan with the final wording if human-voice changed it).

- [ ] **Step 4: Build and verify**

Run: `pnpm run build`
Expected: success.

Run: `grep -o 'href="/projects/[a-z-]*/"' dist/client/projects/index.html | sort -u`
Expected: four hrefs — `agent-ops`, `claudesync`, `featmap-fork`, `homelab-platform`.

- [ ] **Step 5: Commit**

```bash
git add src/components/ProjectCard.astro src/pages/projects/index.astro
git commit -m "feat(projects): gallery page rendering the projects collection"
```

---

### Task 5: Project detail route

**Files:**
- Create: `src/pages/projects/[slug].astro`
- Create: `src/styles/prose.css`

**Interfaces:**
- Consumes: `projects` collection ids as `params.slug` (Task 3), `NAV_LINKS`, `PageHead`, `CTABlock`.
- Produces: routes `/projects/claudesync/`, `/projects/agent-ops/`, `/projects/homelab-platform/`, `/projects/featmap-fork/`.

- [ ] **Step 1: Create `src/styles/prose.css`**

```css
/* Typography for MDX-rendered project bodies. Scoped by .prose-irl. */
.prose-irl {
  font-family: var(--font-sans);
  font-weight: 200;
  font-size: 17px;
  line-height: 1.6;
  color: var(--fg2);
}
.prose-irl h2 {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: clamp(26px, 3vw, 36px);
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--fg1);
  margin: 2.2em 0 0.6em;
}
.prose-irl h2:first-child {
  margin-top: 0;
}
.prose-irl strong {
  color: var(--fg1);
  font-weight: 500;
}
.prose-irl a {
  color: var(--accent-2-hover);
}
.prose-irl ul {
  padding-left: 1.2em;
}
.prose-irl li {
  margin: 0.5em 0;
}
.prose-irl li::marker {
  color: var(--accent);
}
.prose-irl code {
  font-family: var(--font-mono);
  font-size: 0.9em;
  color: var(--fg1);
}
```

- [ ] **Step 2: Create `src/pages/projects/[slug].astro`**

```astro
---
import { getCollection, render } from 'astro:content';
import BaseLayout from '../../layouts/BaseLayout.astro';
import PageHead from '../../components/PageHead.astro';
import CTABlock from '../../components/CTABlock.astro';
import { NAV_LINKS } from '../../nav';
import '../../styles/prose.css';

export async function getStaticPaths() {
  const projects = await getCollection('projects');
  return projects.map((project) => ({
    params: { slug: project.id },
    props: { project },
  }));
}

const { project } = Astro.props;
const { Content } = await render(project);
const d = project.data;
---
<BaseLayout
  title={`${d.title} — Projects — Infinite Room Labs`}
  description={d.summary}
  navLinks={NAV_LINKS}
  footerSitemapLinks={NAV_LINKS}
  sourcePath={`src/content/projects/${project.id}.mdx`}
>
  <main id="main">
    <PageHead eyebrow={`Projects · ${d.role}`} title={d.title} sub={d.tagline} />
    <section class="px-12 py-10 max-md:px-5 max-md:py-6">
      <div class="max-w-shell mx-auto grid grid-cols-[minmax(0,1fr)_260px] gap-14 max-md:grid-cols-1 max-md:gap-8">
        <article class="prose-irl">
          <Content />
        </article>
        <aside class="font-mono text-[11px] tracking-eyebrow uppercase text-fg-muted flex flex-col gap-5 max-md:border-t max-md:border-rule max-md:pt-6">
          <div>
            <b class="text-fg-2 font-medium block mb-1">Role</b>
            {d.role}
          </div>
          <div>
            <b class="text-fg-2 font-medium block mb-1">Tech</b>
            {d.tech.join(' · ')}
          </div>
          {d.repoUrl && (
            <a class="text-accent-2-hover no-underline hover:text-fg-1" href={d.repoUrl}>
              Source ↗
            </a>
          )}
          <a class="text-fg-2 no-underline hover:text-fg-1" href="/projects/">← All projects</a>
        </aside>
      </div>
    </section>
    <CTABlock title="Need this kind<br />of system?">
      If any of this maps to a problem you have, describe it in an email.
    </CTABlock>
  </main>
</BaseLayout>
```

- [ ] **Step 3: Build and verify all four routes render**

Run: `pnpm run build`
Expected: success.

Run: `ls dist/client/projects/`
Expected: directories `agent-ops`, `claudesync`, `featmap-fork`, `homelab-platform` (plus `index.html`).

Run: `grep -c 'prose-irl' dist/client/projects/claudesync/index.html`
Expected: `1` or more.

- [ ] **Step 4: Commit**

```bash
git add "src/pages/projects/[slug].astro" src/styles/prose.css
git commit -m "feat(projects): per-project detail route with MDX prose styles"
```

---

### Task 6: About page

**Files:**
- Create: `src/pages/about.astro`

**Interfaces:**
- Consumes: `NAV_LINKS`, `PageHead`, `CTABlock`.

- [ ] **Step 1: Create `src/pages/about.astro`**

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
import PageHead from '../components/PageHead.astro';
import CTABlock from '../components/CTABlock.astro';
import { NAV_LINKS } from '../nav';
import '../styles/prose.css';
---
<BaseLayout
  title="About — Infinite Room Labs"
  description="Infinite Room Labs is a Kentucky LLC run by Wes Gilleland: DevOps and platform engineering with full-lifecycle depth, operated like a real engineering organization."
  navLinks={NAV_LINKS}
  footerSitemapLinks={NAV_LINKS}
  sourcePath="src/pages/about.astro"
>
  <main id="main">
    <PageHead
      eyebrow="About"
      title="One person.<br />A real engineering<br />operation."
      sub="Infinite Room Labs is a Kentucky LLC operated entirely by <strong>Wes Gilleland</strong>. This page is how it works."
    />

    <div class="max-w-shell mx-auto px-12 max-md:px-5">

      <section class="grid grid-cols-[280px_minmax(0,1fr)] gap-14 py-12 border-b border-rule max-md:grid-cols-1 max-md:gap-5 max-md:py-8">
        <div>
          <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2">/01 — Origin</div>
          <h2 class="font-display font-normal text-fg-1 uppercase mt-3 leading-[0.95] text-[clamp(30px,3.5vw,44px)]">How this<br />started.</h2>
        </div>
        <div class="prose-irl">
          <p>I came up through the full software lifecycle: development, QA automation, and operations, at enterprise software companies and a web agency. The pattern was the same everywhere. I could not leave a brittle system alone. Manual deploys became pipelines. Snowflake servers became Terraform. "Works on my machine" became a containerized dev environment anyone could boot with one command.</p>
          <p><strong>Infinite Room Labs is that pattern, incorporated.</strong></p>
        </div>
      </section>

      <section class="grid grid-cols-[280px_minmax(0,1fr)] gap-14 py-12 border-b border-rule max-md:grid-cols-1 max-md:gap-5 max-md:py-8">
        <div>
          <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2">/02 — The operation</div>
          <h2 class="font-display font-normal text-fg-1 uppercase mt-3 leading-[0.95] text-[clamp(30px,3.5vw,44px)]">Run what<br />you sell.</h2>
        </div>
        <div class="prose-irl">
          <p>Behind this site is a Kubernetes platform I operate myself: Helm deploys driven by Ansible, secrets synced from one source of truth into Vault and the cluster, metrics, logs, and alerting on everything. The open-source side — claudesync, agent-ops — is where agentic engineering practices get proven before they go anywhere near client work.</p>
          <p>Every recommendation I make, I have operated. See <a href="/projects/">Projects</a> for the receipts.</p>
        </div>
      </section>

      <div class="py-14 max-md:py-9">
        <p class="font-display font-normal text-fg-1 uppercase leading-[1.1] tracking-[0.03em] text-[clamp(24px,3vw,40px)] max-w-[24ch] m-0">
          "I won't pretend the homelab is production-grade — it's a lab, and you're paying me to know the difference."
        </p>
        <span class="font-mono text-[11px] tracking-eyebrow uppercase text-fg-muted block mt-4">— On the operation</span>
      </div>

      <section class="grid grid-cols-[280px_minmax(0,1fr)] gap-14 py-12 border-t border-rule max-md:grid-cols-1 max-md:gap-5 max-md:py-8">
        <div>
          <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2">/03 — How I work</div>
          <h2 class="font-display font-normal text-fg-1 uppercase mt-3 leading-[0.95] text-[clamp(30px,3.5vw,44px)]">Async-first.<br />Written-over-<br />verbal.</h2>
        </div>
        <div class="prose-irl">
          <p>Decisions land in documents, not meeting memories. I scope before I build, and you own everything when it is done: code, infrastructure, documentation, accounts. I build with agents and review like I don't.</p>
          <p>This is not a preference list — it is how I produce my best work. Clients who lean into it get unusually thorough engineering and unusually well-documented deliverables. If you need an always-on, meetings-driven collaborator, I will say so early and point you somewhere better.</p>
          <p class="font-mono text-[12px] tracking-wider-2 uppercase">
            <a href="https://github.com/Deathnerd" class="text-accent-2-hover no-underline hover:text-fg-1">GitHub ↗</a>
            <span class="text-fg-muted mx-3">·</span>
            <a href="https://www.linkedin.com/in/george-gilleland-71793bb0" class="text-accent-2-hover no-underline hover:text-fg-1">LinkedIn ↗</a>
          </p>
        </div>
      </section>

    </div>

    <CTABlock title="Sound like your kind<br />of engineer?">
      Start with an email. Describe the system that hurts.
    </CTABlock>
  </main>
</BaseLayout>
```

- [ ] **Step 2: Copy pipeline**

Run the `human-voice` skill over all prose in the page; iterate until the score bottoms out. Then guard-scan the final copy:

Run: `cd ~/projects/infinite-room-labs/self-employment && uv run --no-project python scripts/public_copy_scan.py ~/projects/infinite-room-labs/irl-website/src/pages/about.astro`
Expected: `clean`.

Claim-window review by hand (the scanner is conservative): confirm the page contains no role-ended/runway/non-solicitation material, no availability language, and no dated productivity claims.

- [ ] **Step 3: Build and verify**

Run: `pnpm run build`
Expected: success.

Run: `grep -c 'Wes Gilleland' dist/client/about/index.html`
Expected: `1` or more.

- [ ] **Step 4: Commit**

```bash
git add src/pages/about.astro
git commit -m "feat(about): three-section about page with pull quote and identity links"
```

---

### Task 7: Contact page

**Files:**
- Create: `src/pages/contact.astro`

**Interfaces:**
- Consumes: `NAV_LINKS`, `PageHead`, `CTABlock`.

- [ ] **Step 1: Create `src/pages/contact.astro`**

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
import PageHead from '../components/PageHead.astro';
import CTABlock from '../components/CTABlock.astro';
import { NAV_LINKS } from '../nav';
import '../styles/prose.css';
---
<BaseLayout
  title="Contact — Infinite Room Labs"
  description="Start with an email to hello@infiniteroomlabs.com. No forms, no discovery-call gauntlet — describe your problem and get a written reply."
  navLinks={NAV_LINKS}
  footerSitemapLinks={NAV_LINKS}
  sourcePath="src/pages/contact.astro"
>
  <main id="main">
    <PageHead
      eyebrow="Contact"
      title="Start with<br />an email."
      sub="No forms. No calendar links. No discovery-call gauntlet. Describe the problem in writing and you will get a considered reply in writing."
    />

    <div class="max-w-shell mx-auto px-12 max-md:px-5">

      <section class="grid grid-cols-[280px_minmax(0,1fr)] gap-14 py-12 border-b border-rule max-md:grid-cols-1 max-md:gap-5 max-md:py-8">
        <div>
          <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2">/01 — What to include</div>
          <h2 class="font-display font-normal text-fg-1 uppercase mt-3 leading-[0.95] text-[clamp(30px,3.5vw,44px)]">Give me the<br />shape of it.</h2>
        </div>
        <div class="prose-irl">
          <ul>
            <li><strong>The system that hurts.</strong> What breaks, how often, and who feels it.</li>
            <li><strong>The stack.</strong> Languages, hosting, deployment story — even if the story is "Dave SFTPs it up on Fridays."</li>
            <li><strong>The outcome you want.</strong> Faster deploys, lower hosting bills, an exit from a legacy platform, an audit before you commit.</li>
            <li><strong>Constraints, if you know them.</strong> Timeline shape, budget shape, compliance context. Rough is fine.</li>
          </ul>
        </div>
      </section>

      <section class="grid grid-cols-[280px_minmax(0,1fr)] gap-14 py-12 max-md:grid-cols-1 max-md:gap-5 max-md:py-8">
        <div>
          <div class="font-mono text-[11px] tracking-eyebrow uppercase text-accent-2">/02 — What happens next</div>
          <h2 class="font-display font-normal text-fg-1 uppercase mt-3 leading-[0.95] text-[clamp(30px,3.5vw,44px)]">A reply,<br />in writing.</h2>
        </div>
        <div class="prose-irl">
          <p>You will get a written response — usually with clarifying questions, sometimes with "this isn't a fit" and a pointer to someone better suited. No hard sell either way.</p>
          <p>If it is a fit, the next artifact is a <strong>written scope</strong>: what gets built, what it costs, what you own when it is done. Scoped before built — always.</p>
        </div>
      </section>

    </div>

    <CTABlock eyebrow="The address" title="hello@<br />infiniteroomlabs.com">
      One inbox, read by the person who does the work.
    </CTABlock>
  </main>
</BaseLayout>
```

- [ ] **Step 2: Copy pipeline**

Run the `human-voice` skill over all prose; iterate. Then:

Run: `cd ~/projects/infinite-room-labs/self-employment && uv run --no-project python scripts/public_copy_scan.py ~/projects/infinite-room-labs/irl-website/src/pages/contact.astro`
Expected: `clean`.

Claim-window review by hand: no response-time SLA anywhere ("considered reply", not "reply within N days"), no availability language.

- [ ] **Step 3: Build and verify**

Run: `pnpm run build`
Expected: success.

Run: `grep -c 'mailto:hello@infiniteroomlabs.com' dist/client/contact/index.html`
Expected: `1` or more.

- [ ] **Step 4: Commit**

```bash
git add src/pages/contact.astro
git commit -m "feat(contact): no-form contact page with qualification copy"
```

---

### Task 8: Full verification sweep + changelog

**Files:**
- Modify: `CHANGELOG.md` (Unreleased section)

**Interfaces:**
- Consumes: everything above.

- [ ] **Step 1: Full build**

Run: `pnpm run build`
Expected: success; sitemap regenerated.

Run: `grep -o '<loc>[^<]*</loc>' dist/client/sitemap-0.xml | sort`
Expected: entries for `/`, `/about/`, `/contact/`, `/projects/` and all four project slugs.

- [ ] **Step 2: Browser pass**

Start `pnpm run dev` (background, no output pipe — piping through `head` kills the server). Using claude-in-chrome at 1440x900 and 390x844, visit `/`, `/about`, `/projects`, `/projects/claudesync`, `/contact` and check: nav renders with active state, mobile menu toggle works, cards link to detail pages, no text is illegibly dim, no horizontal overflow at 390px. Kill the dev server when done.

- [ ] **Step 3: Final guard sweep**

Run: `cd ~/projects/infinite-room-labs/self-employment && for f in ~/projects/infinite-room-labs/irl-website/src/pages/about.astro ~/projects/infinite-room-labs/irl-website/src/pages/contact.astro ~/projects/infinite-room-labs/irl-website/src/pages/projects/index.astro ~/projects/infinite-room-labs/irl-website/src/content/projects/*.mdx; do uv run --no-project python scripts/public_copy_scan.py "$f"; done`
Expected: `clean` for every file.

- [ ] **Step 4: Changelog entry**

Add under `## [Unreleased]` / `### Added` in `CHANGELOG.md`:

```markdown
- Multi-page site: `/about` (three-section narrative + pull quote), `/projects` gallery + `/projects/[slug]` detail pages driven by a new `projects` content collection (claudesync, agent-ops, homelab-platform, featmap-fork), and `/contact` (no-form, qualification copy). New `PageHead`, `CTABlock`, `ProjectCard` components and `src/nav.ts` shared nav constant; splash header now uses the `Nav` component with links.
```

- [ ] **Step 5: Commit and push the branch**

```bash
git add CHANGELOG.md
git commit -m "docs(changelog): multi-page site entry"
git push -u origin feature/multi-page
```

Merge to `main` and deploy are a separate, user-approved step (deploy requires the user's wrangler auth; merging to main triggers the changelog guard, satisfied by this entry).
