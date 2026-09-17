#!/usr/bin/env bash
# ==================================================================
#  Laboratório 01 — Linux como Servidor
#  Infra & DevOps na Prática • Capítulo 1
#
#  Uso (dentro do servidor, via SSH):
#    sudo bash lab01.sh preparar    monta o cenário da aula
#    sudo bash lab01.sh verificar   confere a sua missão
#    sudo bash lab01.sh limpar      remove tudo que o lab criou
#
#  Combinado: NÃO leia a função preparar() antes de investigar.
#  A graça da aula é descobrir o problema usando os comandos. 😉
# ==================================================================
set -uo pipefail

PORTA=8080
INICIO=/etc/inicio.d
APP=app-turma
APP_DIR=/srv/app-turma
APP_INICIO=$INICIO/20-app-turma
LEGADO=painel-antigo
LEGADO_DIR=/opt/painel-antigo
LEGADO_INICIO=$INICIO/10-painel-antigo
ESTADO=/opt/.lab01

verde()    { printf '\033[32m%s\033[0m\n' "$*"; }
vermelho() { printf '\033[31m%s\033[0m\n' "$*"; }
azul()     { printf '\033[36m%s\033[0m\n' "$*"; }

exigir_root() {
  if [ "$(id -u)" -ne 0 ]; then
    vermelho "Este comando precisa de privilégio de administrador."
    echo "Rode assim:  sudo bash $0 ${1:-preparar}"
    exit 1
  fi
}

exigir_ambiente() {
  if [ ! -d "$INICIO" ] || [ ! -x /usr/local/sbin/iniciar-servidor ]; then
    vermelho "Este laboratório roda dentro do servidor da turma (capitulo-01/servidor)."
    exit 1
  fi
  for c in python3 curl ss pgrep runuser setsid; do
    command -v "$c" >/dev/null || { vermelho "Comando $c não encontrado. Recrie o servidor com docker compose up -d --build"; exit 1; }
  done
}

porta_ocupada() { ss -Htln "sport = :$PORTA" | grep -q .; }
pids_legado()   { pgrep -f "^/bin/bash $LEGADO_DIR/vigia.sh|directory $LEGADO_DIR"; }
pid_app()       { pgrep -u www-data -f "directory $APP_DIR" | head -1; }

# ------------------------------------------------------------------
preparar() {
  exigir_root preparar
  exigir_ambiente

  # permite rodar "preparar" de novo para recomeçar o laboratório
  pkill -f "^/bin/bash $LEGADO_DIR/vigia.sh|directory $LEGADO_DIR" 2>/dev/null
  pkill -f "directory $APP_DIR" 2>/dev/null
  sleep 1

  if porta_ocupada; then
    vermelho "A porta $PORTA já está em uso por outro programa."
    echo "Descubra quem é com:  sudo ss -tulpn | grep $PORTA"
    exit 1
  fi

  azul "==> Preparando o servidor herdado..."

  # Sistema antigo que a equipe anterior esqueceu ligado
  mkdir -p "$LEGADO_DIR"
  cat > "$LEGADO_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR"><head><meta charset="UTF-8"><title>Painel Administrativo</title></head>
<body style="font-family:monospace;background:#ddd;padding:40px">
<h1>Painel Administrativo v0.3</h1>
<p>Sistema em manutenção desde 2019.</p>
</body></html>
HTML

  cat > "$LEGADO_DIR/vigia.sh" <<SH
#!/bin/bash
# vigia do painel: se o painel cair, liga de novo
while true; do
  runuser -u nobody -- python3 -m http.server $PORTA --bind 0.0.0.0 --directory $LEGADO_DIR
  echo "\$(date '+%d/%m/%Y %H:%M:%S') painel parou, religando em 3s"
  sleep 3
done
SH
  chmod 755 "$LEGADO_DIR" "$LEGADO_DIR/vigia.sh"; chmod 644 "$LEGADO_DIR/index.html"

  cat > "$LEGADO_INICIO" <<SH
#!/bin/bash
# painel-antigo — painel administrativo (sistema de 2019)
setsid $LEGADO_DIR/vigia.sh >> /var/log/$LEGADO.log 2>&1 < /dev/null &
sleep 2
SH

  # A aplicação que a turma precisa colocar no ar
  mkdir -p "$APP_DIR"
  cat > "$APP_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>app-turma</title>
</head>
<body style="font-family:sans-serif;background:#0a1525;color:#f1f5f9;text-align:center;padding:60px">
  <h1>✅ app-turma no ar</h1>
  <p>Servidor preparado por: <strong>SEU GRUPO AQUI</strong></p>
  <p style="color:#94a3b8">Esta página é provisória. Nas próximas aulas ela será
  substituída pela aplicação do projeto de vocês.</p>
</body>
</html>
HTML
  chown -R root:root "$APP_DIR"
  chmod 755 "$APP_DIR"; chmod 644 "$APP_DIR/index.html"

  cat > "$APP_INICIO" <<SH
#!/bin/bash
# app-turma — aplicação do projeto, porta $PORTA, usuário www-data
setsid runuser -u www-data -- python3 -m http.server $PORTA --bind 0.0.0.0 --directory $APP_DIR >> /var/log/$APP.log 2>&1 < /dev/null &
SH
  chmod 755 "$LEGADO_INICIO" "$APP_INICIO"

  # sobe tudo como aconteceria no boot do servidor
  echo "[boot] $(date '+%d/%m/%Y %H:%M:%S') (lab01) executando $INICIO" >> /var/log/boot.log
  run-parts --verbose "$INICIO" >> /var/log/boot.log 2>&1
  sleep 1

  mkdir -p "$ESTADO"
  date +%s > "$ESTADO/preparado-em"

  verde "==> Pronto! O servidor foi entregue pela equipe anterior."
  echo
  echo "Relato do cliente:"
  echo "  \"A equipe disse que a app-turma estava configurada na porta $PORTA,"
  echo "   mas quando eu acesso aparece uma página estranha...\""
  echo
  echo "Comece testando:  curl http://localhost:$PORTA"
}

# ------------------------------------------------------------------
ok=0; total=0
checar() {  # checar "descrição" "dica se falhar" comando...
  local desc="$1" dica="$2"; shift 2
  total=$((total + 1))
  if "$@" >/dev/null 2>&1; then
    verde "  [OK]    $desc"; ok=$((ok + 1))
  else
    vermelho "  [FALTA] $desc"
    echo "          pista: $dica"
  fi
}

legado_parado()      { ! pids_legado; }
legado_sem_boot()    { [ ! -x "$LEGADO_INICIO" ]; }
app_rodando()        { [ -n "$(pid_app)" ]; }
app_no_boot()        { [ -x "$APP_INICIO" ]; }
responde_app()       {  # a porta pertence ao processo da app-turma e responde HTTP
  local pid; pid=$(pid_app)
  [ -n "$pid" ] || return 1
  ss -Htlnp "sport = :$PORTA" | grep -q "pid=$pid," || return 1
  curl -s --max-time 3 "http://localhost:$PORTA" | grep -q 'app-turma'
}
hostname_ok()        { case "$(hostname)" in srv-?*) return 0;; *) return 1;; esac; }
pagina_ok()          { [ -f "$APP_DIR/index.html" ] && ! grep -q 'SEU GRUPO AQUI' "$APP_DIR/index.html"; }
reiniciou()          {  # o processo 1 (o "boot" do container) é mais novo que o preparar
  [ -f "$ESTADO/preparado-em" ] || return 1
  local boot; boot=$(date -d "$(ps -o lstart= -p 1)" +%s)
  [ "$boot" -gt "$(cat "$ESTADO/preparado-em")" ]
}

verificar() {
  exigir_root verificar
  [ -f "$APP_INICIO" ] || { vermelho "Cenário não encontrado. Rode antes: sudo bash $0 preparar"; exit 1; }

  azul "==> Missão: colocar a app-turma no ar"
  checar "painel-antigo parado"                     "quem está ocupando a porta $PORTA? e quem religa ele?" legado_parado
  checar "painel-antigo não volta no boot"          "o que roda sozinho quando o servidor liga?"           legado_sem_boot
  checar "app-turma rodando"                        "o que diz o log da app-turma?"                        app_rodando
  checar "app-turma sobe sozinha no boot"           "o que torna um arquivo de $INICIO ativo?"             app_no_boot
  checar "porta $PORTA responde com a app-turma"    "teste com curl http://localhost:$PORTA"               responde_app
  azul "==> Desafio final"
  checar "hostname no padrão srv-<grupo>"           "onde está a configuração do container?"               hostname_ok
  checar "página identifica o grupo"                "quem é o dono de $APP_DIR/index.html?"                pagina_ok
  checar "tudo continua no ar depois de reiniciar"  "reinicie o servidor e verifique de novo"              reiniciou

  local ip gw
  ip=$(ip -4 -o addr show scope global | awk '{print $2" "$4}' | head -1)
  gw=$(ip route show default | awk '{print $3}' | head -1)
  echo
  azul "==> Evidência (copie este bloco para o AVA)"
  echo "  Data/hora ....: $(date '+%d/%m/%Y %H:%M')"
  echo "  Hostname .....: $(hostname)"
  echo "  Sistema ......: $(. /etc/os-release && echo "$PRETTY_NAME")"
  echo "  Interface/IP .: ${ip:-?}"
  echo "  Gateway ......: ${gw:-?}"
  echo "  Ligado desde .: $(ps -o lstart= -p 1)"
  echo "  Resultado ....: $ok de $total"
  [ "$ok" -eq "$total" ] && verde "  Missão cumprida! 🎉"
}

# ------------------------------------------------------------------
limpar() {
  exigir_root limpar
  azul "==> Removendo o cenário do Laboratório 01..."
  pkill -f "^/bin/bash $LEGADO_DIR/vigia.sh|directory $LEGADO_DIR" 2>/dev/null
  pkill -f "directory $APP_DIR" 2>/dev/null
  rm -f "$LEGADO_INICIO" "$APP_INICIO"
  rm -rf "$APP_DIR" "$LEGADO_DIR" "$ESTADO"
  verde "==> Limpo. (O hostname e os logs em /var/log não foram alterados.)"
}

case "${1:-}" in
  preparar)  preparar ;;
  verificar) verificar ;;
  limpar)    limpar ;;
  *) echo "Uso: sudo bash $0 {preparar|verificar|limpar}"; exit 1 ;;
esac
