#!/usr/bin/env bash
set -euo pipefail

# Pull-based formula update, mirroring update-photo-slap-cask.sh.
#
# mediate's own CI used to push here directly, which needed a cross-repo PAT and
# failed with a 403 whenever that token lacked write access to this repo. Reading
# the release from this side needs no PAT: the workflow commits to its own
# repository with the built-in github.token.

repository="eddysant/mediate"
formula_file="Formula/mediate.rb"

# Authenticate when a token is available. Unauthenticated api.github.com requests
# from Actions runners share a per-IP pool capped at 60/hour, which is what caused
# the intermittent 403s on the photo-slap schedule.
fetch_release() {
  if [ -n "${GH_TOKEN:-}" ]; then
    curl -fsSL --retry 3 --retry-all-errors \
      -H 'Accept: application/vnd.github+json' \
      -H 'X-GitHub-Api-Version: 2022-11-28' \
      -H "Authorization: Bearer ${GH_TOKEN}" \
      "https://api.github.com/repos/${repository}/releases/latest"
  else
    curl -fsSL --retry 3 --retry-all-errors \
      -H 'Accept: application/vnd.github+json' \
      -H 'X-GitHub-Api-Version: 2022-11-28' \
      "https://api.github.com/repos/${repository}/releases/latest"
  fi
}

release_json="$(fetch_release)"
tag="$(jq -r '.tag_name // empty' <<<"${release_json}")"
version="${tag#v}"

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Latest release has an invalid version: ${version:-<none>}" >&2
  exit 1
fi

current_version="$(sed -n 's|.*/archive/refs/tags/v\([0-9][^"]*\)\.tar\.gz.*|\1|p' "${formula_file}")"
if [[ "${current_version}" == "${version}" ]]; then
  echo "mediate ${version} is already current"
  exit 0
fi

# The formula wraps the source tarball rather than a release asset, so hash the
# tag archive. Download to a file instead of piping: a truncated transfer would
# otherwise be hashed silently as if it were the whole archive.
tarball_url="https://github.com/${repository}/archive/refs/tags/${tag}.tar.gz"
download_dir="$(mktemp -d)"
trap 'rm -rf "${download_dir}"' EXIT
curl -fsSL --retry 3 --output "${download_dir}/src.tar.gz" "${tarball_url}"

# Sanity check that we fetched an actual gzip archive and not an error page.
if ! gzip -t "${download_dir}/src.tar.gz" 2>/dev/null; then
  echo "Downloaded tarball for ${tag} is not a valid gzip archive" >&2
  exit 1
fi

sha256="$(shasum -a 256 "${download_dir}/src.tar.gz" | awk '{print $1}')"

VERSION="${version}" TAG="${tag}" SHA256="${sha256}" ruby -e '
  file = ARGV.fetch(0)
  contents = File.read(file)
  tag = ENV.fetch("TAG")
  contents.sub!(%r{/archive/refs/tags/v[^"]+\.tar\.gz}, "/archive/refs/tags/#{tag}.tar.gz") or
    abort "url stanza not found"
  contents.sub!(/sha256 "[0-9a-f]+"/, %(sha256 "#{ENV.fetch("SHA256")}")) or
    abort "sha256 stanza not found"
  File.write(file, contents)
' "${formula_file}"

echo "Updated mediate formula to ${version} (${sha256})"
