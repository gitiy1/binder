FROM debian:11
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install ssh git unzip gcc git make wget neovim fish tmux byobu curl python3 neofetch sudo nano netcat openssl socat python3-pip qemu-kvm libvirt-daemon-system virtinst libguestfs-tools bridge-utils -y
RUN apt-get install -y libvirt-daemon-system-sysv
RUN /etc/init.d/libvirtd start && chkconfig libvirtd on
RUN virsh net-list --all
RUN virsh net-start default
RUN virsh net-autostart default
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
RUN ssh-keygen -A
RUN chown -R ${NB_UID} ${HOME}
RUN chown -R ${NB_UID} /home
RUN chown -R ${NB_UID} /opt
RUN chown -R ${NB_UID} /var/lib/libvirt
USER ${NB_USER}
RUN cd ~ && wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
RUN cd ~ && cp debian-11-generic-amd64.qcow2 /var/lib/libvirt/images
RUN virsh blockresize debian11 /var/lib/libvirt/images/debian-11-generic-amd64.qcow2 50G
RUN virt-customize -a debian-12-generic-amd64.qcow2 \
--update \
--hostname iceyear \
--timezone 'Asia/Shanghai' \
--root-password password:iceyear \
--install openssh-server,build-essential,wget,curl,git,net-tools \
--run-command 'ssh-keygen -A'
RUN virt-install \
--name debian12 \
--memory 4096 \
--vcpus 4 \
--cpu host-passthrough \
--os-variant debian12 \
--boot uefi \
--machine q35 \
--import \
--disk /var/lib/libvirt/images/debian-12-generic-amd64.qcow2,bus=virtio,cache=writeback \
--network bridge=virbr0,model=virtio \
--graphics vnc,port=5901,listen=0.0.0.0,password=iceyear \
--noautoconsole
