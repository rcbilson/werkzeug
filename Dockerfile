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

RUN apt-get update && apt-get install -y \
	git \
	golang-go \
        jq \
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

# Homebrew

RUN useradd -m -s /bin/zsh linuxbrew && \
    usermod -aG sudo linuxbrew &&  \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R linuxbrew: /home/linuxbrew/.linuxbrew

USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

USER root
RUN chown -R richard: /home/linuxbrew/.linuxbrew

USER 1000
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN brew install \
        k9s \
        helm \
        kubectl \
        awscli \
        yarn

COPY entrypoint /entrypoint

ENV SHELL=/usr/bin/zsh
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=America/Toronto
WORKDIR /home/richard

ENTRYPOINT ["/entrypoint"]
