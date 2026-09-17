# Ficha do Servidor — Capítulo 01

> Evidência da aula. Preencha **com dados do seu servidor**, não com os
> exemplos dos slides. Em cada campo, anote também o comando usado.

## 1. Identificação

| Campo | Valor | Comando |
|-------|-------|---------|
| Grupo / integrantes | | — |
| Data | | — |
| Hostname (antes do desafio) | | |
| Hostname (depois do desafio) | | |
| Sistema operacional e versão | | `cat /etc/os-release` |
| Versão do kernel | | `uname -r` |
| Usuário de acesso | | |
| Porta do SSH publicada no meu PC | | `docker compose ps` |

## 2. Rede

| Campo | Valor | Comando |
|-------|-------|---------|
| Interface de rede principal | | |
| IP / máscara do servidor | | |
| Endereço MAC | | |
| Gateway padrão | | |
| Interface e IP do **meu PC** na rede do servidor | | |
| IP do **meu PC** na rede da escola | | |
| Porta usada no SSH | | |

### Diagnóstico em camadas

| Teste | Funcionou? (sim/não) | O que isso prova |
|-------|----------------------|------------------|
| `ping -c 4 <gateway>` | | |
| `ping -c 4 8.8.8.8` | | |
| `ping -c 4 github.com` | | |
| `curl -I https://github.com` | | |

## 3. Recursos

| Recurso | No servidor | No meu PC | Comando |
|---------|-------------|-----------|---------|
| Núcleos de CPU | | | |
| Memória total / disponível | | | |
| Disco `/`: tamanho / uso % | | | |
| Versão do kernel | | | |
| Quantidade de processos | | | `ps aux \| wc -l` |

Por que alguns valores são iguais e outros tão diferentes?

>

## 4. Portas em escuta

Depois de concluir a missão, rode `sudo ss -tulpn` e preencha:

| Porta | TCP/UDP | Endereço de escuta | Processo | Acessível de outro PC? |
|-------|---------|--------------------|----------|------------------------|
| | | | | |
| | | | | |
| | | | | |

## 5. Minha conexão SSH

| Campo | Valor |
|-------|-------|
| Linha `ESTAB` do `ss -tn` | |
| Linha do meu login no `/var/log/auth.log` | |
| O IP e a porta de origem batem? | |

## 6. Missão: o servidor herdado

| Pergunta | Resposta |
|----------|----------|
| Sintoma observado | |
| A `app-turma` estava rodando? (e comando) | |
| Mensagem de erro encontrada no log (arquivo e linha) | |
| Quem ocupava a porta 8080 (processo, PID e usuário) | |
| Árvore desse processo, do pai até ele | |
| Como esse processo subia no boot | |
| Causa do problema, em uma frase | |
| Comandos usados na correção | |
| Como provei que ficou resolvido | |

## 7. Investigação

1. Por que `kill` no python não resolveu o problema de vez?

   >

2. Se você só matasse o vigia, o que aconteceria no próximo boot?

   >

3. A app escuta em `0.0.0.0:8080`. E se fosse `127.0.0.1:8080`, quem conseguiria acessar?

   >

4. Por que dois processos não podem escutar na mesma porta do mesmo IP?

   >

5. No `/var/log/app-turma.log`, de qual IP veio o acesso do seu navegador?

   >

6. Por que a `app-turma` roda como `www-data` e não como `root`?

   >

7. Para trocar o hostname o container foi recriado. Por que a página editada
   e as correções da missão continuaram lá?

   >

## 8. Saída do verificador

Cole aqui o resultado de `sudo bash lab01.sh verificar`:

```
(cole aqui)
```

## 9. Conclusão

> Hoje eu consegui ______________________________________________
> e entendi que _________________________________________________.
