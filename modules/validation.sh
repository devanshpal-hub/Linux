validation_error() {
    log_error "$1"
    return 1
}

validation() {
    local name value rule package group
    local -a firewall_rules=() configured_packages=() configured_groups=()

    if [[ ! -r /etc/os-release ]]; then
        validation_error "Cannot determine the operating system; /etc/os-release is unavailable."
        return 1
    fi
    source /etc/os-release

    for name in DOCKER_INSTALL UPDATE_SYSTEM ENABLE_FIREWALL ENABLE_LOGGING \
        NEW_USER NEW_USER_SUDO NEW_USER_DOCKER_ACCESS; do
        if [[ ! -v $name ]]; then
            validation_error "Required configuration value $name is missing."
            return 1
        fi
        value="${!name}"
        if [[ "$value" != yes && "$value" != no ]]; then
            validation_error "$name must be lowercase yes or no; received '$value'."
            return 1
        fi
    done

    if [[ "$NEW_USER" == no && ( "$NEW_USER_SUDO" == yes || "$NEW_USER_DOCKER_ACCESS" == yes || -n "${NEW_USER_GROUPS:-}" ) ]]; then
        validation_error "User groups and permissions require NEW_USER=yes."
        return 1
    fi
    if [[ "$NEW_USER" == yes && ! "${NEW_USERNAME:-}" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        validation_error "Set NEW_USERNAME to a valid Linux account name when NEW_USER=yes."
        return 1
    fi
    if [[ "$NEW_USER" == no && -n "${NEW_USERNAME:-}" ]]; then
        validation_error "Clear NEW_USERNAME or set NEW_USER=yes."
        return 1
    fi

    if [[ ! "${FIREWALL_SSH_PORT:-}" =~ ^[0-9]{1,5}$ ]] ||
        (( 10#$FIREWALL_SSH_PORT < 1 || 10#$FIREWALL_SSH_PORT > 65535 )); then
        validation_error "FIREWALL_SSH_PORT must be a TCP port between 1 and 65535."
        return 1
    fi

    if [[ -z "${PACKAGES:-}" ]]; then
        validation_error "PACKAGES must contain at least one APT package name."
        return 1
    fi
    IFS=',' read -r -a configured_packages <<< "$PACKAGES"
    for package in "${configured_packages[@]}"; do
        package="${package//[[:space:]]/}"
        if [[ ! "$package" =~ ^[a-z0-9][a-z0-9+.-]*$ ]]; then
            validation_error "Invalid APT package name in PACKAGES: '$package'."
            return 1
        fi
    done

    if [[ -n "${NEW_USER_GROUPS:-}" ]]; then
        IFS=',' read -r -a configured_groups <<< "$NEW_USER_GROUPS"
        for group in "${configured_groups[@]}"; do
            group="${group//[[:space:]]/}"
            if [[ ! "$group" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
                validation_error "Invalid Linux group name in NEW_USER_GROUPS: '$group'."
                return 1
            fi
        done
    fi

    if [[ -n "${FIREWALL_ALLOWED_PORTS:-}" ]]; then
        IFS=',' read -r -a firewall_rules <<< "$FIREWALL_ALLOWED_PORTS"
        for rule in "${firewall_rules[@]}"; do
            rule="${rule//[[:space:]]/}"
            if [[ ! "$rule" =~ ^[0-9]{1,5}(/(tcp|udp))?$ ]]; then
                validation_error "Invalid firewall rule '$rule'; use a port optionally followed by /tcp or /udp."
                return 1
            fi
            value="${rule%%/*}"
            if (( 10#$value < 1 || 10#$value > 65535 )); then
                validation_error "Firewall port in '$rule' must be between 1 and 65535."
                return 1
            fi
        done
    fi

    if [[ ! -v LOG_FILE || -z "$LOG_FILE" ]]; then
        validation_error "LOG_FILE must be set to a file path."
        return 1
    fi

    if [[ "$ID" != ubuntu ]]; then
        validation_error "This toolkit supports Ubuntu only; detected '${ID:-unknown}'."
        return 1
    fi
    if [[ "$DOCKER_INSTALL" == yes && -z "${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}" ]]; then
        validation_error "Ubuntu release codename is unavailable; Docker repository cannot be configured."
        return 1
    fi
    if ! command -v apt-get >/dev/null 2>&1 || ! command -v systemctl >/dev/null 2>&1; then
        validation_error "Required commands apt-get and systemctl must be available."
        return 1
    fi

    log_info "Configuration validated."
}
