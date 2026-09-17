# Ficha de Deploy — Capítulo 02

> Evidência da aula. Preencha **com dados do seu grupo e do seu servidor**,
> não com os exemplos dos slides. Em cada campo, anote também o comando usado.

## 1. Identificação

| Campo | Valor | Comando |
|-------|-------|---------|
| Grupo / integrantes | | — |
| Data | | — |
| Hostname do servidor | | |
| Link do repositório no GitHub | | — |
| Branch principal | | |
| Versão do git no servidor | | |

## 2. O caminho do código

Complete com o comando e **onde** ele foi executado (PC ou servidor):

| Ação | Comando | Onde |
|------|---------|------|
| Baixar o repositório pela primeira vez | | |
| Registrar uma versão | | |
| Enviar versões para o GitHub | | |
| Trazer versões novas do GitHub | | |

## 3. Git na rede

| Campo | Valor | Comando |
|-------|-------|---------|
| IP do `github.com` visto pelo servidor | | |
| IP na linha `Connected to` do trace | | |
| Porta e protocolo de transporte usados | | |
| Versão do TLS | | |
| URL do `origin` no servidor | | |
| O pull precisou de senha? Por quê? | | — |

## 4. Deploy

| Campo | Valor | Comando |
|-------|-------|---------|
| Pasta de produção | | — |
| Dono da pasta (usuário) | | |
| Serviço e porta que publicam a pasta | | |
| Commit no ar logo após o deploy (hash + mensagem) | | |

## 5. Missão: o pull abortado

| Pergunta | Resposta |
|----------|----------|
| Sintoma observado (mensagem do git) | |
| O que o `git status` mostrou | |
| O que o `git diff` mostrou (resuma) | |
| Quando o arquivo foi alterado e pista de quem alterou | |
| A alteração existia no GitHub? Como descobriu? | |
| Causa do problema, em uma frase | |
| Comandos usados na correção, **na ordem** (indique PC ou servidor) | |
| Como provei que ficou resolvido | |

## 6. Investigação

1. Por que o git abortou o pull em vez de sobrescrever o arquivo?

   >

2. Se você rodasse `git restore` logo de cara, o que o cliente perderia?

   >

3. Se o servidor pegar fogo hoje, o que se perde e o que se recupera? Por quê?

   >

4. O servidor precisou de senha para o `pull`? E precisaria para um `push`?

   >

5. Que porta e protocolo o `clone` usou? E se a URL fosse `git@github.com:…`?

   >

6. Abra `http://172.30.0.10:8080/.git/config`. O que apareceu? Isso é um problema?

   >

## 7. Desafio: deploy em um comando

Cole o conteúdo do `deploy.sh`:

```bash
(cole aqui)
```

Para que serve o `--ff-only`?

>

Cole a saída de `git log --format='%h %an %s'` no servidor:

```
(cole aqui)
```

## 8. Saída do verificador

Cole aqui o resultado de `sudo bash ~/infra-devops-aula/capitulo-02/lab02.sh verificar`:

```
(cole aqui)
```

## 9. Conclusão

> Hoje eu consegui ______________________________________________
> e entendi que _________________________________________________.
