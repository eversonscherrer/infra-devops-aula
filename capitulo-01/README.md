# Capítulo 01 — Linux como Servidor

> **Pergunta norteadora:** onde nossa aplicação vai rodar?

## Objetivo

Acessar e investigar um servidor Linux pela rede, entender como ele se
conecta (IP, gateway, portas) e colocar um serviço no ar diagnosticando um
problema real com processos e logs. O servidor criado hoje — um container
Ubuntu que faz papel de máquina — será o **servidor da turma até o Capítulo 9**.

## Conteúdo

- Servidor x computador pessoal · por que Linux · terminal
- Um servidor dentro de um container: o que muda e o que não muda
- SSH: cliente/servidor, TCP, porta 22, endereço IP, redirecionamento de porta
- Diretórios, usuários, permissões, `root` e `sudo`
- Interfaces, IP/máscara, gateway e rotas
- Programa, processo (PID e pai), serviço e porta
- CPU, memória e disco
- O que sobe junto com o servidor (`/etc/inicio.d`) e logs em `/var/log`

## Material

📄 [`01-linux-como-servidor.pdf`](./01-linux-como-servidor.pdf) — teoria + prática intercaladas (31 slides)

## Prática

**Missão: o servidor herdado.** Você entra no servidor da turma, descobre
suas características e depois assume um servidor "entregue pela equipe
anterior": a `app-turma` deveria responder na porta 8080, mas aparece uma
página estranha. Investigue, corrija e deixe o servidor pronto para as
próximas aulas.

### Roteiro rápido — marque conforme for fazendo

#### Etapa 0 — Ligar o servidor (no seu PC)

```bash
cd ~/infra-devops-aula/capitulo-01/servidor
docker compose up -d --build
docker compose ps
```

- [ ] `srv-turma` aparece como `running` (primeira vez? veja [`preparar-servidor.md`](./preparar-servidor.md))

#### Etapa 1 — Entrar no servidor

```bash
ssh aluno@172.30.0.10          # senha: aluno
hostname
whoami
pwd
```

- [ ] O prompt mudou para `aluno@...` — você está **dentro** do servidor

#### Etapa 2 — Qual é o endereço do servidor?

```bash
ip addr
```

- [ ] Anotei interface, IP/máscara e MAC na [ficha](./ficha-servidor.md)
- [ ] No **meu PC**, achei a interface `br-…` com `172.30.0.1` e o `ping 172.30.0.10` responde

#### Etapa 3 — Por onde os pacotes saem?

```bash
ip route
ping -c 4 172.30.0.1
ping -c 4 8.8.8.8
ping -c 4 github.com
curl -I https://github.com
```

- [ ] Sei qual teste prova rede local, internet, DNS e HTTP

#### Etapa 4 — Recursos, portas, processos e logs

```bash
nproc
free -h
df -h /
uname -r
top                      # q para sair
sudo ss -tulpn
ss -tn
pstree -p
ls -l /etc/inicio.d
sudo cat /var/log/boot.log
sudo tail -5 /var/log/auth.log
```

- [ ] Comparei `nproc`, `free -h` e `uname -r` com os do **meu PC**
- [ ] Encontrei a **minha** conexão SSH no `ss -tn` e o **meu** login no `auth.log`

#### Etapa 5 — Missão: o servidor herdado

```bash
curl -O https://raw.githubusercontent.com/eversonscherrer/infra-devops-aula/HEAD/capitulo-01/lab01.sh
sudo bash lab01.sh preparar
curl http://localhost:8080
```

- [ ] Respondi o roteiro de investigação do PDF **antes** de corrigir
- [ ] `sudo bash lab01.sh verificar` mostra as 5 linhas da missão com `[OK]`

> 💡 Combinado: não abra o `lab01.sh` para procurar a resposta. Use os
> comandos da aula — é exatamente assim que se investiga um servidor de
> verdade.

#### Etapa 6 — Desafio final

- [ ] Hostname no padrão `srv-<grupo>` (pista: `compose.yaml`)
- [ ] Página `/srv/app-turma/index.html` identifica o grupo
- [ ] A app abre pelo IP do servidor e por `http://localhost:8080` no **meu PC**
- [ ] Um colega abriu a app pelo **IP do meu PC**
- [ ] Depois de `docker compose restart`, tudo continua no ar
- [ ] `sudo bash lab01.sh verificar` → **8 de 8**

## Arquivos

| Arquivo | O que é |
|---------|---------|
| `01-linux-como-servidor.pdf` | Slides da aula: teoria + prática |
| `preparar-servidor.md` | Como criar e ligar o servidor usado no semestre inteiro (fazer **antes** da aula) |
| `servidor/` | `Dockerfile`, `compose.yaml` e script de inicialização do servidor da turma |
| `lab01.sh` | Monta o cenário da missão (`preparar`), confere o resultado (`verificar`) e desfaz tudo (`limpar`) |
| `ficha-servidor.md` | Modelo da ficha do servidor — a **evidência** da aula |

## Pré-requisitos

- Sequência [docker-aula](https://github.com/eversonscherrer/docker-aula) concluída
- PC com **Linux e Docker Engine** (com o plugin Compose), usando Docker sem sudo — veja [`preparar-servidor.md`](./preparar-servidor.md)
- Cliente SSH e git no PC
- Noções básicas de rede: IP, porta, cliente/servidor

---

## Pergunta rápida da aula

O `sudo ss -tulpn` mostra `tcp LISTEN 127.0.0.1:5432`. Um colega tenta
acessar essa porta de outro PC, pelo IP do servidor. O que acontece?

- A) Conecta, porque a porta está em LISTEN
- B) Não conecta: o serviço só aceita conexões da própria máquina
- C) Conecta, desde que o colega use sudo
- D) Conecta, mas só pela porta 22

<details>
<summary>Resposta</summary>

**B** — `127.0.0.1` é o endereço de *loopback*: o serviço está escutando
apenas na "rede interna" da própria máquina. Para aceitar conexões de fora
ele precisaria escutar em `0.0.0.0` (todas as interfaces) ou no IP da placa
de rede. Isso é uma escolha de segurança comum para bancos de dados — e vai
voltar no Capítulo 9.
</details>

---

## Próxima aula

O servidor está pronto… mas vazio. **Capítulo 02 — Git e GitHub na
infraestrutura:** como o código desenvolvido pela equipe chega até ele?
