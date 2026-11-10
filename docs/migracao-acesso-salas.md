# Migração: salas somente para membros (branch de preparação)

## Não aplicar estas regras isoladamente
O aplicativo atual consulta `salas/{codigo}` antes de entrar e grava `vagas/vagaN` diretamente. Uma regra que restringe a leitura a membros interromperia o ingresso atual. A migração precisa ser coordenada.

## Contrato proposto
- `salas/{codigo}/membros/{uid}: true`: índice de membros, mantido exclusivamente pelo backend confiável.
- `salas/{codigo}/vagas/vagaN`: nome/apelido e UID do participante.
- Criação e ingresso via endpoints autenticados (Cloud Functions callable ou backend equivalente).
- Backend deve validar código, nome (1–30 caracteres), estado `aguardando`, limite de 20 vagas e duplicidade de UID, com transação atômica.
- Cliente não pode criar, excluir ou alterar `membros` diretamente.
- Dados de convite e verificação de código devem ser mínimos e não revelar nomes ou respostas.

## Regra de leitura pretendida (somente depois do novo ingresso)
```json
{
  "rules": {
    "salas": {
      "$codigo": {
        ".read": "auth != null && data.child('membros').child(auth.uid).val() === true"
      }
    }
  }
}
```
A regra acima é um **fragmento ilustrativo**, não um arquivo completo para publicação. Preservar e revisar todas as regras de escrita/validação existentes.

## Dependências de implantação
1. Confirmar disponibilidade de backend confiável e credenciais de deploy. Cloud Functions pode exigir plano Blaze e cobrança configurada.
2. Implementar operações de criação e ingresso com testes de concorrência.
3. Migrar Flutter para chamar as operações sem ler a sala antecipadamente.
4. Implementar regras completas de acesso, validar com Emulator Suite.
5. Publicar backend, cliente e regras em ordem segura; preparar rollback.
6. Testar criador, participante, estranho autenticado e não autenticado.

## Critérios de aceite
- Usuário autenticado fora da sala não lê dados internos.
- Jogador com convite válido ingressa sem precisar ler a sala antecipadamente.
- Mesmo UID não ocupa duas vagas.
- Não é possível ocupar a 21ª vaga.
- Jogador não altera o índice de membros.
- Host e convidados continuam jogando até o final.
