#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if (( EUID != 0 )); then
    printf 'Error: run this script as root, for example with sudo.\n' >&2
    exit 1
fi

if [[ ! -r "$SCRIPT_DIR/config.conf" ]]; then
    printf 'Error: configuration file not found: %s/config.conf\n' "$SCRIPT_DIR" >&2
    exit 1
fi

source "$SCRIPT_DIR/config.conf"

modules=(
    logging.sh
    validation.sh
    update.sh
    install_package.sh
    docker.sh
    users.sh
    firewall.sh
)

for module in "${modules[@]}"; do
    module_path="$SCRIPT_DIR/modules/$module"
    if [[ ! -r "$module_path" ]]; then
        printf 'Error: required module not found: %s\n' "$module_path" >&2
        exit 1
    fi
    source "$module_path"
done

on_error() {
    local status="$1"
    local line="$2"
    trap - ERR
    if [[ -n "$CURRENT_ACTION" ]]; then
        audit_log FAILED "$CURRENT_ACTION (exit status $status)"
    fi
    audit_log FAILED "Provisioning (setup.sh line $line, exit status $status)"
    log_error "Provisioning failed at setup.sh line ${line} (exit status ${status})." || \
        printf 'Provisioning failed at setup.sh line %s (exit status %s).\n' "$line" "$status" >&2
    exit "$status"
}
trap 'on_error "$?" "$LINENO"' ERR

log_init
action_start "Configuration validation"
validation

action_complete "Configuration validation"
log_info "Starting Linux server provisioning."
update_system
installing
configure_user
configure_firewall
audit_log COMPLETE "Provisioning"
log_info "Server provisioning completed successfully."
