# Pinned by PHP version and digest; Renovate bumps both.
FROM serversideup/php:8.5.11-fpm-nginx@sha256:081662b7f29b5d246062eeeffd7842bc385d7ffcb2a87ec0b20c469e2570f733

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
