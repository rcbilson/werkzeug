FROM ubuntu:rolling

# Set up users in the container to match the host, so that the container user
# has correct permissions for 'richard' files.
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y unminimize && \
    yes | unminimize && \
    apt-get install -y ca-certificates curl adduser sudo gpg && \
    deluser ubuntu && \
    addgroup --gid 1000 richard && \
    adduser --quiet --disabled-password --shell /bin/zsh --home /home/richard --gecos "User" richard --uid 1000 --gid 1000 && \
    usermod -aG sudo richard && \
    echo "richard ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add kubernetes PPA
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg &&\
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Add helm PPA
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && apt-get install -y \
	git \
	golang-go \
	helm \
        kubectl \
	npm \
        openssh-server \
	sqlite3 \
	tmux \
	vim \
        file \
        gawk \
        make \
	man-db \
        mandoc \
        podman \
        silversearcher-ag \
        sudo \
        unzip \
        zoxide \
	zsh

# Install yarn & aws-cli
RUN npm install -g yarn && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -r awscliv2.zip aws

# Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

COPY entrypoint /entrypoint

USER 1000:1000
ENV SHELL=/usr/bin/zsh
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=America/Toronto
WORKDIR /home/richard

ENTRYPOINT ["/entrypoint"]
