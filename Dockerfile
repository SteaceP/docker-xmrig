FROM ubuntu:20.04

ENV COIN="monero"
ENV POOL="xmr-us-east1.nanopool.org:14433"
ENV WALLET="8871YQJDhzm1kg8YqAsCoSeYEt6ZjHgBMcwyCwETxcia4MfTL3TyW4b5byAT24FLS38ehauAzNH3o7iPbyF8YHTU4MDfzRU"
ENV WORKER="Docker"
ENV APPS="libuv1-dev libssl-dev libhwloc-dev"
ENV HOME="/home/docker"
ENV FEE="no-fee"
ENV VERSION="v6.12.1"
# Fee options: "steace-fee", "dev-fee", "no-fee"

# Set timezone and create user
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    ln -fs /usr/share/zoneinfo/Canada/Toronto /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    apt-get clean all; \
    # Create user account
    groupadd -g 98 docker; \
    useradd --uid 99 --gid 98 docker; \
    echo 'docker:docker' | chpasswd; \
    usermod -aG sudo docker;

# Install default apps
COPY "mine.sh" "/home/docker/mine.sh"
RUN export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /home/docker/mine.sh; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y sudo $APPS; \
    apt-get clean all; \
    # Prevent error messages when running sudo
    echo "Set disable_coredump false" >> /etc/sudo.conf; 

# Prepare xmrig
WORKDIR /home/docker
RUN apt-get update && apt-get install -y curl; \
    FEE="dev-fee"; \
    curl "https://github.com/SteaceP/xmrig/releases/download/${VERSION}/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="no-fee"; \
    curl "https://github.com/SteaceP/xmrig/releases/download/${VERSION}/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig ;\
    FEE="steace-fee"; \
    curl "https://github.com/SteaceP/xmrig/releases/download/${VERSION}/xmrig-${FEE}.tar.gz" -L -o "/home/docker/xmrig-${FEE}.tar.gz"; \
    mkdir /home/docker/xmrig-${FEE}; \
    tar xvzf xmrig-${FEE}.tar.gz -C /home/docker/xmrig-${FEE}; \
    rm xmrig-${FEE}.tar.gz; \
    chmod +x /home/docker/xmrig-${FEE}/xmrig; \
    apt-get purge -y curl && apt-get autoremove -y && apt-get clean all;

USER docker

CMD ["./mine.sh"]
