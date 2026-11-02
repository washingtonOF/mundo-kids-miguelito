import 'banco_conteudo.dart' as banco;
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'voz_miguelito.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'configuracoes_jogo.dart';

class JogosExtras extends StatelessWidget {
  const JogosExtras({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('⭐ Mais aventuras')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final item in [
          ('🔤 Português', const JogoQuiz(tipo: 'Português')),
          ('🧠 Memória', const JogoMemoria()),
          ('🎨 Cores e formas', const JogoQuiz(tipo: 'Cores e formas')),
          ('🏆 Batalha de equipes', const ConfigurarEquipes()),
        ])
          Card(
            child: ListTile(
              title: Text(item.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.$2),
              ),
            ),
          ),
      ],
    ),
  );
}

class Pergunta {
  final String texto;
  final List<String> alternativas;
  final int correta;
  const Pergunta(this.texto, this.alternativas, this.correta);
}

const perguntasPortugues = [
  Pergunta('Qual palavra está escrita corretamente?', [
    'Caza',
    'Casa',
    'Cassa',
    'Cassa',
  ], 1),
  Pergunta('Qual é a primeira letra de BOLA?', ['A', 'B', 'L', 'O'], 1),
  Pergunta('Quantas sílabas tem SAPATO?', ['1', '2', '3', '4'], 2),
  Pergunta('Qual é o plural de FLOR?', [
    'Floras',
    'Flores',
    'Florão',
    'Flor',
  ], 1),
  Pergunta('Qual palavra rima com PÃO?', ['Mão', 'Sol', 'Lua', 'Casa'], 0),
  Pergunta('Complete: O gato ___ leite.', [
    'bebem',
    'bebe',
    'beberam',
    'bebemos',
  ], 1),
  Pergunta('Qual palavra é um animal?', [
    'Mesa',
    'Livro',
    'Cachorro',
    'Janela',
  ], 2),
  Pergunta('Qual é o contrário de ALTO?', [
    'Grande',
    'Baixo',
    'Longo',
    'Forte',
  ], 1),
  Pergunta('Qual frase termina com uma pergunta?', [
    'Bom dia.',
    'Que legal!',
    'Como você está?',
    'Vamos brincar.',
  ], 2),
  Pergunta('Qual palavra tem 4 letras?', ['Sol', 'Bola', 'Caderno', 'Pé'], 1),
];
const perguntasCores = [
  Pergunta('🔴 Qual é esta cor?', ['Azul', 'Verde', 'Vermelho', 'Amarelo'], 2),
  Pergunta('🔺 Qual é esta forma?', [
    'Círculo',
    'Quadrado',
    'Triângulo',
    'Retângulo',
  ], 2),
  Pergunta('🔵 Qual é esta cor?', ['Azul', 'Rosa', 'Laranja', 'Roxo'], 0),
  Pergunta('⬛ Quantos lados tem um quadrado?', ['2', '3', '4', '5'], 2),
  Pergunta('🟡 Qual é esta cor?', ['Verde', 'Amarelo', 'Preto', 'Azul'], 1),
  Pergunta('⚪ Qual forma não tem lados retos?', [
    'Triângulo',
    'Quadrado',
    'Círculo',
    'Retângulo',
  ], 2),
  Pergunta('🔴 + 🟡: misturando vermelho e amarelo, obtemos...', [
    'Verde',
    'Laranja',
    'Azul',
    'Roxo',
  ], 1),
  Pergunta('🟩 Qual é esta cor?', ['Verde', 'Azul', 'Amarelo', 'Rosa'], 0),
  Pergunta('Qual figura tem três lados?', [
    'Círculo',
    'Quadrado',
    'Triângulo',
    'Pentágono',
  ], 2),
  Pergunta('🔷 Qual cor aparece nesta figura?', [
    'Vermelho',
    'Azul',
    'Verde',
    'Laranja',
  ], 1),
];
const perguntasMatematica = [
  Pergunta('Quanto é 4 + 5?', ['8', '9', '10', '11'], 1),
  Pergunta('Quanto é 12 - 7?', ['4', '5', '6', '7'], 1),
  Pergunta('Quanto é 3 × 4?', ['7', '12', '14', '16'], 1),
  Pergunta('Quanto é 20 ÷ 5?', ['2', '3', '4', '5'], 2),
  Pergunta('Qual número vem depois do 29?', ['28', '31', '30', '39'], 2),
];

class JogoQuiz extends StatefulWidget {
  final String tipo;
  const JogoQuiz({super.key, required this.tipo});
  @override
  State<JogoQuiz> createState() => _JogoQuizState();
}

class _JogoQuizState extends State<JogoQuiz> {
  final FlutterTts _vozMiguelito = FlutterTts();

  bool get ingles => ConfiguracoesJogo.instancia.idioma == 'en-US';

  int indice = 0;
  int pontos = 0;
  bool respondeu = false;
  int? selecionada;

  late final List<Pergunta> perguntas = (() {
    final categoria = widget.tipo == 'Português' ? 'portugues' : 'cores';
    final originais = widget.tipo == 'Português' ? perguntasPortugues : perguntasCores;
    final todas = <Pergunta>[
      ...originais,
      for (final q in banco.questoesExtras[categoria]!)
        Pergunta(q.texto, q.opcoes, q.correta),
    ]..shuffle(Random());
    return todas.take(10).toList();
  })();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _falarPergunta();
    });
  }

  String _prepararTexto(String texto) {
    return texto
        .replaceAll('🔴', 'círculo vermelho')
        .replaceAll('🔵', 'círculo azul')
        .replaceAll('🟡', 'círculo amarelo')
        .replaceAll('🟩', 'quadrado verde')
        .replaceAll('🔺', 'triângulo vermelho')
        .replaceAll('⬛', 'quadrado preto')
        .replaceAll('⚪', 'círculo branco')
        .replaceAll('🔷', 'losango azul')
        .replaceAll(' + ', ' mais ');
  }

  Future<void> _falarPergunta() async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;
    if (!mounted || respondeu || indice >= perguntas.length) return;

    final indiceAtual = indice;
    final pergunta = perguntas[indiceAtual];

    final prefs = await SharedPreferences.getInstance();

    if (!mounted || indiceAtual != indice || respondeu) return;

    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final alternativas = pergunta.alternativas
        .asMap()
        .entries
        .map((item) => '${ingles ? 'Option' : 'Opção'} ${String.fromCharCode(65 + item.key)}: ${_prepararTexto(item.value)}.')
        .join(' ');

    final mensagem =
        '${nome.isNotEmpty ? '$nome, ' : ''}${ingles ? 'Let’s go! ' : 'Vamos lá! '}'
        '${_prepararTexto(pergunta.texto)} '
        '$alternativas';

    await _vozMiguelito.stop();
    await VozMiguelito.configurar(_vozMiguelito);

    if (!mounted || indiceAtual != indice || respondeu) return;

    await _vozMiguelito.speak(mensagem);
  }

  Future<void> _falarResultado(bool acertou) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final mensagem = ingles
        ? (acertou ? 'Great job${nome.isNotEmpty ? ', $nome' : ''}! Correct answer!' : 'Keep trying${nome.isNotEmpty ? ', $nome' : ''}! The correct answer is ${perguntas[indice].alternativas[perguntas[indice].correta]}.')
        : acertou
        ? 'Parabéns${nome.isNotEmpty ? ', $nome' : ''}! '
              'Você acertou! Muito bem!'
        : 'Não foi dessa vez${nome.isNotEmpty ? ', $nome' : ''}! '
              'A resposta correta é ${_prepararTexto(perguntas[indice].alternativas[perguntas[indice].correta])}. Continue tentando!';

    await _vozMiguelito.stop();
    await VozMiguelito.configurar(_vozMiguelito);
    if (!mounted) return;
    await _vozMiguelito.speak(mensagem);
  }

  void _responder(int resposta) {
    if (respondeu) return;

    final acertou = resposta == perguntas[indice].correta;

    setState(() {
      selecionada = resposta;
      respondeu = true;
      if (acertou) pontos += 10;
    });

    _falarResultado(acertou);
  }

  void _proxima() {
    setState(() {
      indice++;
      respondeu = false;
      selecionada = null;
    });

    if (indice < perguntas.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _falarPergunta();
      });
    } else {
      _vozMiguelito.stop();
    }
  }

  @override
  void dispose() {
    _vozMiguelito.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (indice >= perguntas.length) {
      return Scaffold(
        appBar: AppBar(title: Text(ingles ? '🏆 Results' : '🏆 Resultado')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ingles ? '🎉 You earned $pontos points!' : '🎉 Você fez $pontos pontos!',
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(ingles ? 'Back to games' : 'Voltar aos jogos'),
              ),
            ],
          ),
        ),
      );
    }

    final p = perguntas[indice];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E5),
      appBar: AppBar(title: Text(ingles ? (widget.tipo == 'Português' ? 'Portuguese' : 'Colors and shapes') : widget.tipo)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              LinearProgressIndicator(value: (indice + 1) / perguntas.length),
              const SizedBox(height: 20),
              Text(
                ingles ? 'Question ${indice + 1}/${perguntas.length}   ⭐ $pontos points' : 'Questão ${indice + 1}/${perguntas.length}   ⭐ $pontos pontos',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 25),
              Text(
                p.texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              if (ConfiguracoesJogo.instancia.instrucoesAudio)
                Center(
                  child: FilledButton.icon(
                    onPressed: respondeu ? null : _falarPergunta,
                    icon: const Icon(Icons.volume_up),
                    label: Text(ingles ? 'Listen to question and answers' : 'Ouvir pergunta e alternativas'),
                  ),
                ),
              const SizedBox(height: 25),
              for (int i = 0; i < p.alternativas.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.tonal(
                    onPressed: respondeu ? null : () => _responder(i),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        p.alternativas[i],
                        style: const TextStyle(fontSize: 21),
                      ),
                    ),
                  ),
                ),
              if (respondeu) ...[
                Text(
                  selecionada == p.correta
                      ? (ingles ? '🎉 Well done! +10 points' : '🎉 Muito bem! +10 pontos')
                      : (ingles ? '💡 Answer: ${p.alternativas[p.correta]}' : '💡 Resposta: ${p.alternativas[p.correta]}'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: _proxima,
                  child: Text(ingles ? 'Next question' : 'Próxima pergunta'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class JogoMemoria extends StatefulWidget {
  const JogoMemoria({super.key});
  @override
  State<JogoMemoria> createState() => _JogoMemoriaState();
}

class _JogoMemoriaState extends State<JogoMemoria> {
  final FlutterTts _vozMemoria = FlutterTts();

  final Map<String, String> nomesAnimais = {
    '🐶': 'cachorro',
    '🐱': 'gato',
    '🐸': 'sapo',
    '🦋': 'borboleta',
    '🐼': 'panda',
    '🦁': 'leão',
  };

  void _repetirInstrucoes() {
    _falarMemoria('Vire duas cartas e encontre os animais iguais. Toque em uma carta para começar!');
  }

  Future<void> _falarMemoria(String mensagem) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;
    if (!mounted) return;

    await _vozMemoria.stop();
    await _vozMemoria.setLanguage('pt-BR');
    await VozMiguelito.configurar(_vozMemoria);

    if (!mounted) return;
    await _vozMemoria.speak(mensagem);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final nome = prefs.getString('nome_crianca')?.trim() ?? '';

      _falarMemoria(
        'Olá${nome.isNotEmpty ? ', $nome' : ''}! '
        'Vamos brincar de memória? '
        'Vire duas cartas e tente encontrar os animais iguais!',
      );
    });
  }

  @override
  void dispose() {
    _vozMemoria.stop();
    super.dispose();
  }

  final List<String> cartas = [
    ...['🐶', '🐱', '🐸', '🦋', '🐼', '🦁'],
    ...['🐶', '🐱', '🐸', '🦋', '🐼', '🦁'],
  ]..shuffle();
  final Set<int> achadas = {};
  int? primeira, segunda;
  int tentativas = 0;
  bool bloqueado = false;

  void escolher(int i) {
    if (bloqueado || achadas.contains(i) || primeira == i) return;

    final nomeAnimal = nomesAnimais[cartas[i]] ?? 'animal';

    if (primeira == null) {
      setState(() {
        primeira = i;
      });

      _falarMemoria('Você encontrou um $nomeAnimal!');
      return;
    }

    final a = primeira!;
    final b = i;
    final acertou = cartas[a] == cartas[b];

    setState(() {
      segunda = i;
      tentativas++;
      bloqueado = true;
    });

    _falarMemoria(
      acertou
          ? 'Muito bem! Você encontrou um par de $nomeAnimal!'
          : 'Essas cartas são diferentes. Continue tentando!',
    );

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      setState(() {
        if (acertou) achadas.addAll([a, b]);
        primeira = null;
        segunda = null;
        bloqueado = false;
      });

      if (acertou && achadas.length == cartas.length) {
        _falarMemoria(
          'Parabéns! Você encontrou todos os pares! Você é incrível!',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🧠 Jogo da Memória')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achadas.length == cartas.length
                  ? '🏆 Parabéns! Você encontrou todos os pares!'
                  : 'Encontre os pares! • Tentativas: $tentativas',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21),
            ),
            const SizedBox(height: 12),
            if (ConfiguracoesJogo.instancia.instrucoesAudio)
              TextButton.icon(
                onPressed: _repetirInstrucoes,
                icon: const Icon(Icons.volume_up),
                label: const Text('Ouvir instruções novamente'),
              ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: cartas.length,
              itemBuilder: (_, i) => InkWell(
                onTap: () => escolher(i),
                child: Card(
                  color: achadas.contains(i)
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  child: Center(
                    child: Text(
                      achadas.contains(i) || primeira == i || segunda == i
                          ? cartas[i]
                          : '❔',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
            if (achadas.length == cartas.length)
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const JogoMemoria()),
                ),
                child: const Text('Jogar novamente'),
              ),
          ],
        ),
      ),
    ),
  );
}

class ConfigurarEquipes extends StatefulWidget {
  const ConfigurarEquipes({super.key});
  @override
  State<ConfigurarEquipes> createState() => _ConfigurarEquipesState();
}

class _ConfigurarEquipesState extends State<ConfigurarEquipes> {
  int quantidade = 2;
  final nomes = List.generate(
    4,
    (i) => TextEditingController(text: 'Equipe ${i + 1}'),
  );
  @override
  void dispose() {
    for (final c in nomes) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🏆 Preparar equipes')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Quantas equipes vão jogar?',
              style: TextStyle(fontSize: 22),
            ),
            DropdownButton<int>(
              value: quantidade,
              isExpanded: true,
              items: [2, 3, 4]
                  .map(
                    (n) =>
                        DropdownMenuItem(value: n, child: Text('$n equipes')),
                  )
                  .toList(),
              onChanged: (n) => setState(() => quantidade = n!),
            ),
            for (int i = 0; i < quantidade; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: nomes[i],
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: 'Nome da equipe ${i + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BatalhaEquipes(
                    nomes: [
                      for (int i = 0; i < quantidade; i++)
                        nomes[i].text.trim().isEmpty
                            ? 'Equipe ${i + 1}'
                            : nomes[i].text.trim(),
                    ],
                  ),
                ),
              ),
              child: const Text('🎮 Começar batalha'),
            ),
          ],
        ),
      ),
    ),
  );
}

class BatalhaEquipes extends StatefulWidget {
  final List<String> nomes;
  const BatalhaEquipes({super.key, required this.nomes});
  @override
  State<BatalhaEquipes> createState() => _BatalhaEquipesState();
}

class _BatalhaEquipesState extends State<BatalhaEquipes> {
  final FlutterTts _voz = FlutterTts();

  final List<Pergunta> perguntas = [
    ...perguntasMatematica,
    ...perguntasPortugues,
    ...perguntasCores,
  ]..shuffle(Random());

  late final List<int> pontos = List.filled(widget.nomes.length, 0);

  int rodada = 0;
  int? resposta;
  int sequencia = 0;

  static const totalRodadas = 12;

  String _textoFalado(String texto) {
    return texto
        .replaceAll('🔴', 'círculo vermelho')
        .replaceAll('🔵', 'círculo azul')
        .replaceAll('🟡', 'círculo amarelo')
        .replaceAll('🟩', 'quadrado verde')
        .replaceAll('🔺', 'triângulo vermelho')
        .replaceAll('⬛', 'quadrado preto')
        .replaceAll('⚪', 'círculo branco')
        .replaceAll('🔷', 'losango azul')
        .replaceAll(' + ', ' mais ')
        .replaceAll(' × ', ' vezes ')
        .replaceAll(' ÷ ', ' dividido por ')
        .replaceAll(' - ', ' menos ');
  }

  Future<void> _falar(String texto) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio || !mounted) return;

    await _voz.stop();
    await _voz.setLanguage('pt-BR');
    await VozMiguelito.configurar(_voz);

    if (!mounted) return;
    await _voz.speak(texto);
  }

  void _falarRodada() {
    if (rodada >= totalRodadas || resposta != null) return;

    final rodadaAtual = rodada;
    final pergunta = perguntas[rodadaAtual];
    final equipe = widget.nomes[rodadaAtual % widget.nomes.length];

    final alternativas = pergunta.alternativas
        .asMap()
        .entries
        .map((item) => 'Opção ${String.fromCharCode(65 + item.key)}: ${_textoFalado(item.value)}.')
        .join(' ');

    _falar(
      'Agora é a vez da equipe $equipe! '
      'Pergunta ${rodadaAtual + 1}. '
      '${_textoFalado(pergunta.texto)} '
      '$alternativas',
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _falarRodada();
    });
  }

  void _responder(int indice) {
    if (resposta != null || rodada >= totalRodadas) return;

    final acertou = indice == perguntas[rodada].correta;
    final equipe = widget.nomes[rodada % widget.nomes.length];

    setState(() {
      resposta = indice;

      if (acertou) {
        sequencia++;
        pontos[rodada % pontos.length] += 10 + (sequencia % 3 == 0 ? 15 : 0);
      } else {
        sequencia = 0;
      }
    });

    _falar(
      acertou
          ? 'Parabéns, equipe $equipe! Resposta correta!'
          : 'Não foi dessa vez, equipe $equipe. '
                'A resposta correta é '
                '${_textoFalado(perguntas[rodada].alternativas[perguntas[rodada].correta])}.',
    );
  }

  void _proximaRodada() {
    setState(() {
      rodada++;
      resposta = null;
    });

    if (rodada < totalRodadas) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _falarRodada();
      });
    } else {
      final melhor = pontos.reduce(max);
      final vencedores = [
        for (int i = 0; i < pontos.length; i++)
          if (pontos[i] == melhor) widget.nomes[i],
      ].join(' e ');

      _falar(
        melhor == 0
            ? 'Fim de jogo! Obrigado por participar!'
            : 'Fim de jogo! Parabéns! '
                  'Equipe vencedora: $vencedores!',
      );
    }
  }

  @override
  void dispose() {
    _voz.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fim = rodada >= totalRodadas;
    final melhor = pontos.reduce(max);

    final vencedores = [
      for (int i = 0; i < pontos.length; i++)
        if (pontos[i] == melhor) widget.nomes[i],
    ].join(' e ');

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Batalha de equipes')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < pontos.length; i++)
                    Chip(label: Text('${widget.nomes[i]}: ${pontos[i]} ⭐')),
                ],
              ),
              const SizedBox(height: 24),
              if (fim) ...[
                Text(
                  '🏆 ${melhor == 0 ? 'Fim de jogo!' : 'Vencedor: $vencedores'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nova partida'),
                ),
              ] else ...[
                LinearProgressIndicator(value: (rodada + 1) / totalRodadas),
                const SizedBox(height: 16),
                Text(
                  'Rodada ${rodada + 1}/$totalRodadas • '
                  'Vez de ${widget.nomes[rodada % widget.nomes.length]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                if (ConfiguracoesJogo.instancia.instrucoesAudio)
                  Center(
                    child: FilledButton.icon(
                      onPressed: resposta == null ? _falarRodada : null,
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Ouvir pergunta e alternativas'),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  perguntas[rodada].texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(height: 20),
                for (int i = 0; i < perguntas[rodada].alternativas.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonal(
                      onPressed: resposta == null ? () => _responder(i) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          perguntas[rodada].alternativas[i],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                if (resposta != null) ...[
                  Text(
                    resposta == perguntas[rodada].correta
                        ? '🎉 Acertou!'
                        : '💡 Correta: '
                              '${perguntas[rodada].alternativas[perguntas[rodada].correta]}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  FilledButton(
                    onPressed: _proximaRodada,
                    child: Text(
                      rodada == totalRodadas - 1
                          ? 'Ver resultado'
                          : 'Próxima equipe',
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
