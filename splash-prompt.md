# Claude Design follow-up prompt — splash page

Paste into the same Claude Design session that produced `Infinite Room Labs.html`.

---

We're putting the full site on a feature branch and shipping a single-page **splash/teaser** at the domain root first, while content is still WIP. The splash will be replaced by the full home page (Hero A) when we're ready. It needs to feel like a stripped sibling of what we've already built — same Fortress identity, same chrome vocabulary — so the eventual transition reads as evolution, not redesign.

**Goal.** Develop **Hero C from the original Home Hero Treatments exploration** (`heroes/HeroC.jsx`) into a fully-realized standalone splash page. The terminal/IDE pane rendering `brief.md` as YAML is the entire visual. No other hero, no tracks section, no ecosystem teaser, no closing CTA block.

**Layout.**

- Top: gradient bar + threshold mark + "Infinite Room Labs" wordmark, top-left only. **No nav links** — pages they'd point to don't exist publicly yet.
- Center: the editor pane, viewport-fit on desktop (1440×900), gracefully scaling on mobile. Line gutter, gradient-bar lintel, the existing `tagline:` value rendered in Bebas Neue inside the code block, blinking red cursor.
- Below pane: a thin `/STATUS` eyebrow strip, three dense mono one-liners.
- One CTA: mailto `wes@infiniteroomlabs.com`, styled as the primary button. Either inside the editor's status footer or below the status strip — see variations.
- Footer: gradient bar + brand-mark block + LLC/Lexington KY/©2026 in mono. Strip the sitemap/contact/legal columns from the existing footer — none of those targets are live yet.

**Content — render this YAML inside the editor pane verbatim:**

```yaml
# brief.md — Infinite Room Labs
name:        Infinite Room Labs
entity:      Kentucky LLC · Est. 2026
location:    Lexington, KY · Eastern Time
status:      Soft launch · Accepting select work
tagline:     Automate all the things.
practice:
  - Legacy modernization
  - CI/CD rescue
  - Infrastructure as code
  - MSP-stack integration
  - Agentic AI infrastructure
  - Small-business projects (sites, e-commerce, internal tools)
model:       Paid discovery → written milestones → client owns everything
contact:     wes@infiniteroomlabs.com
# full site shipping soon. for now: the brief above is the deal.
```

`tagline:` value renders in Bebas Neue at display size (so the doc itself carries the brand headline). YAML keys/values otherwise use the existing mono treatment.

**Status strip below the pane — three lines, mono, eyebrow-styled:**

- Currently building the full site
- Accepting discovery sprints now
- Email is the front door

**Hard constraints (these contradict what the full site has, so call them out explicitly):**

- No nav links. Brand mark only.
- No contact form — backend not wired. Mailto only.
- No testimonials, client logos, case studies, pricing — none exist yet.
- No references to specific routes (`/services`, `/pricing`, etc.).
- Respect `prefers-reduced-motion` — pause the blinking cursor when reduced-motion is requested.
- Mobile breakpoint at 900px — editor pane must remain readable, gutter compresses, font-size scales.

**Show me two variations before committing:**

- **Take 1 — Document-as-page.** brief.md pane is the only content on the page. Mailto CTA lives inside the editor's status footer (matches Hero C's original framing where the document IS the page).
- **Take 2 — Pane + status strip.** brief.md pane on top, distinct `/STATUS` strip section below it, mailto as a standalone `s-btn s-btn--primary` button beneath the strip.

Don't generate any other pages — splash only. Keep existing pages.
