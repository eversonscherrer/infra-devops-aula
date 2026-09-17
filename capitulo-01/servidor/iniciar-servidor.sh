#!/bin/bash
# ==================================================================
#  "Boot" do servidor: roda toda vez que o container inicia.
#
#  1. prepara o SSH
#  2. executa, em ordem alfabética, todo arquivo EXECUTÁVEL
#     de /etc/inicio.d  (é assim que um programa "sobe junto")
#  3. fica rodando o servidor SSH (porta 22)
# ==================================================================
LOG=/var/log/boot.log

echo "[boot] $(date '+%d/%m/%Y %H:%M:%S') servidor $(hostname) iniciando" >> "$LOG"

mkdir -p /run/sshd
# chaves do servidor ficam em volume: não mudam quando o container é recriado
mkdir -p /etc/ssh/chaves
for t in ed25519 rsa; do
  [ -f /etc/ssh/chaves/ssh_host_${t}_key ] || ssh-keygen -q -N "" -t $t -f /etc/ssh/chaves/ssh_host_${t}_key
done

run-parts --verbose /etc/inicio.d >> "$LOG" 2>&1

echo "[boot] $(date '+%d/%m/%Y %H:%M:%S') SSH escutando na porta 22" >> "$LOG"
exec /usr/sbin/sshd -D -E /var/log/auth.log
