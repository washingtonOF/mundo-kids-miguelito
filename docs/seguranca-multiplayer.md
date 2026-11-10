# Plano de segurança — Multiplayer Miguelzãoo

## Estado atual (10/11/2026)
- Firebase Authentication anônimo.
- Realtime Database: `salas/{codigo}`.
- Entrada por código de seis caracteres, até 20 vagas.
- Regras atuais exigem autenticação e protegem respostas contra sobrescrita.
- **Problema conhecido:** `.read: auth != null && data.exists()` permite que qualquer conta autenticada leia uma sala existente se conhecer seu código.
- A pontuação é calculada no cliente a partir das respostas e horários. **Não é um placar autoritativo** e não deve ser usada para competição com premiações.
- Não há limpeza automática garantida das salas concluídas.

## Migração proposta (não aplicar regras isoladamente)
1. Criar nó de convites com metadados mínimos, sem nomes ou respostas: `convites/{codigo}`. Expor apenas existência/status para validação do código, com proteção contra tentativas excessivas (App Check e limites no backend).
2. Criar operação confiável de ingresso (Cloud Function ou backend autenticado) que valida o convite e adiciona o UID à lista de membros de maneira atômica, respeitando o limite de 20.
3. Alterar o Flutter para chamar essa operação em vez de ler `salas/{codigo}` antes de entrar.
4. Restringir leitura da sala a `auth.uid` registrado entre os membros. Testar com UID criador, participante, autenticado estranho e não autenticado.
5. Migrar cálculo e persistência de pontos para backend confiável. Não enviar gabarito ou aceitar pontuação do cliente como verdade. Respostas devem ter uma por jogador/rodada e janela de tempo validada pelo servidor.
6. Adicionar encerramento de sala, expiração e limpeza agendada. Definir retenção mínima, especialmente por envolver crianças.
7. Testar regras no Firebase Emulator Suite antes de publicar e fazer rollout coordenado do app e das regras.

## Matriz mínima de testes
| Cenário | Esperado |
|---|---|
| Sem autenticação lê sala | Negado |
| Autenticado não membro lê sala | Negado (após migração) |
| Membro lê sala | Permitido |
| Convidado entra com código válido | Permitido via operação de ingresso |
| Código inválido ou expirado | Negado |
| Participante altera pontos | Negado |
| Participante altera resposta já enviada | Negado |
| Participante responde fora da janela | Negado |
| Participante inicia campeonato | Negado |
| Criador inicia com menos de 2 jogadores | Negado |
| Sala recebe jogador 21 | Negado |
| Sala encerrada aceita resposta | Negado |

## Observações
- Não publicar regras que restrinjam `salas/$codigo/.read` antes de atualizar o fluxo de ingresso.
- Regras de Firebase não substituem lógica de pontuação no servidor.
- Usar apenas apelidos, evitar dados pessoais desnecessários e não registrar respostas identificáveis em logs de produção.
- Testar com duas sessões anônimas independentes e uma terceira sessão não participante.
