---
name: technical-seo
description: >
  Technical SEO for web applications: deciding indexability, environment-derived
  robots directives, canonical URLs, crawlable rendering, honest structured data,
  sitemaps and robots.txt.
  Trigger: When building public-facing pages, editing document head or metadata,
  writing robots.txt or sitemap.xml, adding structured data, configuring canonical
  or hreflang, or setting up a staging/preview deployment.
metadata:
  author: micio86dev
  version: "1.0"
---

## When to Use

Load this skill when:
- Building or editing a page that is **meant to be found by search engines**
- Editing the document `<head>`, titles, descriptions, or canonical URLs
- Writing `robots.txt`, `sitemap.xml`, or JSON-LD structured data
- Configuring a staging, preview, or non-production deployment
- Deciding whether a route should be server-rendered for crawlability

**Do not load it** for CLIs, libraries, API-only services, admin panels, dashboards,
or anything behind authentication. Those are not SEO targets, and adding indexing
machinery to them is a defect, not an improvement.

Accessibility and general web performance are separate concerns — semantic markup
belongs to the `accessibility` skill. Only their SEO-relevant consequences appear here.

## Critical Patterns

### Pattern 1: Decide indexability before writing any metadata

The first question is not "what title?" — it is **"is this surface supposed to be
public at all?"** Most application routes are not.

| Surface | Indexed |
|---|---|
| Marketing site, docs, public content | Yes, deliberately |
| Authenticated app, admin, internal tool | Never |
| Staging, preview, ephemeral deploys | No |

Indexing is opt-in. A page becomes indexable because someone decided it should be,
not because it happens to render HTML.

### Pattern 2: Derive indexability from configuration, and fail closed

Resolve the directive from explicit configuration, never from a hostname substring —
that breaks the first time a preview domain, a custom staging host, or a rebrand
appears. Anything not explicitly recognised as production-and-public resolves to
`noindex`. A missing environment variable must produce a private site.

Prefer `noindex` alone. `nofollow` stops the crawler following links from the page;
it is not needed to keep a page out of the index, and adding it by reflex is cargo cult.

### Pattern 3: `robots.txt` controls crawling — `noindex` controls indexing

Different mechanisms, and they interfere with each other:

- A URL disallowed in `robots.txt` is **not crawled**, so its `noindex` is never read —
  and it can still be indexed from external links, as a bare URL.
- To remove a page from search: **allow the crawl and serve `noindex`.**
- `noindex` inside `robots.txt` is unsupported by Google and ignored.
- Never disallow the CSS and JS a page needs to render; the crawler then judges a
  broken page.
- None of this is access control. `robots.txt` is public and advertises the paths it
  names. Sensitive routes need authentication, not a directive.

### Pattern 4: Structured data must describe what the page actually shows

Emit JSON-LD only for entities a user can see on that page. Ratings without visible
reviews, uncredited authors, undisplayed prices — grounds for a manual action, not a
ranking gain. Validate before shipping.

### Pattern 5: Render what you want crawled

Crawlers do execute JavaScript, but rendering is deferred and not guaranteed per URL.
Concrete test: load the page with JavaScript disabled. If the main content is gone,
a crawler may never index it.

Server-render or pre-render the routes whose content must be found. That is a
per-route decision driven by what needs indexing — **not** a blanket requirement to
adopt SSR, and not a reason to restructure an architecture with no public pages.
Verify the HTML a crawler receives, not the DOM after hydration.

## Code Examples

### Example 1: Environment-derived, fail-closed indexability

```js
// Explicit configuration wins. Unknown environment => not indexable.
const env = process.env.DEPLOY_ENV;                 // "production" | "staging" | undefined
const publicSite = process.env.PUBLIC_INDEXING === "enabled";

const indexable = env === "production" && publicSite;
const robots = indexable ? "index, follow" : "noindex";
```

Environment variables are one carrier. Build-time config, edge config, or a
deploy-target flag work identically — what matters is that the value is *declared*
and that the fallback is `noindex`.

### Example 2: A public page head

```html
<html lang="en">
  <head>
    <title>Rate limiting in distributed systems — Acme Engineering</title>
    <meta name="description" content="Shaping burst traffic across regions without a shared counter." />
    <meta name="robots" content="index, follow" />
    <link rel="canonical" href="https://acme.example/blog/rate-limiting" />
    <meta property="og:title" content="Rate limiting in distributed systems" />
    <meta property="og:url" content="https://acme.example/blog/rate-limiting" />
  </head>
</html>
```

Titles and descriptions are per page. One shared pair across every route tells a
search engine the pages are interchangeable. Add Open Graph tags only for pages
people will actually share; they affect link previews, not ranking.

### Example 3: robots.txt aligned with intent

```
User-agent: *
Allow: /

Sitemap: https://acme.example/sitemap.xml
```

Note what is **not** here. Private routes are not listed: `robots.txt` is a public
file, so naming `/admin/` or `/account/` publishes your URL structure while doing
nothing to deindex them (see Pattern 3). Authenticated routes are handled by
authentication plus `noindex`, not by a disallow line.

Non-production deployments serve `User-agent: *` / `Disallow: /` instead, paired
with a `noindex` response — the disallow alone cannot keep an externally linked
URL out of the index.

### Example 4: Structured data that matches the page

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Rate limiting in distributed systems",
  "datePublished": "2026-01-15",
  "author": { "@type": "Person", "name": "Name shown in the byline" }
}
</script>
```

### Example 5: Non-HTML responses

```
X-Robots-Tag: noindex
```

A `<meta>` tag cannot reach a PDF, an image, or a JSON endpoint. Use the header.

## Anti-Patterns

### Don't: decide indexability by hostname string matching

```js
// DON'T: a new preview domain, a custom staging host, or a rebrand silently
// flips this to "production" and publishes the wrong site.
const isProd = location.hostname.includes("acme");
```

### Don't: default to indexable when the environment is unknown

```js
// DON'T: fails open. One missing env var and staging is in the index.
const robots = env === "staging" ? "noindex" : "index, follow";
```

### Don't: block a page in robots.txt to remove it from search

```
# DON'T: the crawler never reads your noindex, and the URL can still appear
Disallow: /old-campaign
```

### Don't: point every canonical at the home page

```html
<!-- DON'T: tells the engine none of your pages are worth indexing separately -->
<link rel="canonical" href="https://acme.example/" />
```

### Don't: add SEO machinery to an authenticated surface

Sitemaps, canonical tags and JSON-LD on a dashboard behind a login add maintenance
and leak URL structure. Those routes want `noindex`, nothing more.

### Don't: claim `llms.txt` improves AI visibility

`llms.txt` is a **proposed community convention**, not a W3C or WHATWG standard.
Adoption varies and no major AI system has committed to honouring it. Adding one is
cheap and harmless — do it if asked — but it is not a ranking factor and it does not
guarantee citation in ChatGPT, Claude, Gemini, Perplexity or anything else.

What makes content usable by machines is the work that has always made it findable:
crawlable server-rendered content, semantic HTML, accurate structured data, stable
URLs, and not blocking the agents you want to be read by.

## Internationalization

Set `<html lang="...">` on every page. Beyond that, only when a page genuinely
exists in several languages: `hreflang` must be **reciprocal** — every variant
lists every other variant, including itself, or the annotations are ignored. Keep
each localized URL canonical to itself: canonicalising it to the default language
asks the engine to drop it, which defeats the hreflang set you just declared. Skip
hreflang entirely on single-locale sites; broken hreflang is worse than none.

## Deterministic Verification

Prefer a tool over an opinion, and use what the project already has.

| Question | Check |
|---|---|
| Is the built page indexable? | `curl -s <url> \| grep -iE 'robots\|canonical'` |
| What does a crawler receive? | Fetch with JavaScript disabled, inspect the HTML |
| Is the structured data valid? | Rich Results Test / Schema Markup Validator |
| Are titles and descriptions unique? | Crawl the sitemap, assert no duplicate pairs |
| Is the sitemap valid? | Fetch `/sitemap.xml`, assert 200 and well-formed XML |
| Page-level audit | Lighthouse SEO category |

Add one assertion to the existing E2E suite: **non-production builds must serve
`noindex`.** One line, and it catches the failure that matters most.

## Quick Reference

| Task | Rule |
|---|---|
| Non-production deploy, or unrecognised environment | `noindex` (fail closed) |
| Authenticated / admin routes | `noindex`, no sitemap entry |
| Duplicate or parameterized URLs | One absolute, self-referencing canonical |
| Remove a page from search | Allow crawl **and** serve `noindex` |
| Structured data | Only for content visible on the page |
| Sitemap contents | Only URLs meant to be discoverable |
| Non-HTML resources | `X-Robots-Tag` header |
| Permanently moved URL | `301`, direct to the final target — avoid redirect chains |
| Sensitive paths | Authentication — never `robots.txt` |

## Resources

- [Google Search Central — crawling and indexing](https://developers.google.com/search/docs/crawling-indexing)
- [Google — robots meta tag and X-Robots-Tag](https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag)
- [RFC 9309 — Robots Exclusion Protocol](https://www.rfc-editor.org/rfc/rfc9309.html)
- [Schema.org](https://schema.org)
