FROM alpine:3.20

RUN apk add --no-cache pgbouncer postgresql-client

RUN addgroup -S pgbouncer && adduser -S -G pgbouncer pgbouncer

RUN mkdir -p /var/run/pgbouncer /var/log/pgbouncer \
    && chown -R pgbouncer:pgbouncer /var/run/pgbouncer /var/log/pgbouncer

WORKDIR /etc/pgbouncer
COPY pgbouncer.ini /etc/pgbouncer/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown -R pgbouncer:pgbouncer /etc/pgbouncer

USER pgbouncer
EXPOSE 6432

ENTRYPOINT ["/entrypoint.sh"]
