# geokretymap-basex

# Docker compose

The full GeoKretyMap stack could be launched using this `docker-compose.yml`

```
  gkm-api-basex:
    image: geokretymap/gkm-api-basex
    container_name: gkm-api-basex
    volumes:
      - /srv/GKM/basex/data/BaseXData/:/srv/BaseXData/
    environment:
      - BASEX_JVM=-Xmx3072m
    restart: always
    network_mode: bridge

  gkm-website:
    image: geokretymap/gkm-website
    container_name: gkm-website
    volumes:
      - /tmp/geokretymap.org
    network_mode: bridge

  gkm-api-nginx:
    container_name: gkm-api-nginx
    image: geokretymap/gkm-api-nginx
    links:
      - gkm-api-basex:database
    environment:
      - VIRTUAL_HOST=api.gkm.kumy.org,gkm.kumy.org
      - LETSENCRYPT_HOST=api.gkm.kumy.org,gkm.kumy.org
      - LETSENCRYPT_EMAIL=e@mail.com
    volumes:
      - /srv/GKM/basex/data/BaseXData/:/var/www/html/basex/
    volumes_from:
      - gkm-website
    restart: always
    network_mode: bridge

  gkm-api-cron:
    container_name: gkm-api-cron
    image: geokretymap/gkm-api-cron
    restart: unless-stopped
    network_mode: bridge
```


Here are the companions:

```
version: '2'
services:
  reverseproxy:
    container_name: nginx
    image: nginx:alpine
    ports:
      - 80:80
      - 443:443
    volumes:
      - /etc/nginx/conf.d
      - /etc/nginx/vhost.d
      - /usr/share/nginx/html
      - /srv/NGINX/certs:/etc/nginx/certs:ro
      - /srv/NGINX/htpasswd:/etc/nginx/htpasswd:ro
    restart: always
    network_mode: bridge

  reverseproxy-config:
    container_name: nginx-gen
    image: jwilder/docker-gen
    volumes_from:
      - reverseproxy
    volumes:
      - /srv/NGINX/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
    command: -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    restart: always
    network_mode: bridge

  reverseproxy-config-ssl:
    container_name: nginx-gen-ssl
    image: jrcs/letsencrypt-nginx-proxy-companion
    volumes_from:
      - reverseproxy
    volumes:
      - /srv/NGINX/certs:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - NGINX_DOCKER_GEN_CONTAINER=nginx-gen
    restart: always
    network_mode: bridge

```
