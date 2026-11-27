#!/bin/sh
# Installs the Kennra CLI from https://github.com/Kennra/cli/releases.
#
#   curl -fsSL https://raw.githubusercontent.com/Kennra/cli/main/install.sh | sh
#
# Options (environment):
#   KENNRA_VERSION      a version such as 0.1.0 (default: the latest release)
#   KENNRA_INSTALL_DIR  where to put the binary (default: /usr/local/bin if writable, else ~/.local/bin)
set -eu

REPO="Kennra/cli"

fail() {
  printf 'kennra install: %s\n' "$1" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || fail "curl is required."

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) fail "unsupported system $os. On Windows, use install.ps1." ;;
esac
case "$arch" in
  arm64 | aarch64) arch=arm64 ;;
  x86_64 | amd64) arch=x64 ;;
  *) fail "unsupported processor $arch." ;;
esac
# A shell under Rosetta reports x86_64 on Apple silicon: take the native binary.
if [ "$os" = darwin ] && [ "$arch" = x64 ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
  arch=arm64
fi
asset="kennra-$os-$arch"

if [ -n "${KENNRA_VERSION:-}" ]; then
  base="https://github.com/$REPO/releases/download/v${KENNRA_VERSION#v}"
else
  base="https://github.com/$REPO/releases/latest/download"
fi

if [ -n "${KENNRA_INSTALL_DIR:-}" ]; then
  dir="$KENNRA_INSTALL_DIR"
elif [ -w /usr/local/bin ]; then
  dir=/usr/local/bin
else
  dir="$HOME/.local/bin"
fi
mkdir -p "$dir"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

printf 'Downloading %s …\n' "$asset"
curl -fsSL --retry 3 -o "$tmp/$asset" "$base/$asset" || fail "could not download $base/$asset"
curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$base/SHA256SUMS" || fail "could not download the checksums"

expected=$(awk -v f="$asset" '$2 == f || $2 == "*" f { print $1 }' "$tmp/SHA256SUMS")
[ -n "$expected" ] || fail "no checksum for $asset in this release"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp/$asset" | awk '{ print $1 }')
else
  actual=$(shasum -a 256 "$tmp/$asset" | awk '{ print $1 }')
fi
[ "$expected" = "$actual" ] || fail "checksum mismatch for $asset; nothing was installed"

chmod +x "$tmp/$asset"
mv "$tmp/$asset" "$dir/kennra"
printf 'Installed %s\n' "$("$dir/kennra" --version 2>/dev/null || echo kennra) in $dir/kennra"

case ":$PATH:" in
  *":$dir:"*) ;;
  *) printf '\n%s is not on your PATH. Add it, for example:\n  echo '\''export PATH="%s:$PATH"'\'' >> ~/.profile\n' "$dir" "$dir" ;;
esac
printf '\nNext: kennra login\n'
