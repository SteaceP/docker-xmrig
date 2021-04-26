FROM alpine:3.9

# Environment Variables
ENV COIN="monero"
ENV POOL="xmr-us-east1.nanopool.org:14433"
ENV WALLET="8871YQJDhzm1kg8YqAsCoSeYEt6ZjHgBMcwyCwETxcia4MfTL3TyW4b5byAT24FLS38ehauAzNH3o7iPbyF8YHTU4MDfzRU"
ENV WORKER="Docker"
ENV MINERV="6.12.1"
ENV APPS="curl tar gzip"

# Prepare Alpine
RUN apk add --no-cache sudo ${APPS}; \
    adduser \
    --disabled-password \
    --gecos "" \
    "docker";\
    echo 'docker:docker' | chpasswd; \
    addgroup sudo; \
    adduser docker sudo; \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;
ENV HOME /home/docker
WORKDIR /home/docker

# Prepare xmrig
COPY "init.sh" "/home/docker/init.sh"
RUN chmod +x /home/docker/init.sh; \

    curl "https://github.com/xmrig/xmrig/releases/download/v${MINERV}/xmrig-${MINERV}-linux-static-x64.tar.gz" -L -o "/home/docker/xmrig-${MINERV}-linux-static-x64.tar.gz"; \
    tar xvzf xmrig-${MINERV}-linux-static-x64.tar.gz; \
    rm xmrig-${MINERV}-linux-static-x64.tar.gz; \
    mv xmrig-${MINERV} xmrig; \
    chmod +x /home/docker/xmrig/xmrig; \

# Clean up
    apk del --no-cache ${APPS};

WORKDIR /home/docker

CMD ["./init.sh"]
