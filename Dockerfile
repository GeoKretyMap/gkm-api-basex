FROM basex/basexhttp:8.4.3

COPY conf/basex /srv/.basex
COPY BaseXRepo/ /srv/BaseXRepo/
COPY BaseXWeb/ /srv/BaseXWeb/
COPY entry-point.sh /usr/local/bin/

USER root
RUN chown -R basex /srv/BaseXRepo/ /srv/BaseXWeb/

USER basex
ENTRYPOINT /usr/local/bin/entry-point.sh
CMD basexhttp -z



# sample composer.yml
#
#  gkm-api-basex:
#    image: geokretymap/gkm-api-basex
#    volumes:
#      - /srv/GKM/basex/data/BaseXRepo/:/srv/BaseXRepo/
#
