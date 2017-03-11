#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER shamwow;
    CREATE DATABASE shamwow;
    GRANT ALL PRIVILEGES ON DATABASE shamwow TO shamwow;
EOSQL