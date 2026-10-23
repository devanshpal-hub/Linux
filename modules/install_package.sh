installing() {
    local index
    local -a packages=()

    IFS=',' read -r -a packages <<< "$PACKAGES"
    for index in "${!packages[@]}"; do
        packages[$index]="${packages[$index]//[[:space:]]/}"
    done

    action_start "Configured package installation"
    if [[ "$UPDATE_SYSTEM" != yes ]]; then
        log_info "Refreshing APT package indexes before package installation."
        apt-get update
    fi

    log_info "Installing configured packages: ${packages[*]}."
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
    action_complete "Configured package installation"
    log_installed_package_versions "${packages[@]}"

    if [[ "$DOCKER_INSTALL" == yes ]]; then
        docker_install
        log_installed_package_versions ca-certificates curl \
            docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        log_info "Docker installation skipped by configuration."
        action_skipped "Docker installation"
    fi
}
