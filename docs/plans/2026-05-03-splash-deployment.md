# Splash deployment plan — 2026-05-03

Status: **draft, pre-rollout**
Branch: `main`
Target: `https://infiniteroomlabs.com/`
Hosts: Cloudflare Workers (via `@astrojs/cloudflare` adapter, `wrangler.jsonc`)

---

## Goal

Soft-launch a single-page splash at the apex domain while the full multi-page
site is finished on `feature/full-site`. Establish brand presence,
discoverability, and a low-friction inbound channel without:

- broadcasting Wes's personal address to scrapers,
- exposing pages that don't exist publicly yet,
- degrading SEO posture for the eventual full launch.

---

## Decisions log

### D-1 · Public address: `hello@infiniteroomlabs.com`

Public mailto and meta description use `hello@` instead of `wes@`.

**Why**

- Once a plaintext email lands on a public HTML page, scraper lists capture it
  permanently. Removing it later doesn't undo the harvest.
- A role-based address keeps Wes's direct address out of public surfaces while
  preserving the personal touch through the *reply* (Wes replies from his
  personal account).
- When scale demands triage, the forwarder behind `hello@` can be replaced
  with a shared inbox or routing rule **without changing the public address**.
  OG cards, bookmarks, LinkedIn references, schema.org `contactPoint` —
  everything that already references `hello@` keeps working.

**Current state of forwarders**

- `wes@infiniteroomlabs.com` — Cloudflare Email Routing rule, manually
  configured in the Cloudflare dashboard, forwards to Wes's personal Gmail.
  Not yet captured in IaC.
- `hello@infiniteroomlabs.com` — **does not exist yet**. Wes will add the same
  forward (`hello@infiniteroomlabs.com → personal Gmail`) in the Cloudflare
  Email Routing dashboard before the splash goes live.

### D-2 · Defensive posture for email harvesting: Cloudflare Email Address Obfuscation

Enable **Email Address Obfuscation** in the Cloudflare dashboard for the
`infiniteroomlabs.com` zone (`Scrape Shield → Email Address Obfuscation`).

**What it does**

- Auto-rewrites every `mailto:` href and visible email text to obfuscated JS
  that decrypts client-side at view time.
- Real users see the email normally. Naive scrapers (regex-on-HTML) see
  `[email protected]` and a `data-cfemail="..."` hex blob.
- Cuts harvest volume from low-effort scrapers materially. Doesn't stop a
  determined adversary, but they're not the threat model.

**Why this and not Turnstile / Bot Fight Mode**

- A `mailto:` is plaintext HTML. A challenge/captcha can't gate it because
  scrapers parse the HTML directly without rendering JavaScript. Captchas
  protect *form submissions*, not link harvesting.
- Aggressive **Bot Fight Mode** would block AI crawlers (GPTBot, ClaudeBot,
  PerplexityBot) and risk degrading Googlebot crawl. For a soft-launch
  consultancy trying to be discoverable, that's the wrong trade-off.
- Email Address Obfuscation is a pure HTML rewrite — zero SEO cost, zero
  bot challenges, zero impact on legitimate crawlers indexing page content.

### D-3 · Indexing posture: index now, no `noindex`

Splash is indexable from the day of soft launch.

**Why**

- Domain age and crawl history take 3–6 months to settle on a fresh apex.
  Noindexing forfeits crawl equity that can't be recovered later when the
  full site ships.
- A single well-structured page with correct title, description, JSON-LD,
  and OG metadata is not a "thin content" penalty risk — it's a placeholder
  with entity signals.
- The only opportunity cost is keyword surface, which the title/description
  rewrite already addresses.

### D-4 · No Turnstile / Bot Fight Mode on the splash

Reaffirms D-2. The splash has no form to protect, so adding either of these
would only degrade indexability for zero defensive gain. Re-evaluate when
the contact form on `feature/full-site` ships.

### D-5 · No social profile links on the splash yet

`sameAs` array in JSON-LD and visible footer LinkedIn / GitHub links are
deferred until profile cleanup is complete. Re-introduce in a follow-up
commit once profiles reflect the IRL brand.

### D-6 · OG card is a placeholder PNG

`/public/og-default.png` is generated from `/public/og-default.svg` via
Inkscape (Bebas Neue + IBM Plex installed locally). Good enough for the
soft launch; replace with a designer-quality card before any paid promotion
or major social push.

---

## Pre-rollout checklist

### Cloudflare dashboard (manual — Wes)

- [ ] **Add `hello@infiniteroomlabs.com` Email Routing rule** forwarding to
      Wes's personal Gmail. Same destination as the existing `wes@` rule.
- [ ] **Send a test email** to `hello@infiniteroomlabs.com` and verify it
      lands in the personal Gmail inbox before the splash goes public.
- [ ] **Enable Email Address Obfuscation** under
      `Scrape Shield → Email Address Obfuscation` for the
      `infiniteroomlabs.com` zone.
- [ ] **Enable Cloudflare Web Analytics** in the Cloudflare Pages / Workers
      project for `infiniteroomlabs.com` (one checkbox, no script tag, no
      cookie banner, free).
- [ ] Confirm **Bot Fight Mode is OFF** (or in default low-friction setting)
      so legitimate AI crawlers and Googlebot are not blocked.
- [ ] **Add a Cache Rule for SSR responses.**
      `Rules → Caching Rules → Create rule`. Match
      `(http.host in {"infiniteroomlabs.com" "www.infiniteroomlabs.com"})`.
      Set cache eligibility to "Eligible for cache" and both Edge TTL and
      Browser TTL to "Use cache-control header from origin". Without this
      rule, Worker responses bypass the edge cache entirely (regardless of
      the Cache-Control header on the response) — every hit invokes the
      Worker. With it, the middleware-set `s-maxage=300` header takes
      effect and repeat hits to the same URL serve from edge cache.

### Repo (already shipped on `main`)

- [x] Public mailto changed to `hello@infiniteroomlabs.com` with
      `?subject=Inquiry%20%5BIRL-splash%5D` for inbound source attribution.
- [x] Meta description references `hello@`.
- [x] OG card (`/public/og-default.png`) regenerated with `hello@`.
- [x] `OrganizationSchema.astro` `contactPoint.email` set to `hello@`.

### Build & deploy

- [ ] `npm run build` — verify clean.
- [ ] `wrangler deploy` (or whatever the chosen deploy mechanism is) to push
      to Cloudflare Workers.
- [ ] DNS check: apex `infiniteroomlabs.com` resolves to the deployed Worker.
- [ ] Real-world OG preview test: paste the production URL into LinkedIn,
      Slack, and iMessage; confirm card renders with the brand image.
- [ ] Real-world inbox test: click the splash mailto from the live site,
      send an email, confirm it lands in Wes's Gmail with the expected
      `[IRL-splash]` subject tag.

---

## Follow-ups (not blocking soft launch)

### F-1 · Move email forwarders into IaC

Capture the `wes@` and `hello@` Cloudflare Email Routing rules as Terraform
resources in `infinite-room-labs-infra`. New module:
`terraform/modules/cloudflare-email-routing/` and a leaf at
`terraform/environments/prod/cloudflare/email-routing/`. Use the
[`cloudflare_email_routing_address`](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_address)
+ [`cloudflare_email_routing_rule`](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_rule)
resources. Import the existing rules so state matches reality.

This is currently a **manual configuration drift risk** — anyone with
Cloudflare dashboard access could change the routing without trace.

### F-2 · Designer-quality OG card

Commission or hand-build a polished 1200×630 OG card to replace the
Inkscape-rendered placeholder. Use it before any paid promotion.

### F-3 · Reintroduce LinkedIn + GitHub once profiles are cleaned up

When ready, restore:

- `sameAs` array in `OrganizationSchema.astro`
- visible footer `Profile` link (or equivalent) in the splash markup

### F-4 · Q3 2026 stamp watch

The splash carries a visible `Full site · Q3 2026` ETA. Set calendar
reminders to either ship the full site ahead of Q3 or update the stamp
before it ages into a liability. The longer this stamp is wrong, the more
it damages the first impression for repeat visitors.

### F-5 · DMARC tightening

Current DMARC policy on `infiniteroomlabs.com` is `p=none` (per
`infinite-room-labs-infra/terraform/environments/prod/env.hcl`). Once the
inbound forwarder is stable and we've verified no legit mail is being
mishandled, tighten to `p=quarantine` and eventually `p=reject` with an
`rua=` reporting endpoint. Reduces spoofing risk on the IRL brand.

---

## Cross-references

- `infinite-room-labs-infra/terraform/environments/prod/env.hcl` — current
  SendGrid DNS records and DMARC posture for `infiniteroomlabs.com`.
- `infinite-room-labs-infra/terraform/modules/sendgrid-config/` — outbound
  mail config (separate from the inbound forwarder concern above).
- `splash-prompt.md` (repo root) — the Claude Design follow-up brief that
  produced this splash.
- `CHANGELOG.md` — running list of code-level changes for the soft launch.
