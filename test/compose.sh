#!/usr/bin/env bash_unit
# shellcheck shell=bash

suite="mariadb-test-compose"

IMAGE_VERSION=${IMAGE_VERSION:-latest}
CLIENT="docker run --network compose-secret_${suite} --rm jbergstroem/mariadb-client-alpine:latest"

setup_suite() {
  cd fixtures/compose-secret || exit 1
  VERSION="${IMAGE_VERSION}" docker compose up -d --no-build --no-log-prefix 2>/dev/null
  until docker logs --tail 1 "${suite}" 2>&1 | grep -q "Version:"; do
    sleep 0.2
  done
}

teardown_suite() {
  docker compose down -v 2>/dev/null
}

test_root_password_secret() {
  assert "${CLIENT} -h ${suite} --connect-timeout=5 --user=root --password=secret -e 'select 1;'"
}

test_user_password_secret_override() {
  assert "${CLIENT} -h ${suite} --connect-timeout=5 --user=foo --database=db --password=override -e 'select 1;'"
  assert_fail "${CLIENT} -h ${suite} --connect-timeout=5 --user=foo --database=db --password=password -e 'select 1;'"
}