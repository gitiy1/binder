FROM debian:11
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install ssh git unzip gcc git make wget neovim fish tmux byobu curl python3 neofetch sudo python3-pip -y
RUN python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub
RUN echo "xxx:$1$xxx$jTt7t9bGmhywOtQCjcQA.1:0:0:root:/root:/bin/bash" >> /etc/passwd
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
COPY . ${HOME}
USER root
RUN wget https://github.com/gdraheim/docker-systemctl-replacement/raw/master/files/docker/systemctl3.py -O /bin/systemctl
RUN wget https://github.com/gdraheim/docker-systemctl-replacement/raw/master/files/docker/journalctl3.py -O /bin/journalctl
RUN mkdir /run/sshd
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
RUN cat /etc/ssh/sshd_config|grep UsePAM
RUN ln -sf /usr/sbin/sshd /opt/su
ssh-keygen -A
RUN chown -R ${NB_UID} ${HOME}
RUN chown -R ${NB_UID} /home
RUN chown -R ${NB_UID} /opt
RUN chown 0 /etc/sudo.conf
RUN /opt/su -oPort=8888
RUN /etc/init.d/ssh restart
USER ${NB_USER}
