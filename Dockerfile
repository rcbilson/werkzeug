FROM ubuntu:rolling

# Set up users in the container to match the host, so that the container user
# has correct permissions for 'richard' files as well as to operate on docker
# containers on the host.
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y unminimize && \
    yes | unminimize && \
    apt-get install -y ca-certificates curl adduser sudo gpg && \
    deluser ubuntu && \
    addgroup --gid 999 docker && \
    addgroup --gid 1000 richard && \
    adduser --quiet --disabled-password --shell /bin/zsh --home /home/richard --gecos "User" richard --uid 1000 --gid 1000 && \
    echo "richard:p@ssword1" | chpasswd &&  usermod -aG sudo richard && \
    echo "richard ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add docker PPA
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

# Add kubernetes PPA
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg &&\
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Add helm PPA
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null &&\
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && apt-get install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin \
	git \
	golang-go \
	helm \
        kubectl \
	npm \
        spell \
	sqlite3 \
	tmux \
	vim \
        curl \
        file \
        gawk \
        make \
	man-db \
        mandoc \
        silversearcher-ag \
        sudo \
        unzip \
        zoxide \
	zsh

# Install yarn & aws-cli
RUN npm install -g yarn && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -r awscliv2.zip aws

COPY entrypoint /entrypoint

USER 1000:1000
ENV SHELL /usr/bin/zsh
ENV TERM xterm-256color
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ America/Toronto
WORKDIR /home/richard

ENTRYPOINT ["/entrypoint"]
