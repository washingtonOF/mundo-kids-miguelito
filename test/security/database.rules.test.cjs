const { test, after } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');

// Exportar regras PUBLICADAS do Console para security/database.rules.json.
// Nunca executar testes destrutivos contra o banco de produção.
const rulesPath = 'security/database.rules.candidate.json';
if (!fs.existsSync(rulesPath)) {
  throw new Error('Regras ausentes: exporte a versão publicada para ' + rulesPath);
}
const rules = fs.readFileSync(rulesPath, 'utf8');
let env;
const room = 'ABC234';
const creator = { uid: 'criador', nome: 'Criador', pontos: 0 };
const guest = { uid: 'convidado', nome: 'Convidado', pontos: 0 };

async function setup() {
  env = await initializeTestEnvironment({
    projectId: 'demo-miguelzao-security',
    database: { rules, host: '127.0.0.1', port: 9000 }
  });
  await env.withSecurityRulesDisabled(async ctx => {
    await ctx.database().ref('salas/' + room).set({
      criador: creator.uid, status: 'aguardando', maxJogadores: 20,
      criadaEm: 1, tempoPergunta: 20, tipo: 'matematica',
      vagas: { vaga0: creator }
    });
  });
}
const db = uid => env.authenticatedContext(uid).database();
test('autorização de sala e vagas', async () => {
  await setup();
  const path = 'salas/' + room;
  await assertSucceeds(db('criador').ref(path).get());
  await assertFails(db('estranho').ref(path).get());
  await assertFails(env.unauthenticatedContext().database().ref(path).get());
  await assertSucceeds(db('convidado').ref(path + '/vagas/vaga1').set(guest));
  await assertSucceeds(db('convidado').ref(path).get());
  await assertFails(db('convidado').ref(path + '/vagas/vaga2').set(guest));
  await assertFails(db('estranho').ref(path + '/vagas/vaga1').set({
    uid: 'estranho', nome: 'Ataque', pontos: 0
  }));
  // Teste de privacidade: terceiros não podem consultar dados de vagas.
  await assertFails(db('estranho').ref(path + '/vagas/vaga1').get());

  // Apenas o criador pode iniciar, com dois jogadores.
  await assertFails(db('convidado').ref(path + '/status').set('jogando'));
  await assertFails(db('estranho').ref(path + '/inicioEm').set(Date.now()));
  const inicio = Date.now();
  await assertSucceeds(db('criador').ref(path).update({
    status: 'jogando', inicioEm: inicio
  }));
  await assertFails(db('estranho').ref(path + '/vagas/vaga2').set({
    uid: 'estranho', nome: 'Intruso', pontos: 0
  }));

  // Cada jogador registra uma única resposta na rodada atual.
  const resposta = { alternativa: 1, respondidoEm: Date.now() };
  await assertSucceeds(db('convidado').ref(path + '/respostas/0/convidado').set(resposta));
  await assertFails(db('convidado').ref(path + '/respostas/0/convidado').set(resposta));
  await assertFails(db('estranho').ref(path + '/respostas/0/estranho').set(resposta));
  await assertFails(db('convidado').ref(path + '/respostas/0/criador').set(resposta));
  await assertFails(db('convidado').ref(path + '/respostas/0/convidado2').set({
    alternativa: 5, respondidoEm: Date.now()
  }));
  await assertFails(db('convidado').ref(path + '/vagas/vaga0/pontos').set(999));
  await assertFails(db('convidado').ref(path + '/vagas/vaga1/pontos').set(999));
});
after(async () => { if (env) await env.cleanup(); });
