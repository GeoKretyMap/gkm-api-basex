FROM basex/basexhttp:9.1.2

USER root

RUN apk add vim \
    && curl -o /usr/local/bin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu

# Install application
COPY --chown=basex:basex conf/basex /srv/.basex
COPY --chown=basex:basex BaseXRepo/ /srv/BaseXRepo/
COPY --chown=basex:basex BaseXWeb/ /srv/BaseXWeb/

COPY scripts/ /srv/scripts/
COPY entry-point.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entry-point.sh"]
CMD ["basexserver", "-z"]
