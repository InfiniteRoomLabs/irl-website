// @ts-check
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import mdx from '@astrojs/mdx';

// https://astro.build/config
export default defineConfig({
  site: 'https://infiniteroomlabs.com',
  adapter: cloudflare(),

  vite: {
    plugins: [
      tailwindcss()
    ]
  },

  integrations: [
    sitemap(),
    mdx()
  ]
});