FROM ubuntu:24.04

# prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# install deps in one layer to keep image size down
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    sudo \
    gettext \
    && rm -rf /var/lib/apt/lists/*

# Add official postgreSQL apt repo
# To get latest PG
RUN apt-get update && apt-get install -y postgresql-common ca-certificates \
    && yes '' | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

RUN apt-get update && apt-get install -y \
    postgresql-18 \
    postgresql-client-18 \
    postgresql-server-dev-18 \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/patroni \
    && /opt/patroni/bin/pip install --upgrade pip \
    && /opt/patroni/bin/pip install \
        patroni[etcd3] \
        psycopg2-binary

# patroni[etcd3] means install patroni WITH etcd3 support
# psycopg2-binary is the Python PostgreSQL driver Patroni needs

ENV PATH="/opt/patroni/bin:$PATH"

# Create postgres user home directory
# Patroni runs as postgres user for security
RUN mkdir -p /data/patroni \
    && chown postgres:postgres /data/patroni \
    && chmod 700 /data/patroni

COPY post_bootstrap.sh /etc/patroni/post_bootstrap.sh
RUN chmod +x /etc/patroni/post_bootstrap.sh

COPY patroni.yml /etc/patroni.yml

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
# 5432 = PostgreSQL
# 8008 = Patroni REST API (this is what HAProxy health checks hit)
EXPOSE 5432 8008

# Run as postgres user, not root — security best practice
USER postgres

ENTRYPOINT ["/entrypoint.sh"]
