#!/usr/bin/env bash
set -e

echo "Running post_bootstrap..."
echo "Connecting to: $1"

psql "$1" --set ON_ERROR_STOP=on <<SQL
  \echo 'Creating replicator...'
  CREATE USER replicator WITH PASSWORD '${REPLICATOR_PASSWORD}' REPLICATION;

  \echo 'Creating rewind_user...'
  CREATE USER rewind_user WITH PASSWORD '${REWIND_PASSWORD}';
  GRANT EXECUTE ON function pg_catalog.pg_ls_dir(text, boolean, boolean) TO rewind_user;
  GRANT EXECUTE ON function pg_catalog.pg_stat_file(text, boolean) TO rewind_user;
  GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text) TO rewind_user;
  GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text, bigint, bigint, boolean) TO rewind_user;

  \echo 'Creating pgbouncer_auth...'
  CREATE USER pgbouncer_auth WITH PASSWORD '${PGBOUNCER_AUTH_PASSWORD}';

  \echo 'Creating pgbouncer schema...'
  CREATE SCHEMA IF NOT EXISTS pgbouncer;

  \echo 'Granting usage on schema...'
  GRANT USAGE ON SCHEMA pgbouncer TO pgbouncer_auth;

  \echo 'Creating user_lookup function...'
  CREATE OR REPLACE FUNCTION pgbouncer.user_lookup(
    IN i_username text,
    OUT usename text,
    OUT passwd text
  )
  RETURNS record AS \$\$
  BEGIN
    SELECT rolname, rolpassword
    INTO usename, passwd
    FROM pg_authid
    WHERE rolname = i_username AND rolcanlogin = true;
  END;
  \$\$ LANGUAGE plpgsql SECURITY DEFINER
  SET search_path = pg_catalog, pg_temp;

  \echo 'Revoking public function access...'
  REVOKE ALL ON FUNCTION pgbouncer.user_lookup(text) FROM public;

  \echo 'Granting function execute...'
  GRANT EXECUTE ON FUNCTION pgbouncer.user_lookup(text) TO pgbouncer_auth;

  \echo 'Creating appdb...'
  CREATE DATABASE appdb;

  \echo 'Creating appuser...'
  CREATE USER appuser WITH PASSWORD '${APP_PASSWORD}';
  GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;

  \echo 'All done!'
SQL

echo "post_bootstrap completed successfully"
