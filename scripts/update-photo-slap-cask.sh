#!/usr/bin/env bash
set -euo pipefail

repository="eddysant/photo-slap-modern"
cask_file="Casks/photo-slap.rb"
release_json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/${repository}/releases/latest")"
version="$(jq -r '.tag_name // empty' <<<"${release_json}")"
version="${version#v}"

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Latest release has an invalid version: ${version}" >&2
  exit 1
fi

asset_name="photo-slap-Mac-${version}-Installer.dmg"
asset_url="$(jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .browser_download_url' <<<"${release_json}")"
if [[ -z "${asset_url}" || "${asset_url}" != "https://github.com/${repository}/releases/download/v${version}/${asset_name}" ]]; then
  echo "Release v${version} does not contain ${asset_name}" >&2
  exit 1
fi

current_version="$(sed -n 's/^[[:space:]]*version "\([^"]*\)"/\1/p' "${cask_file}")"
if [[ "${current_version}" == "${version}" ]]; then
  echo "photo-slap ${version} is already current"
  exit 0
fi

download_dir="$(mktemp -d)"
trap 'rm -rf "${download_dir}"' EXIT
curl -fL --retry 3 --output "${download_dir}/${asset_name}" "${asset_url}"
sha256="$(shasum -a 256 "${download_dir}/${asset_name}" | awk '{print $1}')"

VERSION="${version}" SHA256="${sha256}" ruby -e '
  file = ARGV.fetch(0)
  contents = File.read(file)
  contents.sub!(/version "[^"]+"/, %(version "#{ENV.fetch("VERSION")}")) or abort "version stanza not found"
  contents.sub!(/sha256 "[0-9a-f]+"/, %(sha256 "#{ENV.fetch("SHA256")}")) or abort "sha256 stanza not found"
  File.write(file, contents)
' "${cask_file}"

echo "Updated photo-slap cask to ${version} (${sha256})"
