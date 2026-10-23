LOGGING_ENABLED=no

log_init() {
    LOGGING_ENABLED="${ENABLE_LOGGING:-no}"
    if [[ "$LOGGING_ENABLED" == "yes" ]]; then
        local log_directory
        log_directory="$(dirname -- "$LOG_FILE")"
        install -d -m 0750 -- "$log_directory"
        touch -- "$LOG_FILE"
        chmod 0640 -- "$LOG_FILE"
        exec > >(tee -a -- "$LOG_FILE") 2>&1
    fi
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
