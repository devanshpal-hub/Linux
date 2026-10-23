configure_user() {
    local group
    local -a groups=() groups_from_config=()

    if [[ "$NEW_USER" != yes ]]; then
        log_info "User creation and permission configuration skipped by configuration."
        return 0
    fi

    if ! id "$NEW_USERNAME" >/dev/null 2>&1; then
        log_info "Creating user $NEW_USERNAME."
        useradd --create-home --shell /bin/bash -- "$NEW_USERNAME"
    else
        log_info "User $NEW_USERNAME already exists; preserving its account settings."
    fi

    if [[ "$NEW_USER_SUDO" == yes ]]; then
        groups+=(sudo)
    fi
    if [[ "$NEW_USER_DOCKER_ACCESS" == yes ]]; then
        groups+=(docker)
    fi
    if [[ -n "$NEW_USER_GROUPS" ]]; then
        IFS=',' read -r -a groups_from_config <<< "$NEW_USER_GROUPS"
        for group in "${groups_from_config[@]}"; do
            groups+=("${group//[[:space:]]/}")
        done
    fi

    for group in "${groups[@]}"; do
        if ! getent group "$group" >/dev/null; then
            log_error "Cannot add $NEW_USERNAME to '$group': the group does not exist."
            return 1
        fi
        usermod --append --groups "$group" -- "$NEW_USERNAME"
        log_info "Added $NEW_USERNAME to group $group."
    done
}
