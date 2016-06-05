#!/bin/bash
set -eo pipefail

# allow the container to be started with `--user`
if [ "$(id -u)" = '0' ]; then
   [ ! -d /srv/BaseXData/export/gkdetails ] && mkdir -p /srv/BaseXData/export/gkdetails
   chown basex. /srv/BaseXData /srv/BaseXRepo /srv/BaseXData/export /srv/BaseXData/export/gkdetails
   gosu basex "$@"
fi

exec "$@"
