# SRE-Alerting-Guidelines

A peer-to-peer style guide for writing effective alerts. This is the long-term,
transparent home for the guide's content and its living issue tracker; the
finished guide is published as a project page under
[writings.conall.dev/projects/](https://writings.conall.dev/projects/).

## Preview site

This repo builds as a standalone [Hugo](https://gohugo.io/) site (theme:
[PaperMod](https://github.com/adityatelange/hugo-PaperMod), pinned as a git
submodule at `themes/PaperMod`), so edits can be previewed — Markdown
rendering, headings, TOC, links — before they're copied over to
writings.conall.dev's `content/projects/`.

```bash
git submodule update --init --recursive
hugo server --buildDrafts
```

### Cloudflare preview deployments

`wrangler.jsonc` and `scripts/ci-build.sh` mirror the pattern used by
writings.conall.dev: connect this repo to a **Cloudflare Workers Builds**
project (dashboard → Workers & Pages → Create → Import a repository), and it
will build every branch automatically:

- `main` deploys to the project's production URL.
- Any other branch deploys to a preview URL of the form
  `https://<branch-slug>-sre-alerting-guidelines.<workers-dev-subdomain>.workers.dev/`
  (the build script derives the slug from `WORKERS_CI_BRANCH` and overrides
  `baseURL` accordingly, so internal links stay on the preview domain).

No GitHub Actions workflow or cross-repo push is needed — Cloudflare builds
straight off whatever branch you push here.

### Publishing

Once a section of the guide is ready, copy the corresponding page(s) from
`content/projects/sre-alerting-guidelines/` here into
`content/projects/sre-alerting-guidelines/` on writings.conall.dev and open a
PR there. This repo's copy stays the editable source of truth and preview
surface; writings.conall.dev only receives finished pages.
