#!/bin/bash
set -eo pipefail

# allow the container to be started with `--user`
if [ "$(id -u)" = '0' ]; then
	chown -R basex. /srv/BaseXData /srv/BaseXRepo
	gosu basex "$@"
fi

exec "$@"
