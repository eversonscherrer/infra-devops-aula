# Preparando o servidor do semestre

> Faça isto **antes** da aula 01. O container criado aqui é o **servidor da
> turma** e será usado do Capítulo 1 ao Capítulo 9 — não apague os volumes.

## O que você vai ter no final

```
 Seu PC (Linux + Docker)                         container srv-turma
 ┌───────────────────────────┐  rede-lab  ┌──────────────────────────────┐
 │ terminal + navegador      │ ─────────▶ │ Ubuntu 24.04 "servidor"      │
 │ 172.30.0.1 (gateway)      │   SSH 22   │ 172.30.0.10                  │
 │ localhost:2222 ──NAT──────┼──────────▶ │ sem interface gráfica        │
 └───────────────────────────┘            └──────────────────────────────┘
```

O container **finge ser um servidor**: tem usuário, SSH, processos, logs e
programas que sobem sozinhos quando ele liga. No docker-aula cada container
rodava **um** programa; este é uma exceção proposital, para estudarmos o
servidor por dentro sem precisar de uma máquina virtual.

## Requisitos

| Item | Como conferir |
|------|---------------|
| Linux com Docker Engine | `docker --version` |
| Plugin Compose | `docker compose version` |
| Seu usuário pode usar o Docker | `docker ps` funciona **sem** sudo |
| Cliente SSH e git | `ssh -V` · `git --version` |
| ~500 MB livres em disco | `df -h ~` |

Se `docker ps` der `permission denied ... docker.sock`:

```bash
sudo usermod -aG docker $USER
# saia da sessão e entre de novo (ou reinicie o PC)
```

## 1. Baixar o material das aulas

```bash
cd ~
git clone https://github.com/eversonscherrer/infra-devops-aula.git
cd infra-devops-aula/capitulo-01/servidor
```

## 2. Criar e ligar o servidor

```bash
docker compose up -d --build
docker compose ps
```

A primeira vez demora alguns minutos (baixa o Ubuntu e instala os pacotes).
O resultado esperado é o container `srv-turma` com estado `running` e as
portas `0.0.0.0:2222->22/tcp` e `0.0.0.0:8080->8080/tcp`.

## 3. Entrar no servidor por SSH

Há **dois caminhos** até o servidor — os dois vão aparecer na aula:

```bash
# pela porta publicada no seu PC (redirecionamento, como um NAT)
ssh -p 2222 aluno@localhost

# direto pelo IP do container, na rede rede-lab
ssh aluno@172.30.0.10
```

Senha inicial: **`aluno`** (vamos discutir isso no Capítulo 9).

- [ ] Conectou e o prompt virou `aluno@ubuntu:~$`? Pronto — a partir de agora
      use sempre o SSH, nunca `docker exec`.

## Comandos do dia a dia

Rode **no seu PC**, dentro de `capitulo-01/servidor`:

| Quero… | Comando |
|--------|---------|
| Ligar o servidor | `docker compose up -d` |
| Desligar (mantém tudo) | `docker compose stop` |
| Reiniciar ("reboot") | `docker compose restart` |
| Recriar depois de mudar o `compose.yaml` | `docker compose up -d` |
| Ver se está ligado | `docker compose ps` |

O servidor sobe sozinho quando o PC liga (`restart: unless-stopped`).

## O que fica guardado

O trabalho do semestre fica em **volumes**, que sobrevivem a `stop`,
`restart`, `down` e à recriação do container:

| Volume | Pasta no servidor | O que guarda |
|--------|-------------------|--------------|
| `home` | `/home` | pasta do usuário `aluno` |
| `srv` | `/srv` | dados e aplicações publicadas |
| `opt` | `/opt` | programas à parte |
| `inicio` | `/etc/inicio.d` | o que sobe junto com o servidor |
| `logs` | `/var/log` | logs |
| `chaves-ssh` | `/etc/ssh/chaves` | identidade SSH do servidor |

> ⚠️ **Nunca** use `docker compose down -v`: o `-v` apaga os volumes, ou seja,
> o servidor "formatado". Programas instalados com `apt` **fora** dessas
> pastas somem quando o container é recriado — tudo que precisarmos já vem
> na imagem.

## Problemas comuns

| Sintoma | Onde investigar |
|---------|-----------------|
| `permission denied ... docker.sock` | Seu usuário não está no grupo `docker` (veja Requisitos) |
| `Bind for 0.0.0.0:2222 failed: port is already allocated` | Outro programa usa a porta: `sudo ss -tulpn \| grep 2222` |
| `Pool overlaps with other one on this address space` | Já existe uma rede Docker em `172.30.0.0/24`: `docker network ls` |
| `Connection refused` no SSH | O container está ligado? `docker compose ps` |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | O volume `chaves-ssh` foi apagado. Rode `ssh-keygen -R "[localhost]:2222"` e `ssh-keygen -R 172.30.0.10` |
| Esqueci a senha | `docker compose exec servidor passwd aluno` |
