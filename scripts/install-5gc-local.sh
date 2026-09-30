#!/usr/bin/env bash
set -euo pipefail

# Install the already-configured build into a staging root.  This keeps the
# package layout identical to the final /usr/local deployment without touching
# the running host service.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTDIR="${DESTDIR:-${ROOT_DIR}/build/stage}"
PREFIX="${PREFIX:-/usr/local}"

cd "${ROOT_DIR}"

if [[ "${PREFIX}" != "/usr/local" ]]; then
	printf 'PREFIX must be /usr/local for the 5GC layout (got %s)\n' "${PREFIX}" >&2
	exit 2
fi

make install R="${DESTDIR}"

install -d -m 0755 "${DESTDIR}/usr/local/etc/freeradius"
install -d -m 0755 "${DESTDIR}/var/log/freeradius"
install -d -m 0755 "${DESTDIR}/lib/systemd/system"
install -m 0644 "${ROOT_DIR}/deploy/systemd/freeradius.service" \
	"${DESTDIR}/lib/systemd/system/freeradius.service"

printf 'Staged FreeRADIUS 5GC installation: %s\n' "${DESTDIR}"
