# Pinned by PHP version and digest; Renovate bumps both.
FROM serversideup/php:8.5.10-fpm-nginx@sha256:8f8c2f010ac5082ff3b42dbd1c2b2a77aa8a7ee0adb96d49920f32f45ae730e8

USER root
RUN install-php-extensions intl bcmath
# serversideup rewrites REMOTE_ADDR from CF-Connecting-IP. Behind a proxy
# (Caddy, a load balancer) that hides the proxy hop from Laravel, which then
# ignores X-Forwarded-Proto and generates http URLs. Emptied rather than
# deleted so an include by name cannot break the config; the application's
# trusted proxies resolve the client and scheme instead.
RUN echo '# real_ip shim removed - Laravel resolves proxies itself' \
    > /etc/nginx/server-opts.d/remoteip.conf
USER www-data

# TLS ends at the proxy, and /up is Laravel's health route.
ENV PHP_OPCACHE_ENABLE=1 \
    SSL_MODE=off \
    HEALTHCHECK_PATH=/up
