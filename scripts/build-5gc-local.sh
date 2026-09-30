#!/usr/bin/env bash
set -euo pipefail

# Configure FreeRADIUS for the 5GC deployment layout without installing it.
# The caller can run `make` after this script, then use a separate staging
# directory for installation and service validation.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-/usr/local}"
SYSCONFDIR="${SYSCONFDIR:-${PREFIX}/etc}"
RADIUS_CONF_DIR="${RADIUS_CONF_DIR:-${SYSCONFDIR}/freeradius}"
RADIUS_DICT_DIR="${RADIUS_DICT_DIR:-${PREFIX}/share/freeradius/dictionary}"
RADIUS_LOG_DIR="${RADIUS_LOG_DIR:-/var/log/freeradius}"

cd "${ROOT_DIR}"

./configure \
  --prefix="${PREFIX}" \
  --sysconfdir="${SYSCONFDIR}" \
  --with-raddbdir="${RADIUS_CONF_DIR}" \
  --with-dictdir="${RADIUS_DICT_DIR}" \
  --with-logdir="${RADIUS_LOG_DIR}" \
  --with-systemd \
  --with-rlm_eap_md5
