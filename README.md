# Infinite Room Labs

## Commands

| Command           | What it does                                  |
| ----------------- | --------------------------------------------- |
| \`npm run dev\`     | Vite dev server on http://localhost:4321      |
| \`npm run build\`   | Production build to ./dist                    |
| \`npm run preview\` | Serves ./dist locally to verify the build     |
| \`npm run astro\`   | Run any astro CLI command                     |

## Structure

- \`src/pages/\` — file-based routes
- \`src/layouts/\` — page shells (just a convention, not framework magic)
- \`src/components/\` — components, including \`seo/\` for JSON-LD blocks
- \`src/content/\` — content collections (services, posts, caseStudies, faqs)
- \`src/content.config.ts\` — Zod schemas validating every collection entry
- \`src/assets/\` — images Astro should optimize at build time
- \`public/\` — static files served verbatim (favicon, robots.txt)

## Dev environment

This project ships with a \`.devcontainer/\` setup. Open in VS Code and choose
"Reopen in Container" to develop inside Docker. The container has fish, gh,
just, jq, and the right Node version preinstalled.

## Deploy

Connect this repo to Cloudflare Pages.
- Build command: \`npm run build\`
- Build output: \`dist\`
- Node version: 20 or 22
