FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="Coixia LLC"
LABEL maintainer="support@coixia.com"
LABEL org.opencontainers.image.source="https://github.com/coixia/coixia-rust-image"
LABEL org.opencontainers.image.description="Coixia Rust Dedicated Server Image for Wisp/Pterodactyl"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt upgrade -y \
    && apt install -y \
        lib32gcc-s1 \
        lib32stdc++6 \
        unzip \
        curl \
        iproute2 \
        tzdata \
        libgdiplus \
        ca-certificates \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && apt-get install -y nodejs \
    && rm nodesource_setup.sh \
    && node --version \
    && npm --version

# Install ws WebSocket package (required for Wisp RCON wrapper)
RUN mkdir -p /node_modules/ws /tmp/ws \
    && curl -L $(curl -s https://api.github.com/repos/websockets/ws/releases/latest | jq -r '.zipball_url') -o /tmp/ws-latest.zip \
    && unzip /tmp/ws-latest.zip -d /tmp/ws \
    && mv /tmp/ws/*/* /node_modules/ws \
    && rm -rf /tmp/ws /tmp/ws-latest.zip

# Install SteamCMD — must be outside /home/container as Pterodactyl mounts a volume there
RUN mkdir -p /opt/steamcmd \
    && curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xzvf - -C /opt/steamcmd

# Create container user
RUN useradd -d /home/container -m container \
    && chown -R container:container /opt/steamcmd

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

# Copy wrapper and entrypoint
COPY --chmod=0755 ./wrapper.js /wrapper.js
COPY --chmod=0755 ./entrypoint.sh /entrypoint.sh

CMD [ "/bin/bash", "/entrypoint.sh" ]
