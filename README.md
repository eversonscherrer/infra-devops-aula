# Infra & DevOps na Prática — Do código ao usuário

Sequência de aulas hands-on de **infraestrutura, redes e DevOps**.

> Vocês **constroem** o software.
> Aqui, aprendemos a fazer esse software **sair do computador do
> desenvolvedor e chegar até o usuário**.

## A jornada

```
 Aplicação ─▶ Git/GitHub ─▶ Servidor Linux ─▶ Docker Compose ─▶ Redes ─▶ Nginx
                                                                          │
     Segurança ◀─ Monitoramento ◀─ CI/CD ◀─ HTTPS ◀─ DNS ◀────────────────┘
```

Ao final, você deve conseguir olhar para `https://projeto.exemplo.com` e
explicar de ponta a ponta: DNS, chegada ao servidor, porta 443, TLS, Nginx,
aplicação, comunicação entre containers, banco de dados, como o código chegou
ao servidor, como a atualização é automatizada, como a aplicação é
monitorada e quais cuidados de segurança foram tomados.

## Estrutura

| Pasta | Aula | Pergunta norteadora | Status |
|-------|------|---------------------|--------|
| [capitulo-01/](capitulo-01/) | Linux como Servidor | Onde nossa aplicação vai rodar? | ✅ disponível |
| [capitulo-02/](capitulo-02/) | Git e GitHub na infraestrutura | Como o código da equipe chega ao servidor? | ✅ disponível |
| capitulo-03/ | Docker Compose + Redes | Como os serviços da aplicação se comunicam? | em breve |
| capitulo-04/ | Nginx como Reverse Proxy | Como disponibilizar nossas aplicações de maneira organizada? | em breve |
| capitulo-05/ | DNS e Domínio | Como acessar a aplicação pelo nome em vez do IP? | em breve |
| capitulo-06/ | HTTPS | Como proteger a comunicação entre usuário e aplicação? | em breve |
| capitulo-07/ | CI/CD introdutório | Precisamos atualizar o servidor manualmente toda vez? | em breve |
| capitulo-08/ | Monitoramento | Como sabemos se a aplicação continua funcionando? | em breve |
| capitulo-09/ | Segurança básica | Nossa aplicação funciona, mas está minimamente segura? | em breve |

Cada capítulo tem **um PDF** (teoria + prática intercaladas), um **README**
com o roteiro e apenas os arquivos necessários para o laboratório.

## O servidor do semestre

Todas as aulas usam **o mesmo servidor**: um container Ubuntu 24.04 que faz
papel de máquina (SSH, usuários, processos, logs), criado no Capítulo 1 com
`capitulo-01/servidor/compose.yaml` e evoluído a cada encontro. O trabalho
fica em volumes — nunca use `docker compose down -v`.

👉 Comece por [`capitulo-01/preparar-servidor.md`](capitulo-01/preparar-servidor.md).

## Pré-requisitos

- Sequência **[docker-aula](https://github.com/eversonscherrer/docker-aula)**
  concluída (imagens, containers, volumes, portas, Nginx, Docker Compose)
- PC com **Linux e Docker Engine** (plugin Compose), usando Docker sem sudo
- Cliente SSH e git

## Como começar

```bash
git clone https://github.com/eversonscherrer/infra-devops-aula.git
cd infra-devops-aula/capitulo-01/servidor
docker compose up -d --build
ssh aluno@172.30.0.10
```

Abra o PDF do capítulo e siga o README.
