# laravel-php

[serversideup/php](https://serversideup.net/open-source/docker-php/) `fpm-nginx`,
set up for Laravel apps behind a proxy:

- `intl` and `bcmath` installed;
- `TRUSTED_PROXY=off`, so `REMOTE_ADDR` stays the proxy hop and Laravel's
  trusted proxies resolve the client and scheme;
- `PHP_OPCACHE_ENABLE=1`, `SSL_MODE=off` and `HEALTHCHECK_PATH=/up` as defaults.
  OPcache does not check for file changes, so a container with the code mounted
  as a volume needs `PHP_OPCACHE_VALIDATE_TIMESTAMPS=1` or a restart.

```dockerfile
FROM ghcr.io/robertboes/laravel-php:8.5.10@sha256:… AS base
```

Pin a version and digest and let Renovate or Dependabot bump them. `latest`
moves to the next PHP minor without a PR, so apps should not use it.

## Tags

The exact PHP version (`8.5.10`), the minor (`8.5`) and `latest`. The version is
read from the built image, so it is whatever serversideup ships, which can trail
php.net. No tag is immutable; pin the digest.

## Updates

The base image is pinned by version and digest in the `Dockerfile`. Renovate
opens a PR when serversideup publishes a new one; merging it to `main` publishes
this image. A new serversideup major fails the tests until it has an entry in
[CHANGELOG.md](CHANGELOG.md), which Renovate shows in apps' update PRs.

## Testing

```sh
docker build -t laravel-php:test .
tests/run.sh laravel-php:test
```
