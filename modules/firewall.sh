configure_firewall() {
    local rule
    local -a firewall_rules=()

    if [[ "$ENABLE_FIREWALL" != yes ]]; then
        log_info "Firewall configuration skipped by configuration."
        action_skipped "Firewall configuration"
        return 0
    fi

    action_start "Firewall configuration"
    if ! command -v ufw >/dev/null 2>&1; then
        log_info "Installing UFW."
        DEBIAN_FRONTEND=noninteractive apt-get install -y ufw
        log_installed_package_versions ufw
    fi

    log_info "Configuring UFW; allowing SSH on TCP port $FIREWALL_SSH_PORT."
    ufw allow "${FIREWALL_SSH_PORT}/tcp"

    if [[ -n "$FIREWALL_ALLOWED_PORTS" ]]; then
        IFS=',' read -r -a firewall_rules <<< "$FIREWALL_ALLOWED_PORTS"
        for rule in "${firewall_rules[@]}"; do
            rule="${rule//[[:space:]]/}"
            ufw allow "$rule"
        done
    fi

    ufw default deny incoming
    ufw default allow outgoing
    ufw --force enable
    ufw status verbose
    action_complete "Firewall configuration"
    log_info "UFW is enabled."
}
