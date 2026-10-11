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

Previews need no GitHub Actions workflow — Cloudflare builds straight off
whatever branch you push here. (Publishing to writings.conall.dev is separate;
see below.)

### Publishing

Merging a change to `sre-alerting-guidelines.md` on `main` publishes it:
[`.github/workflows/publish-to-writings.yml`](./.github/workflows/publish-to-writings.yml)
copies the file to `content/projects/sre-alerting-guidelines/index.md` in
[conallob/writings.conall.dev](https://github.com/conallob/writings.conall.dev)
and pushes it to that repo's `main`, which Cloudflare then deploys. This repo's
copy stays the editable source of truth; the writings repo copy is generated
and shouldn't be edited by hand. The `Last Edited: {{LAST_EDITED}}` line in the
guide is a placeholder: the workflow replaces it (and the front matter `lastmod`)
with the merge commit's date in the published copy, so it stays literal here.

## Repository structure

```
.
├── sre-alerting-guidelines.md   # the guide (edit this)
├── .github/workflows/            # publish-to-writings.yml (deploy-key sync)
├── wrangler.jsonc                # Cloudflare Workers Builds deploy config
└── preview/                      # Hugo preview site (config/theme/tooling only)
    ├── hugo.toml
    ├── archetypes/
    ├── content/                  # site scaffolding (_index.md pages); the
    │                              # guide itself is mounted in, not stored here
    ├── scripts/ci-build.sh
    └── themes/PaperMod/          # git submodule
```

## Use the guide as a Claude Code skill

This repo is also a Claude Code plugin marketplace
([`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json)) that
ships one plugin, `sre-alerting-guidelines`, with a single skill,
`review-alerts`. The skill is a thin pointer: it fetches the current guide from
[writings.conall.dev](https://writings.conall.dev/projects/sre-alerting-guidelines/index.md)
each time it runs instead of bundling a copy, so it never goes stale and reads
of the guide keep going through the published site.

Install it in one step (Claude Code 2.1.275 or later):

```
/plugin install sre-alerting-guidelines --marketplace conallob/SRE-Alerting-Guidelines
```

or add the marketplace and install separately:

```bash
claude plugin marketplace add conallob/SRE-Alerting-Guidelines
claude plugin install sre-alerting-guidelines@conallob
```

Then ask Claude to review an alert, or run `/sre-alerting-guidelines:review-alerts`.

Validate changes to the plugin or marketplace with
`claude plugin validate .` and
`claude plugin validate ./plugins/sre-alerting-guidelines`.
