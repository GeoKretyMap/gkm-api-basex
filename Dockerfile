FROM basex/basexhttp:8.4.3

USER root

RUN curl -o /usr/local/bin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
    && chmod +x /usr/local/bin/gosu

# Install application
COPY conf/basex /srv/.basex
COPY BaseXRepo/ /srv/BaseXRepo/
COPY BaseXWeb/ /srv/BaseXWeb/
RUN chown -R basex /srv/BaseXRepo/ /srv/BaseXWeb/

COPY entry-point.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entry-point.sh"]
CMD ["basexhttp", "-z"]



# sample composer.yml
#
#  gkm-api-basex:
#    image: geokretymap/gkm-api-basex
#    volumes:
#      - /srv/GKM/basex/data/BaseXRepo/:/srv/BaseXRepo/
#
