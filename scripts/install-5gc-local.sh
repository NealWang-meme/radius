#!/usr/bin/env bash
set -euo pipefail

# Install the already-configured build into a staging root.  This keeps the
# package layout identical to the final /usr/local deployment without touching
# the running host service.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTDIR="${DESTDIR:-${ROOT_DIR}/build/stage}"
PREFIX="${PREFIX:-/usr/local}"
RADIUS_SHARED_SECRET="${RADIUS_SHARED_SECRET:?set RADIUS_SHARED_SECRET for the SMF client}"
RADIUS_TEST_PASSWORD="${RADIUS_TEST_PASSWORD:?set RADIUS_TEST_PASSWORD for the test identity}"

cd "${ROOT_DIR}"

if [[ "${PREFIX}" != "/usr/local" ]]; then
	printf 'PREFIX must be /usr/local for the 5GC layout (got %s)\n' "${PREFIX}" >&2
	exit 2
fi

case "${RADIUS_SHARED_SECRET}${RADIUS_TEST_PASSWORD}" in
	*['|&\\']*)
		printf 'Credential values contain unsupported template characters\n' >&2
		exit 2
		;;
esac

make install R="${DESTDIR}"

install -d -m 0755 "${DESTDIR}/usr/local/etc/freeradius"
install -d -m 0755 "${DESTDIR}/var/log/freeradius"
install -d -m 0755 "${DESTDIR}/lib/systemd/system"

sed \
	-e "s|@RADIUS_SHARED_SECRET@|${RADIUS_SHARED_SECRET}|g" \
	"${ROOT_DIR}/deploy/5gc/freeradius/clients.conf.in" \
	> "${DESTDIR}/usr/local/etc/freeradius/clients.conf"
sed \
	-e "s|@RADIUS_TEST_PASSWORD@|${RADIUS_TEST_PASSWORD}|g" \
	"${ROOT_DIR}/deploy/5gc/freeradius/authorize.in" \
	> "${DESTDIR}/usr/local/etc/freeradius/mods-config/files/authorize"

chmod 0640 "${DESTDIR}/usr/local/etc/freeradius/clients.conf" \
    "${DESTDIR}/usr/local/etc/freeradius/mods-config/files/authorize"

# FreeRADIUS instantiates the bundled PEAP/TLS modules during configuration
# loading, so provide their local test certificates even when the 5GC flow
# uses EAP-MD5.  The generated private keys stay in the deployment root.
make -C "${DESTDIR}/usr/local/etc/freeradius/certs" all

install -m 0644 "${ROOT_DIR}/deploy/systemd/freeradius.service" \
	"${DESTDIR}/lib/systemd/system/freeradius.service"

printf 'Staged FreeRADIUS 5GC installation: %s\n' "${DESTDIR}"
