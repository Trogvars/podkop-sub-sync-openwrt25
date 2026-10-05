#!/bin/ash
set -e

REPO="Trogvars/podkop-sub-sync-openwrt25"
BRANCH="${PODKOP_SYNC_BRANCH:-main}"
TMP="$(mktemp -d /tmp/podkop-sub-sync-install.XXXXXX)" || exit 1
cleanup(){ rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
echo "[podkop-sub-sync] Downloading ${REPO}@${BRANCH}..."
wget -qO "$TMP/src.tar.gz" "$URL" || { echo "ERROR: failed to download $URL"; exit 1; }
tar -xzf "$TMP/src.tar.gz" -C "$TMP" || { echo "ERROR: failed to unpack source archive"; exit 1; }
INSTALLER="$(find "$TMP" -type f -name install-podkop-sub-sync.sh | head -n 1)"
[ -n "$INSTALLER" ] || { echo "ERROR: install-podkop-sub-sync.sh not found"; exit 1; }
chmod 755 "$INSTALLER"
exec "$INSTALLER" "$@"
