#!/usr/bin/env bash
# ==================================================================
#  Laboratório 02 — Git e GitHub na infraestrutura
#  Infra & DevOps na Prática • Capítulo 2
#
#  Uso (dentro do servidor da turma, via SSH, com o usuário aluno):
#    sudo bash lab02.sh preparar URL   faz o deploy do repositório do grupo
#    sudo bash lab02.sh verificar      confere a sua missão
#    sudo bash lab02.sh limpar         desfaz o deploy do laboratório
#
#  URL = endereço HTTPS do repositório do grupo no GitHub, por exemplo:
#        https://github.com/usuario/projeto-grupo3.git
#
#  Combinado: NÃO leia a função preparar() antes de investigar.
#  A graça da aula é descobrir o problema usando os comandos. 😉
# ==================================================================
set -uo pipefail

PORTA=8080
APP=app-turma
APP_DIR=/srv/app-turma
APP_INICIO=/etc/inicio.d/20-app-turma
ESTADO=/opt/.lab02
MARCA='ramal 2042'

verde()    { printf '\033[32m%s\033[0m\n' "$*"; }
vermelho() { printf '\033[31m%s\033[0m\n' "$*"; }
azul()     { printf '\033[36m%s\033[0m\n' "$*"; }

exigir_root() {
  if [ "$(id -u)" -ne 0 ]; then
    vermelho "Este comando precisa de privilégio de administrador."
    echo "Rode assim:  sudo bash $0 $*"
    exit 1
  fi
}

exigir_ambiente() {
  local falta=""
  if [ ! -d /etc/inicio.d ] || [ ! -x /usr/local/sbin/iniciar-servidor ]; then
    vermelho "Este laboratório roda dentro do servidor da turma (capitulo-01/servidor)."
    exit 1
  fi
  for c in git curl python3 pgrep runuser setsid; do command -v "$c" >/dev/null || falta="$falta $c"; done
  if [ -n "$falta" ]; then
    vermelho "Faltam programas no servidor:$falta"
    echo "Recrie o servidor no PC:  docker compose up -d --build"
    exit 1
  fi
}

# Git roda sempre como o dono do repositório — nunca como root.
git_u() { (cd /tmp && sudo -u "$USUARIO" -H env GIT_TERMINAL_PROMPT=0 timeout 60 git -C "$APP_DIR" "$@"); }

porta_ocupada() { ss -Htln "sport = :$PORTA" | grep -q .; }
pid_app()       { pgrep -u www-data -f "directory $APP_DIR\$" | head -1; }
parar_app()     { pkill -f "directory $APP_DIR\$" 2>/dev/null; sleep 1; }
normalizar()    { local u="${1%/}"; echo "${u%.git}"; }

# ------------------------------------------------------------------
preparar() {
  local url="${1:-}"
  exigir_root preparar URL
  exigir_ambiente

  USUARIO="${SUDO_USER:-}"
  if [ -z "$USUARIO" ] || [ "$USUARIO" = root ]; then
    vermelho "Rode a partir do usuário aluno usando sudo — não como root."
    exit 1
  fi

  case "$url" in
    https://github.com/?*/?*) ;;
    *)
      vermelho "Informe a URL HTTPS do repositório do grupo."
      echo "Exemplo:  sudo bash $0 preparar https://github.com/usuario/projeto-grupo3.git"
      exit 1 ;;
  esac

  azul "==> Testando acesso ao repositório..."
  if ! (cd /tmp && sudo -u "$USUARIO" -H env GIT_TERMINAL_PROMPT=0 timeout 30 git ls-remote "$url" >/dev/null 2>&1); then
    vermelho "Não consegui ler $url"
    echo "  pistas: a URL está certa? o repositório é PÚBLICO?"
    echo "          o servidor chega na internet? (ping 8.8.8.8 · curl -I https://github.com)"
    exit 1
  fi

  parar_app
  if porta_ocupada; then
    vermelho "A porta $PORTA já está em uso por outro programa."
    echo "Descubra quem é com:  sudo ss -tulpn | grep $PORTA"
    exit 1
  fi

  azul "==> Fazendo o deploy do repositório em $APP_DIR..."

  if [ -e "$APP_DIR" ]; then
    local copia="$APP_DIR.antes-lab02-$(date +%Y%m%d%H%M%S)"
    mv "$APP_DIR" "$copia"
    echo "  conteúdo anterior guardado em $copia"
  fi

  install -d -o "$USUARIO" -g "$(id -gn "$USUARIO")" -m 755 "$APP_DIR"
  if ! git_u clone -q "$url" "$APP_DIR"; then
    vermelho "Falha no git clone."
    exit 1
  fi

  if [ ! -f "$APP_DIR/index.html" ]; then
    vermelho "O repositório não tem um index.html na raiz."
    echo "  Use o modelo capitulo-02/site-modelo/index.html, faça commit e push,"
    echo "  e rode o preparar de novo."
    exit 1
  fi

  # a app-turma do Capítulo 1 continua publicando a pasta na porta 8080
  if [ ! -f "$APP_INICIO" ]; then
    cat > "$APP_INICIO" <<SH
#!/bin/bash
# app-turma — aplicação do projeto, porta $PORTA, usuário www-data
setsid runuser -u www-data -- python3 -m http.server $PORTA --bind 0.0.0.0 --directory $APP_DIR >> /var/log/$APP.log 2>&1 < /dev/null &
SH
  fi
  chmod 755 "$APP_INICIO"
  "$APP_INICIO"
  for _ in 1 2 3 4 5 6 7 8 9 10; do porta_ocupada && break; sleep 1; done

  # Sexta-feira, 23h40...
  python3 - "$APP_DIR/index.html" <<'PY'
import re, sys
caminho = sys.argv[1]
with open(caminho, encoding="utf-8", errors="replace") as f:
    html = f.read()
bloco = (
    '  <!-- HOTFIX sexta 23h40 (jorge): cliente reclamou que nao achava contato.\n'
    '       Corrigi direto no servidor pq era urgente, segunda eu subo pro GitHub -->\n'
    '  <p style="margin-top:40px;color:#ffb74d">📞 Problemas? Contato do suporte: ramal 2042</p>\n'
)
fim = list(re.finditer(r"</body>", html, re.I))
html = html[:fim[-1].start()] + bloco + html[fim[-1].start():] if fim else html + "\n" + bloco
with open(caminho, "w", encoding="utf-8") as f:
    f.write(html)
PY
  touch -d "last friday 23:40" "$APP_DIR/index.html" 2>/dev/null || true

  mkdir -p "$ESTADO"
  echo "$url"                   > "$ESTADO/url"
  echo "$USUARIO"               > "$ESTADO/usuario"
  git_u rev-parse HEAD          > "$ESTADO/commit-inicial"

  local ip
  ip=$(ip -4 -o addr show scope global | awk '{split($4,a,"/"); print a[1]}' | head -1)
  verde "==> Deploy feito! O repositório do grupo está em produção."
  echo
  echo "  Pasta ........: $APP_DIR"
  echo "  Serviço ......: $APP (porta $PORTA, $APP_INICIO)"
  echo "  No navegador .: http://${ip:-IP_DO_SERVIDOR}:$PORTA"
  echo
  echo "Próximo passo: altere o index.html no SEU PC, faça commit e push,"
  echo "e atualize o servidor com:  cd $APP_DIR && git pull"
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

eh_clone()        {
  [ -d "$APP_DIR/.git" ] || return 1
  [ "$(normalizar "$(git_u config --get remote.origin.url)")" = "$(normalizar "$(cat "$ESTADO/url")")" ]
}
limpo()           { local s; s=$(git_u status --porcelain) || return 1; [ -z "$s" ]; }
sincronizado()    {
  git_u fetch -q || return 1
  [ "$(git_u rev-parse HEAD)" = "$(git_u rev-parse '@{u}')" ]
}
hotfix_no_repo()  { git_u show HEAD:index.html | grep -q "$MARCA"; }
no_ar()           {
  local pid; pid=$(pid_app)
  [ -n "$pid" ] || return 1
  ss -Htlnp "sport = :$PORTA" | grep -q "pid=$pid," || return 1
  cmp -s <(curl -s --max-time 3 "http://localhost:$PORTA/index.html") <(git_u show HEAD:index.html)
}
dois_autores()    { [ "$(git_u log --format='%ae' | sort -u | wc -l)" -ge 2 ]; }
deploy_versionado(){ git_u ls-files --error-unmatch deploy.sh && git_u show HEAD:deploy.sh | grep -q 'git pull'; }
tres_commits()    { [ "$(git_u rev-list --count "$(cat "$ESTADO/commit-inicial")..HEAD")" -ge 3 ]; }

verificar() {
  exigir_root verificar
  if [ ! -f "$ESTADO/url" ]; then
    vermelho "Deploy não encontrado. Rode antes: sudo bash $0 preparar URL_DO_REPOSITORIO"
    exit 1
  fi
  USUARIO=$(cat "$ESTADO/usuario")

  azul "==> Missão: atualizar a produção sem perder nada"
  checar "$APP_DIR é um clone do repositório do grupo"   "git remote -v"                                   eh_clone
  checar "nenhuma alteração solta no servidor"           "o que o git status mostra?"                      limpo
  checar "servidor atualizado com o GitHub"              "git fetch · git status · git log --oneline"      sincronizado
  checar "correção do suporte guardada no repositório"   "o git diff mostrou algo. Isso está no GitHub?"   hotfix_no_repo
  checar "porta $PORTA serve a versão do repositório"    "a app-turma está rodando? curl localhost:$PORTA"   no_ar
  azul "==> Desafio final"
  checar "commits de pelo menos 2 integrantes"           "git log --format='%an <%ae>'"                    dois_autores
  checar "deploy.sh versionado e usando git pull"        "o script nasce no PC, não no servidor"           deploy_versionado
  checar "3 ou mais commits novos chegaram ao servidor"  "git log --oneline · quantos são novos?"          tres_commits

  local ip
  ip=$(ip -4 -o addr show scope global | awk '{print $2" "$4}' | head -1)
  echo
  azul "==> Evidência (copie este bloco para o AVA)"
  echo "  Data/hora ....: $(date '+%d/%m/%Y %H:%M')"
  echo "  Hostname .....: $(hostname)"
  echo "  Interface/IP .: ${ip:-?}"
  echo "  Repositório ..: $(git_u config --get remote.origin.url 2>/dev/null || echo '?')"
  echo "  Branch .......: $(git_u rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  echo "  No ar ........: $(git_u log -1 --format='%h %s (%an)' 2>/dev/null || echo '?')"
  echo "  Commits ......: $(git_u rev-list --count HEAD 2>/dev/null || echo '?') no total, $(git_u log --format='%ae' 2>/dev/null | sort -u | wc -l) autor(es)"
  echo "  Resultado ....: $ok de $total"
  [ "$ok" -eq "$total" ] && verde "  Missão cumprida! 🎉"
}

# ------------------------------------------------------------------
limpar() {
  exigir_root limpar
  azul "==> Desfazendo o deploy do Laboratório 02..."
  parar_app
  rm -rf "$APP_DIR"
  local copia
  copia=$(ls -d "$APP_DIR".antes-lab02-* 2>/dev/null | sort | head -1)
  if [ -n "$copia" ]; then
    mv "$copia" "$APP_DIR"
    rm -rf "$APP_DIR".antes-lab02-*
    echo "  conteúdo anterior restaurado de $copia"
  fi
  rm -rf "$ESTADO"
  if [ -d "$APP_DIR" ] && [ -x "$APP_INICIO" ]; then
    "$APP_INICIO"
    for _ in 1 2 3 4 5; do porta_ocupada && break; sleep 1; done
  fi
  verde "==> Limpo. (O repositório continua intacto no GitHub.)"
}

case "${1:-}" in
  preparar)  preparar "${2:-}" ;;
  verificar) verificar ;;
  limpar)    limpar ;;
  *) echo "Uso: sudo bash $0 {preparar URL|verificar|limpar}"; exit 1 ;;
esac
