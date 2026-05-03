import { defineMiddleware } from 'astro:middleware';

/**
 * Default cache headers for SSR responses.
 *
 * Background
 * ----------
 * Astro pages with `prerender = false` are rendered by the Worker on every
 * request. Cloudflare's edge cache does NOT auto-cache Worker responses
 * (unlike the Workers Static Assets handler that serves prerendered pages,
 * which caches automatically). Without a Cache Rule attached at the zone
 * level AND a sensible Cache-Control header on the response, every SSR
 * request consumes a Worker invocation.
 *
 * This middleware sets a conservative default Cache-Control on any SSR
 * response that didn't already pick one. Pages can opt out by setting
 * their own header (the 404 page does this with `max-age=300, s-maxage=300`
 * and that header is preserved here because we only set if absent).
 *
 * Pair this with a Cache Rule in the Cloudflare dashboard:
 *   Rules > Caching Rules > Create rule
 *   When: hostname in {infiniteroomlabs.com, www.infiniteroomlabs.com}
 *   Then: Eligible for cache; Edge/Browser TTL = use cache-control from origin
 *
 * Both pieces are required. The header is advisory without the rule; the
 * rule has nothing to act on without the header.
 */

const DEFAULT_SSR_CACHE = 'public, max-age=300, s-maxage=300';

export const onRequest = defineMiddleware(async (_context, next) => {
  const response = await next();

  // Only set a default for cacheable methods. Anything mutating should be
  // explicit about its caching posture and is unlikely to want auto-cache.
  const method = _context.request.method;
  if (method !== 'GET' && method !== 'HEAD') {
    return response;
  }

  if (!response.headers.has('cache-control')) {
    response.headers.set('cache-control', DEFAULT_SSR_CACHE);
  }

  return response;
});
