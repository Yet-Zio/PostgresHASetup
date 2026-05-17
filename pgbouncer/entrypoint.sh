#!/bin/sh
set -e

export PGPASSWORD="${POSTGRES_PASSWORD}"

echo "Waiting for PostgreSQL on haproxy:${HAPROXY_PORT}..."
until psql -h haproxy -p "${HAPROXY_PORT}" -U postgres -d postgres -c "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done
unset PGPASSWORD

# Write plaintext password for pgbouncer_auth
# Can't use SCRAM verifier here — PgBouncer needs plaintext
# to authenticate itself outbound to Postgres for auth_query
printf '"pgbouncer_auth" "%s"\n' "${PGBOUNCER_AUTH_PASSWORD}" > /etc/pgbouncer/userlist.txt

sed -i "s/__HAPROXY_PORT__/${HAPROXY_PORT}/g" /etc/pgbouncer/pgbouncer.ini
echo "Starting PgBouncer → haproxy:${HAPROXY_PORT}"
exec pgbouncer /etc/pgbouncer/pgbouncer.ini -u pgbouncer
