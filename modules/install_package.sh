installing() {
    local index
    local -a packages=()

    IFS=',' read -r -a packages <<< "$PACKAGES"
    for index in "${!packages[@]}"; do
        packages[$index]="${packages[$index]//[[:space:]]/}"
    done

    if [[ "$UPDATE_SYSTEM" != yes ]]; then
        log_info "Refreshing APT package indexes before package installation."
        apt-get update
    fi

    log_info "Installing configured packages: ${packages[*]}."
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"

    if [[ "$DOCKER_INSTALL" == yes ]]; then
        docker_install
    else
        log_info "Docker installation skipped by configuration."
    fi
}
