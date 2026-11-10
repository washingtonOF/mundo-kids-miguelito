# Auditoria de segurança Spark — matriz de testes (não publicar regras sem emulador)

## Evidência disponível
- Dois jogadores conseguiram ingressar em uma sala nova após corrigir o link de convite.
- As regras analisadas são a cópia fornecida pelo usuário, não uma leitura autenticada do estado de produção.
- O ingresso atual usa `set()` em `salas/{codigo}/vagas/vaga1..19`; o Firebase decide pelo `.write`.
- A cópia de regras limita `salas/{codigo}/.read` a UIDs presentes nas vagas, **mas** permite `.read` em cada `vagas/vaga1..19` a qualquer usuário autenticado enquanto `status == aguardando`. Isso expõe apelidos e UIDs para quem conhece o código, mesmo antes do ingresso.
- A regra `.write` de cada vaga contém verificação explícita contra duplicação de UID em todas as 20 vagas. Validar com testes de concorrência.
- Regras de respostas verificam UID e janela de tempo, mas a pontuação ainda não é calculada por servidor confiável.

## Testes obrigatórios com Firebase Emulator Suite
Criar três contas anônimas distintas: A (anfitrião), B (convidado), C (estranho), e uma sessão sem autenticação.

| Teste | Operação | Esperado |
|---|---|---|
| T01 | A cria sala | ALLOW |
| T02 | B ingressa com código | ALLOW |
| T03 | A lê sala completa | ALLOW |
| T04 | B lê sala completa | ALLOW |
| T05 | C lê sala completa | DENY |
| T06 | Sem autenticação lê sala | DENY |
| T07 | C lê vaga1 enquanto sala aguarda | **ALLOW nas regras atuais: vazamento conhecido** |
| T08 | B tenta ocupar segunda vaga | DENY |
| T09 | C tenta sobrescrever vaga de B | DENY |
| T10 | C tenta escrever resposta de B | DENY |
| T11 | C tenta iniciar partida | DENY |
| T12 | A inicia com 2 jogadores | ALLOW |
| T13 | C tenta entrar após início | DENY |
| T14 | B tenta alterar pontos de A | DENY |
| T15 | Duas entradas simultâneas na mesma vaga | No máximo uma ALLOW |

## Risco adicional
Regras de RTDB `.read` e `.write` concedidas em ancestrais são herdadas e não podem ser revogadas em descendentes. Revisar a expressão de `.write` na sala, que contém cláusulas OR, para assegurar que não autoriza operações inesperadas sobre nós filhos.

## Próxima correção estrutural
Separar índice público de ingresso (sem nomes nem UID expostos) dos dados privados dos participantes. Não substituir as regras em produção sem prototipar o ingresso e rodar testes de emulador.

## Estado
Auditoria estática realizada; testes de autorização no emulador e contra produção ainda **não executados**. Nenhuma regra foi publicada por esta auditoria.
