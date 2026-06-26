#!/usr/bin/env bash
# Installs / updates the Dynamic Island plasmoid into the user's Plasma widgets.
set -euo pipefail

ID="com.ifny75.dynamicisland"
SRC="$(cd "$(dirname "$0")" && pwd)/package"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids/$ID"

if [[ ! -f "$SRC/metadata.json" ]]; then
    echo "error: $SRC/metadata.json not found" >&2
    exit 1
fi

echo "Installing $ID -> $DEST"
mkdir -p "$DEST"
rm -rf "${DEST:?}/contents"
cp -rf "$SRC/contents" "$SRC/metadata.json" "$DEST/"

# Refresh Plasma's service cache so the new version/config is detected.
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true

echo "Done."
echo "Reload Plasma to apply:  kquitapp6 plasmashell && kstart plasmashell"
echo "Or test standalone:      plasmawindowed $ID"
