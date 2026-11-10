# Firebase Spark: controle de acesso sem Cloud Functions

## Situação
O Spark permite Firebase Authentication anônimo e Realtime Database com regras. Não precisamos de Cloud Functions para restringir **leitura** de salas a UIDs que já estejam em vagas. Entretanto, ingresso público por código exige uma exceção cuidadosamente limitada, e as regras atuais do projeto devem ser integradas, não substituídas às cegas.

## Mudança de cliente já preparada nesta branch
`entrarSala` deixou de fazer `get()` em `salas/{codigo}` antes de ingressar. Tenta transações nas vagas 1–19. Não publicar essa alteração isoladamente; transações requerem leitura no nó da vaga.

## Estratégia Spark
1. Manter o criador em `vaga0` e jogadores em `vaga1` a `vaga19`.
2. Regra de leitura da **sala inteira**: exigir `auth != null` e que `auth.uid` corresponda ao `uid` de alguma das 20 vagas. A expressão deve ser gerada explicitamente para as 20 posições (sem wildcard com busca dinâmica).
3. Para permitir ingresso por código sem ler a sala, oferecer leitura limitada às vagas individuais, apenas para usuários autenticados. **Isso revela apelidos/UIDs dessas vagas a quem conhece o código**, portanto é uma concessão de privacidade. Melhor evolução: usar nós de ocupação sem apelidos, separar perfis privados e permitir transações somente nesse índice.
4. Nas regras de escrita de `vagas/vagaN`, exigir sala existente, status `aguardando`, vaga vazia, `newData.child('uid').val() === auth.uid`, apelido válido e campos permitidos. Impedir remoção e edição posterior, e garantir que não haja duas vagas com mesmo UID. Essa última garantia é difícil com 20 transações independentes e requer checagem explícita de todas as vagas.
5. Proibir criação ou edição direta de uma lista de membros controlada pelo cliente. Não aceitar `pontos` escritos pelo cliente como placar confiável.
6. Testar as regras reais com Emulator Suite e duas contas anônimas distintas, além de uma terceira conta estranha.

## Limitação importante
No Spark, **não há uma operação de ingresso privilegiada por servidor** dentro desse desenho. Se o código da sala for conhecido, um usuário autenticado pode tentar entrar enquanto houver vagas. O código funciona como convite de posse, não como autorização individual pré-aprovada. Para acesso apenas por pessoas pré-aprovadas é necessário um processo adicional de aprovação pelo anfitrião ou backend confiável.

## Critérios para publicação
- Regras atuais completas copiadas para arquivo versionado no repositório.
- Testes automatizados de acesso anônimo, terceiro autenticado, anfitrião, convidado, vaga cheia e resposta duplicada.
- Testes positivos em celular e navegador.
- Rollout coordenado do cliente e regras, com backup das regras anteriores.

## Próxima decisão
Para minimizar exposição de nomes, implementar um nó separado de reivindicação de vagas sem apelidos, e manter os apelidos somente dentro de `salas/{codigo}` visível aos membros. Isso exige migração coordenada e testes antes de qualquer alteração na produção.
