import 'dart:async';
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
  Widget build(BuildContext context) {
    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    return Scaffold(
    appBar: AppBar(title: Text(ingles ? '⭐ More adventures' : '⭐ Mais aventuras')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final item in [
          (ingles ? '🔤 Portuguese' : '🔤 Português', const JogoQuiz(tipo: 'Português')),
          (ingles ? '🧠 Memory' : '🧠 Memória', const JogoMemoria()),
          (ingles ? '🎨 Colors and shapes' : '🎨 Cores e formas', const JogoQuiz(tipo: 'Cores e formas')),
          (ingles ? '🏆 Team battle' : '🏆 Batalha de equipes', const ConfigurarEquipes()),
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
    'Cassaço',
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
// Exercícios de vocabulário português com instruções em inglês.
// A atividade continua ensinando palavras portuguesas, inclusive no modo inglês.
const perguntasPortuguesIngles = [
  Pergunta('Which Portuguese word is spelled correctly?', ['Caza', 'Casa', 'Cassa', 'Cassaço'], 1),
  Pergunta('What is the first letter of BOLA?', ['A', 'B', 'L', 'O'], 1),
  Pergunta('How many syllables are in SAPATO?', ['1', '2', '3', '4'], 2),
  Pergunta('What is the plural of FLOR in Portuguese?', ['Floras', 'Flores', 'Florão', 'Flor'], 1),
  Pergunta('Which Portuguese word rhymes with PÃO?', ['Mão', 'Sol', 'Lua', 'Casa'], 0),
  Pergunta('Complete the Portuguese sentence: O gato ___ leite.', ['bebem', 'bebe', 'beberam', 'bebemos'], 1),
  Pergunta('Which Portuguese word names an animal?', ['Mesa', 'Livro', 'Cachorro', 'Janela'], 2),
  Pergunta('Which Portuguese word means the opposite of ALTO?', ['Grande', 'Baixo', 'Longo', 'Forte'], 1),
  Pergunta('Which Portuguese sentence is a question?', ['Bom dia.', 'Que legal!', 'Como você está?', 'Vamos brincar.'], 2),
  Pergunta('Which Portuguese word has four letters?', ['Sol', 'Bola', 'Caderno', 'Pé'], 1),
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
// Banco em inglês para a atividade visual; respostas mantêm os mesmos índices.
const perguntasCoresIngles = [
  Pergunta('🔴 What color is this?', ['Blue', 'Green', 'Red', 'Yellow'], 2),
  Pergunta('🔺 What shape is this?', ['Circle', 'Square', 'Triangle', 'Rectangle'], 2),
  Pergunta('🔵 What color is this?', ['Blue', 'Pink', 'Orange', 'Purple'], 0),
  Pergunta('⬛ How many sides does a square have?', ['2', '3', '4', '5'], 2),
  Pergunta('🟡 What color is this?', ['Green', 'Yellow', 'Black', 'Blue'], 1),
  Pergunta('⚪ Which shape has no straight sides?', ['Triangle', 'Square', 'Circle', 'Rectangle'], 2),
  Pergunta('🔴 + 🟡: mixing red and yellow makes...', ['Green', 'Orange', 'Blue', 'Purple'], 1),
  Pergunta('🟩 What color is this?', ['Green', 'Blue', 'Yellow', 'Pink'], 0),
  Pergunta('Which shape has three sides?', ['Circle', 'Square', 'Triangle', 'Pentagon'], 2),
  Pergunta('🔷 What color is this shape?', ['Red', 'Blue', 'Green', 'Orange'], 1),
];

const perguntasMatematica = [
  Pergunta('Quanto é 4 + 5?', ['8', '9', '10', '11'], 1),
  Pergunta('Quanto é 12 - 7?', ['4', '5', '6', '7'], 1),
  Pergunta('Quanto é 3 × 4?', ['7', '12', '14', '16'], 1),
  Pergunta('Quanto é 20 ÷ 5?', ['2', '3', '4', '5'], 2),
  Pergunta('Qual número vem depois do 29?', ['28', '31', '30', '39'], 2),
];

const perguntasMatematicaIngles = [
  Pergunta('What is 4 + 5?', ['8', '9', '10', '11'], 1),
  Pergunta('What is 12 - 7?', ['4', '5', '6', '7'], 1),
  Pergunta('What is 3 × 4?', ['7', '12', '14', '16'], 1),
  Pergunta('What is 20 ÷ 5?', ['2', '3', '4', '5'], 2),
  Pergunta('Which number comes after 29?', ['28', '31', '30', '39'], 2),
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
    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    final originais = widget.tipo == 'Português'
        ? (ingles ? perguntasPortuguesIngles : perguntasPortugues)
        : (ingles ? perguntasCoresIngles : perguntasCores);
    // O banco adicional ainda não foi localizado; evitar instruções em idioma misturado.
    final todas = <Pergunta>[
      ...originais,
      if (!ingles)
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
    if (ingles) {
      return texto
          .replaceAll('🔴', 'red circle')
          .replaceAll('🔵', 'blue circle')
          .replaceAll('🟡', 'yellow circle')
          .replaceAll('🟩', 'green square')
          .replaceAll('🔺', 'red triangle')
          .replaceAll('⬛', 'black square')
          .replaceAll('⚪', 'white circle')
          .replaceAll('🔷', 'blue diamond')
          .replaceAll(' + ', ' plus ')
          .replaceAll(' - ', ' minus ')
          .replaceAll(' × ', ' times ')
          .replaceAll(' ÷ ', ' divided by ');
    }
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
        .replaceAll(' - ', ' menos ')
        .replaceAll(' × ', ' vezes ')
        .replaceAll(' ÷ ', ' dividido por ');
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

    final indiceRespondido = indice;
    final respostaCorreta = _prepararTexto(perguntas[indiceRespondido].alternativas[perguntas[indiceRespondido].correta]);
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || indiceRespondido != indice) return;

    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final mensagem = ingles
        ? (acertou ? 'Great job${nome.isNotEmpty ? ', $nome' : ''}! Correct answer!' : 'Keep trying${nome.isNotEmpty ? ', $nome' : ''}! The correct answer is $respostaCorreta.')
        : acertou
        ? 'Parabéns${nome.isNotEmpty ? ', $nome' : ''}! '
              'Você acertou! Muito bem!'
        : 'Não foi dessa vez${nome.isNotEmpty ? ', $nome' : ''}! '
              'A resposta correta é $respostaCorreta. Continue tentando!';

    await _vozMiguelito.stop();
    if (!mounted || indiceRespondido != indice) return;
    await VozMiguelito.configurar(_vozMiguelito);
    if (!mounted || indiceRespondido != indice) return;
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
    if (!respondeu || indice >= perguntas.length) return;
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
              if (ConfiguracoesJogo.instancia.instrucoesAudio)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: respondeu
                        ? () => _falarResultado(selecionada == perguntas[indice].correta)
                        : _falarPergunta,
                    icon: const Icon(Icons.volume_up),
                    label: Text(ingles
                        ? (respondeu ? 'Hear feedback again' : 'Hear question and options')
                        : (respondeu ? 'Ouvir resultado novamente' : 'Ouvir pergunta e alternativas')),
                  ),
                ),
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
  Timer? _ocultarCartasTimer;
  bool get ingles => ConfiguracoesJogo.instancia.idioma == 'en-US';

  final Map<String, String> nomesAnimais = {
    '🐶': 'cachorro',
    '🐱': 'gato',
    '🐸': 'sapo',
    '🦋': 'borboleta',
    '🐼': 'panda',
    '🦁': 'leão',
  };

  void _repetirInstrucoes() {
    _falarMemoria(ingles ? 'Flip two cards and find matching animals. Tap a card to begin!' : 'Vire duas cartas e encontre os animais iguais. Toque em uma carta para começar!');
  }

  Future<void> _falarMemoria(String mensagem) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;
    if (!mounted) return;

    await _vozMemoria.stop();
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

      _falarMemoria(ingles
        ? 'Hello${nome.isNotEmpty ? ', $nome' : ''}! Let’s play memory! Flip two cards and find the matching animals!'
        : 'Olá${nome.isNotEmpty ? ', $nome' : ''}! Vamos brincar de memória? Vire duas cartas e tente encontrar os animais iguais!');
    });
  }

  @override
  void dispose() {
    _ocultarCartasTimer?.cancel();
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

    final nomeAnimal = ingles ? ({'🐶': 'dog', '🐱': 'cat', '🐸': 'frog', '🦋': 'butterfly', '🐼': 'panda', '🦁': 'lion'}[cartas[i]] ?? 'animal') : (nomesAnimais[cartas[i]] ?? 'animal');

    if (primeira == null) {
      setState(() {
        primeira = i;
      });

      _falarMemoria(ingles ? 'You found a $nomeAnimal!' : 'Você encontrou um $nomeAnimal!');
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
          ? (ingles ? 'Well done! You found a matching pair of $nomeAnimal!' : 'Muito bem! Você encontrou um par de $nomeAnimal!')
          : (ingles ? 'These cards are different. Keep trying!' : 'Essas cartas são diferentes. Continue tentando!'),
    );

    _ocultarCartasTimer?.cancel();
    _ocultarCartasTimer = Timer(
      Duration(milliseconds: ConfiguracoesJogo.instancia.modoTranquilo ? 1600 : 850),
      () {
      if (!mounted) return;

      setState(() {
        if (acertou) achadas.addAll([a, b]);
        primeira = null;
        segunda = null;
        bloqueado = false;
      });

      if (acertou && achadas.length == cartas.length) {
        _falarMemoria(
          ingles ? 'Congratulations! You found every pair! Amazing!' : 'Parabéns! Você encontrou todos os pares! Você é incrível!',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(ingles ? '🧠 Memory Game' : '🧠 Jogo da Memória')),
    body: SafeArea(
      child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Text(
              achadas.length == cartas.length
                  ? (ingles ? '🏆 Congratulations! You found every pair!' : '🏆 Parabéns! Você encontrou todos os pares!')
                  : (ingles ? 'Find the pairs! • Attempts: $tentativas' : 'Encontre os pares! • Tentativas: $tentativas'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21),
            ),
            const SizedBox(height: 12),
            if (ConfiguracoesJogo.instancia.instrucoesAudio)
              TextButton.icon(
                onPressed: _repetirInstrucoes,
                icon: const Icon(Icons.volume_up),
                label: Text(ingles ? 'Hear instructions again' : 'Ouvir instruções novamente'),
              ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: cartas.length,
              itemBuilder: (_, i) => Semantics(
                button: true,
                label: achadas.contains(i)
                    ? (ingles ? 'Pair found' : 'Par encontrado')
                    : (ingles ? 'Card ${i + 1}' : 'Carta ${i + 1}'),
                child: InkWell(
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
            ),
            if (achadas.length == cartas.length)
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const JogoMemoria()),
                ),
                child: Text(ingles ? 'Play again' : 'Jogar novamente'),
              ),
          ],
        ),
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
  bool get ingles => ConfiguracoesJogo.instancia.idioma == 'en-US';
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
    appBar: AppBar(title: Text(ingles ? '🏆 Set up teams' : '🏆 Preparar equipes')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              ingles ? 'How many teams will play?' : 'Quantas equipes vão jogar?',
              style: TextStyle(fontSize: 22),
            ),
            DropdownButton<int>(
              value: quantidade,
              isExpanded: true,
              items: [2, 3, 4]
                  .map(
                    (n) =>
                        DropdownMenuItem(value: n, child: Text(ingles ? '$n teams' : '$n equipes')),
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
                    labelText: ingles ? 'Team ${i + 1} name' : 'Nome da equipe ${i + 1}',
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
              child: Text(ingles ? '🎮 Start battle' : '🎮 Começar batalha'),
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
  bool get ingles => ConfiguracoesJogo.instancia.idioma == 'en-US';

  late final List<Pergunta> perguntas = [
    ...(ingles ? perguntasMatematicaIngles : perguntasMatematica),
    ...(ingles ? perguntasPortuguesIngles : perguntasPortugues),
    ...(ingles ? perguntasCoresIngles : perguntasCores),
  ]..shuffle(Random());

  late final List<int> pontos = List.filled(widget.nomes.length, 0);

  int rodada = 0;
  int? resposta;
  int sequencia = 0;

  static const totalRodadas = 12;

  String _textoFalado(String texto) {
    if (ingles) return texto.replaceAll('🔴', 'red circle').replaceAll('🔵', 'blue circle').replaceAll('🟡', 'yellow circle').replaceAll('🟩', 'green square').replaceAll('🔺', 'red triangle').replaceAll('⬛', 'black square').replaceAll('⚪', 'white circle').replaceAll('🔷', 'blue diamond').replaceAll(' + ', ' plus ').replaceAll(' × ', ' times ').replaceAll(' ÷ ', ' divided by ').replaceAll(' - ', ' minus ');
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
        .map((item) => '${ingles ? 'Option' : 'Opção'} ${String.fromCharCode(65 + item.key)}: ${_textoFalado(item.value)}.')
        .join(' ');

    _falar(
      '${ingles ? 'Team $equipe, it is your turn! Question ${rodadaAtual + 1}.' : 'Agora é a vez da equipe $equipe! Pergunta ${rodadaAtual + 1}.'} '
      '${_textoFalado(pergunta.texto)} $alternativas',
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _falarRodada();
    });
  }

  void _falarFeedbackEquipe() {
    if (resposta == null || rodada >= totalRodadas) return;
    final acertou = resposta == perguntas[rodada].correta;
    final equipe = widget.nomes[rodada % widget.nomes.length];
    final correta = _textoFalado(
      perguntas[rodada].alternativas[perguntas[rodada].correta],
    );
    _falar(acertou
        ? (ingles
            ? 'Well done, team $equipe! Correct answer!'
            : 'Parabéns, equipe $equipe! Resposta correta!')
        : (ingles
            ? 'Not this time, team $equipe. The correct answer is $correta.'
            : 'Não foi dessa vez, equipe $equipe. A resposta correta é $correta.'));
  }

  void _responder(int indice) {
    if (resposta != null || rodada >= totalRodadas) return;

    final acertou = indice == perguntas[rodada].correta;

    setState(() {
      resposta = indice;

      if (acertou) {
        sequencia++;
        pontos[rodada % pontos.length] += 10 + (sequencia % 3 == 0 ? 15 : 0);
      } else {
        sequencia = 0;
      }
    });

    _falarFeedbackEquipe();
  }

  void _proximaRodada() {
    if (resposta == null || rodada >= totalRodadas) return;
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
            ? (ingles ? 'Game over! Thanks for playing!' : 'Fim de jogo! Obrigado por participar!')
            : (ingles
                ? 'Game over! Congratulations! Winning team: $vencedores!'
                : 'Fim de jogo! Parabéns! Equipe vencedora: $vencedores!'),
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
      appBar: AppBar(title: Text(ingles ? '🏆 Team battle' : '🏆 Batalha de equipes')),
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
                  '🏆 ${melhor == 0 ? (ingles ? 'Game over!' : 'Fim de jogo!') : (ingles ? 'Winner: $vencedores' : 'Vencedor: $vencedores')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ingles ? 'New game' : 'Nova partida'),
                ),
              ] else ...[
                LinearProgressIndicator(value: (rodada + 1) / totalRodadas),
                const SizedBox(height: 16),
                Text(
                  ingles ? 'Round ${rodada + 1}/$totalRodadas • ${widget.nomes[rodada % widget.nomes.length]}\'s turn' : 'Rodada ${rodada + 1}/$totalRodadas • Vez de ${widget.nomes[rodada % widget.nomes.length]}',
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
                      label: Text(ingles ? 'Listen to question and answers' : 'Ouvir pergunta e alternativas'),
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
                        ? (ingles ? '🎉 Correct!' : '🎉 Acertou!')
                        : '${ingles ? '💡 Correct answer:' : '💡 Correta:'} ${perguntas[rodada].alternativas[perguntas[rodada].correta]}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  if (ConfiguracoesJogo.instancia.instrucoesAudio)
                    TextButton.icon(
                      onPressed: _falarFeedbackEquipe,
                      icon: const Icon(Icons.volume_up),
                      label: Text(ingles
                          ? 'Hear feedback again'
                          : 'Ouvir resultado novamente'),
                    ),
                  FilledButton(
                    onPressed: _proximaRodada,
                    child: Text(
                      rodada == totalRodadas - 1
                          ? (ingles ? 'See results' : 'Ver resultado')
                          : (ingles ? 'Next team' : 'Próxima equipe'),
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
