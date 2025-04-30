#!/bin/bash
# shellcheck source=/dev/null

ROCKS_DIR="$(dirname "$0")"

luarocks install moonscript --tree "$ROCKS_DIR"
luarocks install busted --tree "$ROCKS_DIR"
