FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    git \
    ssh
    
# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

RUN mkdir -p /var/run/sshd

RUN git config --global user.email "git_autodocker@example.com"
RUN git config --global user.name "Git AutoDocker"

ADD sshkey.pub /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys

### gitreceive comes from progrium. grab it again when a new version is available.  
# ADD https://raw.github.com/progrium/gitreceive/master/gitreceive /usr/local/bin/
ADD gitreceive /usr/local/bin/

RUN chmod 755 /usr/local/bin/gitreceive 
RUN /usr/local/bin/gitreceive init

ADD receiver /home/git/receiver
RUN chmod 755 /home/git/receiver

VOLUME /home/git
#VOLUME /var/lib/docker
EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd", "-D"]