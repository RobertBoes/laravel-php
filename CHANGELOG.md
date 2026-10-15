# Changelog

Tags follow the PHP version, not serversideup's, so a serversideup major can
arrive as a PHP patch. Those are listed here, and Renovate shows the entry in
the update PR.

## 8.5.11

Moves to [serversideup/php v5](https://github.com/serversideup/docker-php/releases/tag/v5.0.0)
on Debian trixie (was v4 on bookworm). Their
[migration guide](https://serversideup.net/open-source/docker-php/docs/guide/major-version-migrations)
has the full list. This image keeps v4's behaviour where an app would notice:
OPcache still checks for file changes (`PHP_OPCACHE_VALIDATE_TIMESTAMPS=1`) and
`REMOTE_ADDR` stays the proxy hop. The larger OPcache and realpath cache
defaults come along.

Nothing to change unless you extend the image:

- The real-IP shim is now `TRUSTED_PROXY`, set to `off` here, so nothing changes
  unless you overrode `/etc/nginx/server-opts.d/remoteip.conf`; set
  `TRUSTED_PROXY` instead.
- Extra s6 dependencies go in `/etc/s6-overlay/s6-rc.d/<service>/dependencies.d/`
  as empty files; the `dependencies` file is ignored.
- Packages you `apt-get install` come from trixie, where some names differ.
