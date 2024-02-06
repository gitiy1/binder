FROM debian:11
RUN apt update
RUN apt-get install -y gcc make wget neovim fish tmux byobu curl python3 neofetch sudo python3-pip
RUN python3 -m pip install --no-cache-dir notebook jupyterlab jupyterhub
RUN echo root:iceyear|chpasswd
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
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
