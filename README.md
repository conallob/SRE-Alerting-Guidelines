# SRE-Alerting-Guidelines

A peer-to-peer style guide for writing effective alerts. This is the long-term,
transparent home for the guide's content and its living issue tracker; the
finished guide is published as a project page under
[writings.conall.dev/projects/](https://writings.conall.dev/projects/).

## Content

[`sre-alerting-guidelines.md`](./sre-alerting-guidelines.md) at the repo root
is the guide itself — the one file to edit. Everything else in the repo is
tooling that exists to preview it.

## Preview site

All the Hugo scaffolding (config, theme, layout) lives under
[`preview/`](./preview), so it doesn't bury the content. `preview/hugo.toml`
mounts the top-level `sre-alerting-guidelines.md` straight into Hugo's
content tree (a `[[module.mounts]]` entry, not a copy or symlink — Hugo
won't follow a symlink that escapes the site root), so there's a single
canonical copy of the text.

```bash
git submodule update --init --recursive preview/themes/PaperMod
cd preview && hugo server --buildDrafts
```

### Cloudflare preview deployments

`wrangler.jsonc` (repo root) and `preview/scripts/ci-build.sh` mirror the
pattern used by writings.conall.dev: connect this repo to a **Cloudflare
Workers Builds** project (dashboard → Workers & Pages → Create → Import a
repository), build command `bash preview/scripts/ci-build.sh`, output
directory `preview/public`. It then builds every branch automatically:

- `main` deploys to the project's production URL.
- Any other branch deploys to a preview URL of the form
  `https://<branch-slug>-sre-alerting-guidelines.<workers-dev-subdomain>.workers.dev/`
  (the build script derives the slug from `WORKERS_CI_BRANCH` and overrides
  `baseURL` accordingly, so internal links stay on the preview domain).

No GitHub Actions workflow or cross-repo push is needed — Cloudflare builds
straight off whatever branch you push here.

### Publishing

Once a section of the guide is ready, copy `sre-alerting-guidelines.md`
(minus its Hugo front matter, or adapted to fit) into
`content/projects/sre-alerting-guidelines/` on writings.conall.dev and open a
PR there. This repo's copy stays the editable source of truth and preview
surface; writings.conall.dev only receives finished pages.

## Repository structure

```
.
├── sre-alerting-guidelines.md   # the guide (edit this)
├── wrangler.jsonc                # Cloudflare Workers Builds deploy config
└── preview/                      # Hugo preview site (config/theme/tooling only)
    ├── hugo.toml
    ├── archetypes/
    ├── content/                  # site scaffolding (_index.md pages); the
    │                              # guide itself is mounted in, not stored here
    ├── scripts/ci-build.sh
    └── themes/PaperMod/          # git submodule
```
