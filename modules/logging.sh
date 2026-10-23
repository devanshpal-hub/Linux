LOGGING_ENABLED=no
CURRENT_ACTION=""

log_init() {
    LOGGING_ENABLED="${ENABLE_LOGGING:-no}"
    if [[ "$LOGGING_ENABLED" == "yes" ]]; then
        local log_directory
        log_directory="$(dirname -- "$LOG_FILE")"
        if [[ ! -d "$log_directory" ]]; then
            install -d -m 0750 -- "$log_directory"
        fi
        touch -- "$LOG_FILE"
        chmod 0640 -- "$LOG_FILE"
    fi
}

audit_log() {
    [[ "$LOGGING_ENABLED" == "yes" ]] || return 0

    printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$1" "$2" >> "$LOG_FILE"
}

action_start() {
    CURRENT_ACTION="$1"
}

action_complete() {
    audit_log COMPLETE "$1"
    CURRENT_ACTION=""
}

action_skipped() {
    audit_log SKIPPED "$1"
}

log_installed_package_versions() {
    local package package_status package_version
    for package in "$@"; do
        if package_status="$(dpkg-query -W -f='${db:Status-Status}\t${Version}' -- "$package" 2>/dev/null)" &&
            [[ "$package_status" == installed$'\t'* ]]; then
            package_version="${package_status#*$'\t'}"
            audit_log PACKAGE "$package=$package_version"
        fi
    done
}

log_message() {
    local level="$1"
    shift
    local timestamp message
    timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"
    message="[$timestamp] [$level] $*"
    printf '%s\n' "$message"
}

log_info() {
    log_message INFO "$@"
}

log_error() {
    log_message ERROR "$@" >&2
}
