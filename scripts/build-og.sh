#!/usr/bin/env bash
# Regenerate the OG card PNG from public/og-default.svg.
#
# Renders at 1200x630 (the OpenGraph spec minimum) using Inkscape, with
# rsvg-convert as a fallback. The SVG references Bebas Neue and IBM Plex
# Sans; this script auto-installs them from public/fonts/ into ~/.fonts if
# fontconfig can't find them, so the script is self-bootstrapping on a
# fresh machine.
#
# Usage:
#   scripts/build-og.sh                 # default paths
#   OG_SVG=path/in.svg OG_PNG=out.png scripts/build-og.sh
#
# Hooked from package.json as `npm run og`.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OG_SVG="${OG_SVG:-$REPO_ROOT/public/og-default.svg}"
OG_PNG="${OG_PNG:-$REPO_ROOT/public/og-default.png}"
OG_W="${OG_W:-1200}"
OG_H="${OG_H:-630}"

log() { printf '\033[1;34m[og]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[og]\033[0m %s\n' "$*" >&2; }

# --- Sanity checks ---------------------------------------------------------

if [[ ! -f "$OG_SVG" ]]; then
  err "source SVG not found: $OG_SVG"
  exit 1
fi

# --- Fonts -----------------------------------------------------------------
# The SVG embeds font-family names. fontconfig must resolve them or
# Inkscape silently falls back to a default and the layout breaks.
ensure_fonts() {
  # Check local ~/.fonts/ first (fast, no fc-list cache dependency).
  # Fall back to fontconfig only when the file isn't present locally.
  local needed=("BebasNeue-Regular.ttf" "IBMPlexSans-SemiBold.ttf")
  local missing=()
  local font
  for font in "${needed[@]}"; do
    if [[ -f "$HOME/.fonts/$font" ]]; then
      continue
    fi
    case "$font" in
      BebasNeue-Regular.ttf)
        fc-list 2>/dev/null | grep -qi 'bebas neue' && continue ;;
      IBMPlexSans-SemiBold.ttf)
        fc-list 2>/dev/null | grep -qi 'plex sans.*semibold' && continue ;;
    esac
    missing+=("$font")
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi

  log "installing missing fonts to ~/.fonts: ${missing[*]}"
  mkdir -p "$HOME/.fonts"
  for font in "${missing[@]}"; do
    if [[ -f "$REPO_ROOT/public/fonts/$font" ]]; then
      cp "$REPO_ROOT/public/fonts/$font" "$HOME/.fonts/"
    else
      err "font missing from public/fonts/: $font (cannot bootstrap)"
      exit 1
    fi
  done
  fc-cache -f >/dev/null 2>&1 || true
}

# --- Renderer --------------------------------------------------------------

render_with_inkscape() {
  log "rendering with inkscape: $OG_SVG -> $OG_PNG (${OG_W}x${OG_H})"
  inkscape "$OG_SVG" \
    --export-type=png \
    --export-filename="$OG_PNG" \
    --export-width="$OG_W" \
    --export-height="$OG_H" \
    >/dev/null
}

render_with_rsvg() {
  log "rendering with rsvg-convert: $OG_SVG -> $OG_PNG (${OG_W}x${OG_H})"
  rsvg-convert -w "$OG_W" -h "$OG_H" -o "$OG_PNG" "$OG_SVG"
}

if command -v inkscape >/dev/null 2>&1; then
  ensure_fonts
  render_with_inkscape
elif command -v rsvg-convert >/dev/null 2>&1; then
  ensure_fonts
  render_with_rsvg
else
  # No renderer on this host (typical CI / Cloudflare Pages build). The
  # committed PNG at $OG_PNG is the deploy artifact; this hook is a
  # local-dev convenience to keep the PNG in sync with the SVG source.
  # Skip cleanly so `npm run build` succeeds in CI.
  log "skip: no renderer available (inkscape / rsvg-convert), using committed $OG_PNG"
  if [[ -f "$OG_PNG" ]]; then
    exit 0
  fi
  err "no renderer AND no committed PNG at $OG_PNG -- cannot continue"
  err "install with: sudo apt-get install -y inkscape  # or  librsvg2-bin"
  exit 1
fi

# --- Verify ----------------------------------------------------------------

if [[ ! -s "$OG_PNG" ]]; then
  err "render produced empty output: $OG_PNG"
  exit 1
fi

# Verify dimensions if `file` is available (cheap sanity check).
if command -v file >/dev/null 2>&1; then
  dims=$(file "$OG_PNG" | grep -oE '[0-9]+ x [0-9]+' | head -1)
  if [[ -n "$dims" && "$dims" != "$OG_W x $OG_H" ]]; then
    err "unexpected output dimensions: $dims (wanted $OG_W x $OG_H)"
    exit 1
  fi
fi

size_bytes=$(stat -c%s "$OG_PNG" 2>/dev/null || stat -f%z "$OG_PNG" 2>/dev/null || echo 0)
log "ok ($(printf '%d' "$size_bytes") bytes)"
