#!/usr/bin/env bash
set -euo pipefail

# Runs from the repo root (see wrangler.jsonc's build.command). All the Hugo
# scaffolding - config, content, theme submodule - lives under preview/ so
# the top-level sre-alerting-guidelines.md stays the one canonical content
# file; preview/content/.../index.md is a symlink to it.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

git submodule update --init --recursive preview/themes/PaperMod

curl -fsSL https://github.com/gohugoio/hugo/releases/download/v0.147.2/hugo_extended_0.147.2_linux-amd64.tar.gz | tar -xz -C /tmp hugo

# Cloudflare Workers Builds set WORKERS_CI_BRANCH to the git branch being built.
# Production deploys (main) use hugo.toml's baseURL as-is. Preview deploys
# override it to the branch preview URL, so internal links (nav, breadcrumbs,
# tags, etc. - PaperMod bakes these in via absURL/absLangURL) stay on the
# preview domain instead of pointing at production. Mirrors the same pattern
# used by writings.conall.dev, which this content is eventually copied into.
WORKER_NAME="${WRANGLER_CI_OVERRIDE_NAME:-sre-alerting-guidelines}"
WORKERS_DEV_SUBDOMAIN="conall-ac7"

BASEURL_ARGS=()
if [ -n "${WORKERS_CI_BRANCH:-}" ] && [ "${WORKERS_CI_BRANCH}" != "main" ]; then
  SLUG=$(echo "$WORKERS_CI_BRANCH" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
  BASEURL_ARGS=(--baseURL "https://${SLUG}-${WORKER_NAME}.${WORKERS_DEV_SUBDOMAIN}.workers.dev/")
fi

# -s preview: the Hugo site root (hugo.toml, content/, themes/) lives there;
# public/ is created inside it, matching wrangler.jsonc's assets.directory.
/tmp/hugo --source preview --minify --buildDrafts "${BASEURL_ARGS[@]}"
