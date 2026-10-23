# Pinned by PHP version and digest; Renovate bumps both.
FROM serversideup/php:8.5.12-fpm-nginx@sha256:385934673d575b9e41bca6d6341e4888670e1e81550a826c998b50748adc3d46

USER root
RUN install-php-extensions intl bcmath
USER www-data

# TLS ends at the proxy, and /up is Laravel's health route. TRUSTED_PROXY
# defaults to cloudflare, which rewrites REMOTE_ADDR from CF-Connecting-IP.
# Behind a proxy (Caddy, a load balancer) that hides the proxy hop from
# Laravel, which then ignores X-Forwarded-Proto and generates http URLs; the
# application's trusted proxies resolve the client and scheme instead.
# OPcache keeps checking for file changes, as before serversideup v5, so a
# mounted volume still picks up edits; production can set it to 0.
ENV PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=1 \
    SSL_MODE=off \
    HEALTHCHECK_PATH=/up \
    TRUSTED_PROXY=off
