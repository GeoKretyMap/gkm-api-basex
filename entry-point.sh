#!/bin/bash
set -eo pipefail

# if command starts with an option, prepend basexhttp
if [ "${1:0:1}" = '-' ]; then
	set -- basexhttp "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'basexhttp' -a "$1" "basexclient" -a "$(id -u)" = '0' ]; then
	chown -R basex. /srv/BaseXData /srv/BaseXRepo
	exec gosu basex "$BASH_SOURCE" "$@"
fi

exec "$@"
