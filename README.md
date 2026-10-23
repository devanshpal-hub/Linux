# Linux Server Automation Toolkit

A configuration-driven Bash toolkit for provisioning an Ubuntu Server. It can
update the system, install common utilities and Docker Engine with the Docker
Compose plugin, create a user, configure UFW, and keep a timestamped log.

## Requirements

- Ubuntu Server with `apt-get` and systemd
- Bash, an internet connection, and root privileges
- A non-root account with `sudo` for launching the toolkit

The toolkit makes system-wide changes. Review the configuration before running
it, and test it in a virtual machine before using it on a production server.

## Configure

Edit [config.conf](./config.conf). Every `yes`/`no` option is lowercase.

| Setting | Purpose |
| --- | --- |
| `DOCKER_INSTALL` | Install Docker Engine, CLI, Buildx, and Compose plugin |
| `UPDATE_SYSTEM` | Refresh APT indexes and upgrade installed packages |
| `ENABLE_FIREWALL` | Install and enable UFW with the configured allow rules |
| `ENABLE_LOGGING` | Write a timestamped run log to `LOG_FILE` |
| `NEW_USER` | Create or configure the account named by `NEW_USERNAME` |
| `NEW_USERNAME` | Account to create when `NEW_USER=yes` |
| `NEW_USER_SUDO` | Add that account to the `sudo` group |
| `NEW_USER_DOCKER_ACCESS` | Add that account to the `docker` group |
| `NEW_USER_GROUPS` | Additional existing groups, comma-separated |
| `FIREWALL_SSH_PORT` | TCP port to allow for SSH before enabling UFW |
| `FIREWALL_ALLOWED_PORTS` | Additional ports to allow, comma-separated |
| `PACKAGES` | APT packages to install, comma-separated |
| `LOG_FILE` | Log file path when logging is enabled |

New accounts are created without a password. Configure their password or SSH
keys separately. Membership in `sudo` grants administrative privileges.
Membership in the `docker` group is effectively root-equivalent; enable it only
for users you trust. When enabling UFW remotely, set `FIREWALL_SSH_PORT` to the
server's actual SSH port. The default allow rules are TCP 22, 80, and 443.

## Run

From this directory:

```bash
sudo ./setup.sh
```

The runner resolves modules relative to its own location, so it can also be
invoked by absolute path from another working directory. The provisioning order
is: configuration validation, optional system upgrade, package and Docker
installation, optional user configuration, and optional firewall setup.

When logging is enabled, the default log is
`/var/log/linux-server-automation.log`. Command failures stop the run, are
reported, and are written to the log when logging is enabled.
