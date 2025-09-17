# syntax=docker/dockerfile:1
FROM ghcr.io/tenstorrent/tt-metal/tt-metalium-ubuntu-22.04-release-amd64:latest-rc

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        mc \
        htop \
        sudo \
        gosu \
        ca-certificates \
        curl \
        git \
        vim \
        less \
        locales && \
    rm -rf /var/lib/apt/lists/*

# Configure UTF-8 locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Passwordless sudo for members of group sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/010-sudo-nopasswd && \
    chmod 0440 /etc/sudoers.d/010-sudo-nopasswd

WORKDIR /workspace

# Entrypoint for dynamic host user mapping
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]


