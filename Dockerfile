FROM ubuntu:20.04

ENV COIN="monero"
ENV POOL="randomxmonero.usa-west.nicehash.com:3380"
ENV WALLET="3QGJuiEBVHcHkHQMXWY4KZm63vx1dEjDpL"
ENV WORKER="Docker"
ENV APPS="libuv1-dev libssl-dev libhwloc-dev curl libpci3 xz-utils"
ENV HOME="/home/docker"
ENV FEE="lnxd-fee" 
ENV DRIVERV=""
# Fee options: "lnxd-fee", "dev-fee", "no-fee"

# Set timezone and create user
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    ln -fs /usr/share/zoneinfo/Australia/Melbourne /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    apt-get clean all; \
    # Create user account
    groupadd -g 98 docker; \
    useradd --uid 99 --gid 98 docker; \
    echo 'docker:docker' | chpasswd;

# Install default apps
# Copy latest scripts
COPY start.sh /home/docker/start.sh
COPY mine.sh /home/docker/mine.sh
RUN export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /home/docker/mine.sh; \
    chmod +x /home/docker/start.sh; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y $APPS; \
    apt-get clean all; \

# Prepare xmrig
WORKDIR /home/docker
RUN FEE="dev-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="no-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="lnxd-fee"; \
    curl "https://github.com/lnxd/xmrig/releases/download/v6.10.0/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig; \

USER docker

CMD ["./mine.sh"]