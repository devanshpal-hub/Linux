update_system() {
    if [[ "$UPDATE_SYSTEM" != yes ]]; then
        log_info "System update and upgrade skipped by configuration."
        action_skipped "System update and upgrade"
        return 0
    fi

    action_start "System update and upgrade"
    log_info "Refreshing APT package indexes."
    apt-get update
    log_info "Upgrading installed packages."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    action_complete "System update and upgrade"
    log_info "System update completed."
}
