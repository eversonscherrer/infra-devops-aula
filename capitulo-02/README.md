# Capítulo 02 — Git e GitHub na infraestrutura

> **Pergunta norteadora:** como o código desenvolvido pela equipe chega ao servidor?

## Objetivo

Publicar o código do grupo no GitHub, fazer o **deploy** no servidor do
semestre com `git clone` e atualizá-lo com `git pull`, diagnosticando um
pull que falhou por causa de uma alteração feita direto no servidor — sem
perder nada. No fim, o servidor recebe código **só pelo caminho oficial**:
PC → commit → push → GitHub → pull.

## Conteúdo

- Git x GitHub · repositório e commit
- O caminho do código: `clone`, `commit`, `push`, `pull`
- Git na rede: DNS, TCP, HTTPS (443) x SSH (22)
- Deploy e produção · o servidor como **cópia**
- Investigar sem alterar: `status`, `diff`, `log`, `fetch`
- Alterações locais, `restore` e `pull --ff-only`

## Material

📄 [`02-git-github-infraestrutura.pdf`](./02-git-github-infraestrutura.pdf) — teoria + prática intercaladas (23 slides)

## Prática

**Missão: primeiro deploy do grupo.** O grupo publica sua página no GitHub
e coloca o repositório em produção em `/srv/app-turma` (servida pela
`app-turma`, porta 8080, do Capítulo 1). Na hora de atualizar, o `git pull`
é abortado. Alguém mexeu no servidor. Investigue, preserve o que precisa
ser preservado e deixe a produção sincronizada com o GitHub.

### Roteiro rápido — marque conforme for fazendo

#### Etapa 1 — Publicar o código do grupo (no seu PC)

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"

# no GitHub: New repository → projeto-grupoN → Public → Add a README
git clone https://github.com/USUARIO/projeto-grupoN.git
cd projeto-grupoN
# copie site-modelo/index.html para cá e personalize
git add index.html
git commit -m "Primeira versão do site"
git push
```

- [ ] O `index.html` e o commit aparecem na página do repositório no GitHub

#### Etapa 2 — O servidor também usa git

```bash
ssh aluno@172.30.0.10
git --version
git clone https://github.com/eversonscherrer/infra-devops-aula.git
cd infra-devops-aula
git log --oneline
git remote -v
getent hosts github.com
GIT_TRACE_CURL=1 git ls-remote https://github.com/eversonscherrer/infra-devops-aula.git \
  2>&1 | grep -E "Connected to|SSL connection|GET /|HTTP/2 200"
```

- [ ] Sei dizer qual IP, porta e protocolo o git usou para falar com o GitHub

> 💡 De agora em diante, no início de cada aula:
> `cd ~/infra-devops-aula && git pull`

#### Etapa 3 — Missão: primeiro deploy

```bash
cd ~/infra-devops-aula
sudo bash capitulo-02/lab02.sh preparar https://github.com/USUARIO/projeto-grupoN.git
cd /srv/app-turma
git log --oneline
```

- [ ] `http://172.30.0.10:8080` abre a página do grupo no navegador do **meu PC**

#### Etapa 4 — Atualizar a produção

No **PC**: troque `Integrante 1` pelos nomes do grupo, `commit` e `push`.
No **servidor**:

```bash
cd /srv/app-turma
git pull
```

- [ ] Respondi o roteiro de investigação do PDF **antes** de corrigir
- [ ] `sudo bash ~/infra-devops-aula/capitulo-02/lab02.sh verificar` mostra as 5 linhas da missão com `[OK]`

> 💡 Combinado: não abra o `lab02.sh` para procurar a resposta. E nada de
> apagar a pasta e clonar de novo — descubra primeiro **o que** você apagaria.

#### Etapa 5 — Desafio final

- [ ] Cada integrante fez pelo menos 1 commit do próprio PC e conta
- [ ] `deploy.sh` criado **no PC** e versionado no repositório
- [ ] Nova alteração publicada usando só `push` + `bash deploy.sh`
- [ ] `lab02.sh verificar` → **8 de 8**

## Arquivos

| Arquivo | O que é |
|---------|---------|
| `02-git-github-infraestrutura.pdf` | Slides da aula: teoria + prática |
| `site-modelo/index.html` | Página inicial do repositório do grupo (personalize e publique) |
| `lab02.sh` | Faz o deploy do repositório do grupo (`preparar URL`), confere a missão (`verificar`) e desfaz o deploy (`limpar`) |
| `ficha-deploy.md` | Modelo da ficha de deploy: a **evidência** da aula |

## Pré-requisitos

- [Capítulo 01](../capitulo-01/) concluído: servidor `srv-<grupo>` ligado e acessível por SSH
- **Conta no GitHub** para cada integrante (crie antes da aula)
- **Git instalado no PC**: https://git-scm.com/downloads (`git --version` para conferir)
- Repositório do grupo **público**. Se o projeto precisar ser privado, fale com o professor.

---

## Pergunta rápida da aula

No servidor, `git pull` responde `Already up to date`. O colega jura que mudou
o site e fez o commit. Qual é a causa mais provável?

- A) O servidor está sem acesso à internet
- B) O commit ficou só no PC do colega: faltou o push
- C) A porta 8080 está fechada no servidor
- D) O git pull só funciona com sudo

<details>
<summary>Resposta</summary>

**B** — `commit` registra a versão **apenas na máquina de quem fez**. Enquanto
não houver `push`, o GitHub não conhece esse commit e o servidor não tem de
onde buscá-lo. Sem internet (A), o pull daria erro de conexão, não
"Already up to date". A porta 8080 (C) não participa do pull.
</details>

---

## Próxima aula

O código chega ao servidor… mas a aplicação real tem frontend, backend e
banco de dados. **Capítulo 03 — Docker Compose + Redes:** como os serviços da
aplicação se comunicam? Traga o repositório da aplicação que vocês
estão desenvolvendo.
