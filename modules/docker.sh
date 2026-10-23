docker_install() {
    local architecture codename
    codename="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"

    action_start "Docker Engine and Compose installation"
    log_info "Installing Docker Engine and Docker Compose."
    install -m 0755 -d /etc/apt/keyrings
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    architecture="$(dpkg --print-architecture)"
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu %s stable\n' \
        "$architecture" "$codename" \
        > /etc/apt/sources.list.d/docker.list

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    action_complete "Docker Engine and Compose installation"
    log_info "Docker Engine is installed and enabled."
}
