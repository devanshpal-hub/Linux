update_system() {
    if [[ "$UPDATE_SYSTEM" != yes ]]; then
        log_info "System update and upgrade skipped by configuration."
        return 0
    fi

    log_info "Refreshing APT package indexes."
    apt-get update
    log_info "Upgrading installed packages."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    log_info "System update completed."
}
