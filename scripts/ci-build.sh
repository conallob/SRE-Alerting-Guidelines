#!/usr/bin/env bash
set -euo pipefail

git submodule update --init --recursive

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

/tmp/hugo --minify --buildDrafts "${BASEURL_ARGS[@]}"
