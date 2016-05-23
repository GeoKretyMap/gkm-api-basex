FROM basex/basexhttp:8.4.3

ADD conf/basex /srv/.basex
ADD BaseXRepo/ /srv/BaseXRepo/
ADD BaseXWeb/ /srv/BaseXWeb/

USER root
RUN chown -R basex /srv/BaseXRepo/ /srv/BaseXWeb/
USER basex

CMD /usr/local/bin/basexhttp -z



# sample composer.yml
#
#  gkm-api-basex:
#    image: geokretymap/gkm-api-basex
#    volumes:
#      - /srv/GKM/basex/data/BaseXRepo/:/srv/BaseXRepo/
#
