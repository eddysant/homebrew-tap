#!/usr/bin/env bash
set -euo pipefail

repository="eddysant/siftr"
cask_file="Casks/siftr.rb"
# Authenticate the API call when a token is available. Unauthenticated
# api.github.com requests from Actions runners share a per-IP pool capped at
# 60/hour, which is what caused the intermittent 403s on this schedule.
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
version="$(jq -r '.tag_name // empty' <<<"${release_json}")"
version="${version#v}"

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Latest release has an invalid version: ${version}" >&2
  exit 1
fi

asset_name="siftr-${version}-arm64.dmg"
asset_url="$(jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .browser_download_url' <<<"${release_json}")"
if [[ -z "${asset_url}" || "${asset_url}" != "https://github.com/${repository}/releases/download/v${version}/${asset_name}" ]]; then
  echo "Release v${version} does not contain ${asset_name}" >&2
  exit 1
fi

current_version="$(sed -n 's/^[[:space:]]*version "\([^"]*\)"/\1/p' "${cask_file}")"
if [[ "${current_version}" == "${version}" ]]; then
  echo "siftr ${version} is already current"
  exit 0
fi

download_dir="$(mktemp -d)"
trap 'rm -rf "${download_dir}"' EXIT
curl -fsSL --retry 3 --output "${download_dir}/${asset_name}" "${asset_url}"
sha256="$(shasum -a 256 "${download_dir}/${asset_name}" | awk '{print $1}')"

VERSION="${version}" SHA256="${sha256}" ruby -e '
  # Read and write as UTF-8 explicitly. Ruby otherwise uses the locale external
  # encoding, which is US-ASCII on a bare runner, and any non-ASCII character in
  # the cask (an em dash in a description, say) makes sub! raise
  # "invalid byte sequence in US-ASCII".
  file = ARGV.fetch(0)
  contents = File.read(file, encoding: "UTF-8")
  contents.sub!(/version "[^"]+"/, %(version "#{ENV.fetch("VERSION")}")) or abort "version stanza not found"
  contents.sub!(/sha256 "[0-9a-f]+"/, %(sha256 "#{ENV.fetch("SHA256")}")) or abort "sha256 stanza not found"
  File.write(file, contents, encoding: "UTF-8")
' "${cask_file}"

echo "Updated siftr cask to ${version} (${sha256})"
