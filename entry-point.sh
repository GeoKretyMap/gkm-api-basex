#!/bin/bash -x 
#set -eo pipefail

# allow the container to be started with `--user`
if [ "$1" = 'basexhttp' -a "$1" = "basexclient" -a "$(id -u)" = '0' ]; then
	chown -R basex. /srv/BaseXData /srv/BaseXRepo
	gosu basex "$@"
fi

exec "$@"
