#!/usr/bin/env bash
# Tests a built image: tests/run.sh <image>
set -euo pipefail

image=${1:?usage: tests/run.sh <image>}
name=laravel-php-test-$$
app_dir=$(cd "$(dirname "$0")/app" && pwd)

fail() {
    echo "FAIL: $*" >&2
    docker logs "$name" >&2 || true
    exit 1
}

cleanup() {
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker network rm "$name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# A network of its own, so requests come from a private address. serversideup's
# shim trusts those, so it would rewrite REMOTE_ADDR if it were still active;
# a request from localhost inside the container would not show that.
docker network create "$name" >/dev/null
docker run -d --name "$name" --network "$name" \
    -v "$app_dir:/var/www/html:ro" "$image" >/dev/null

echo "Waiting for the healthcheck..."
for _ in $(seq 1 60); do
    status=$(docker inspect -f '{{.State.Health.Status}}' "$name")
    [ "$status" = healthy ] && break
    [ "$(docker inspect -f '{{.State.Running}}' "$name")" = true ] || fail "container exited"
    sleep 2
done
[ "$status" = healthy ] || fail "healthcheck is '$status', not healthy"
echo "ok: healthy"

fake_ip=203.0.113.7
remote_addr=$(docker run --rm --network "$name" --entrypoint curl "$image" \
    --silent --fail -H "CF-Connecting-IP: $fake_ip" "http://$name:8080/")
[ -n "$remote_addr" ] || fail "empty REMOTE_ADDR"
[ "$remote_addr" != "$fake_ip" ] || fail "REMOTE_ADDR was rewritten from CF-Connecting-IP"
echo "ok: CF-Connecting-IP ignored (REMOTE_ADDR=$remote_addr)"

modules=$(docker exec "$name" php -m)
for module in intl bcmath; do
    grep -qx "$module" <<< "$modules" || fail "PHP module $module missing"
done
echo "ok: intl and bcmath loaded"

for pair in PHP_OPCACHE_ENABLE=1 SSL_MODE=off HEALTHCHECK_PATH=/up; do
    actual=$(docker exec "$name" printenv "${pair%%=*}")
    [ "$actual" = "${pair#*=}" ] || fail "${pair%%=*} is '$actual', expected '${pair#*=}'"
done
echo "ok: env defaults set"
