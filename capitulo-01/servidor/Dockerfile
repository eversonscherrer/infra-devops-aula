# ==================================================================
#  Servidor do semestre — Infra & DevOps na Prática
#  Um Ubuntu Server "de mentira": o container finge ser uma máquina.
# ==================================================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Sao_Paulo \
    LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-server sudo tzdata ca-certificates \
      iproute2 iputils-ping curl dnsutils \
      procps psmisc python3 \
      nano less git \
 && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
 && rm -rf /var/lib/apt/lists/*

# usuário de acesso (a imagem do Ubuntu já traz um "ubuntu" que não usamos)
RUN userdel -r ubuntu 2>/dev/null; \
    useradd -m -s /bin/bash -G sudo aluno \
 && echo 'aluno:aluno' | chpasswd \
 && mkdir -p /etc/inicio.d /run/sshd \
 && sed -i 's/^AcceptEnv/#AcceptEnv/' /etc/ssh/sshd_config \
 && echo 'LANG=C.UTF-8' > /etc/default/locale \
 && rm -f /etc/ssh/ssh_host_* \
 && printf 'HostKey /etc/ssh/chaves/ssh_host_ed25519_key\nHostKey /etc/ssh/chaves/ssh_host_rsa_key\n' > /etc/ssh/sshd_config.d/10-chaves.conf

COPY iniciar-servidor.sh /usr/local/sbin/iniciar-servidor
RUN chmod 755 /usr/local/sbin/iniciar-servidor

EXPOSE 22
CMD ["/usr/local/sbin/iniciar-servidor"]
