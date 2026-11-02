import 'dart:math';

import 'package:flutter/material.dart';

import 'jogos_extras.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'configuracoes_jogo.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'voz_miguelito.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'multiplayer_online.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.signInAnonymously();

  runApp(const MundoKidsApp());
}

class MundoKidsApp extends StatelessWidget {
  const MundoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundo Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EE6)),
        scaffoldBackgroundColor: const Color(0xFFFFF6DB),
      ),
      initialRoute: '/',
      routes: {'/': (context) {
        final codigo = Uri.base.queryParameters['sala']?.trim().toUpperCase();
        if (codigo != null && RegExp(r'^[A-HJ-NP-Z2-9]{6}$').hasMatch(codigo)) {
          return TelaMultiplayerOnline(conviteSala: codigo);
        }
        return const EntradaMundoKids();
      }},
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(
              Icons.settings,
              color: Colors.deepPurple,
              size: 30,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaConfiguracoes()),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_inicio.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🌟 Sua aventura vai começar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31235B),
                      shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420),
                    child: Text(
                      'Clique no botão abaixo para explorar nossos jogos, aprender e se divertir com o Miguelito!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF31235B),
                        shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaModoJogo()),
                    ),
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('COMEÇAR A JOGAR'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF39C878),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Escolha do modo antes de selecionar uma atividade.
class TelaModoJogo extends StatelessWidget {
  const TelaModoJogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Como vamos jogar?'),
        backgroundColor: Colors.white.withValues(alpha: 0.88),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_jogos.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Escolha como quer se divertir!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF31235B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'O Miguelito está pronto para a aventura!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 28),
                      _opcao(
                        context: context,
                        emoji: '👤',
                        titulo: 'JOGAR SOZINHO',
                        descricao: 'Escolha uma matéria e aprenda no seu ritmo.',
                        destino: const TelaJogos(),
                      ),
                      const SizedBox(height: 14),
                      _opcao(
                        context: context,
                        emoji: '👥',
                        titulo: 'JOGAR EM EQUIPE',
                        descricao: 'Crie uma sala ou entre com o código dos amigos.',
                        destino: const TelaMultiplayerOnline(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _opcao({
    required BuildContext context,
    required String emoji,
    required String titulo,
    required String descricao,
    required Widget destino,
  }) {
    return Material(
      color: const Color(0xFFF1EDFF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destino),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF31235B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(descricao, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF6B4EE6)),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaJogos extends StatelessWidget {
  const TelaJogos({super.key});

  @override
  Widget build(BuildContext context) {
    const atividades = [
      ('🔢', 'Matemática'),
      ('🔤', 'Português'),
      ('🧠', 'Memória'),
      ('🎨', 'Cores e formas'),
    ];

    void abrirAtividade(int index) {
      final Widget destino;
      switch (index) {
        case 0:
          destino = const TelaNivel();
        case 1:
          destino = const JogoQuiz(tipo: 'Português');
        case 2:
          destino = const JogoMemoria();
        case 3:
          destino = const JogoQuiz(tipo: 'Cores e formas');
        default:
          return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('🎮 Escolha uma aventura!'),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_jogos.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Qual aventura vamos jogar hoje?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF31235B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (int index = 0; index < atividades.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 3,
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            leading: Text(
                              atividades[index].$1,
                              style: const TextStyle(fontSize: 32),
                            ),
                            title: Text(
                              atividades[index].$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31235B),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF6B4EE6),
                            ),
                            onTap: () => abrirAtividade(index),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Nivel { facil, medio, desafio }

extension NivelDescricao on Nivel {
  String get titulo => switch (this) {
    Nivel.facil => 'Fácil',
    Nivel.medio => 'Médio',
    Nivel.desafio => 'Desafio',
  };
  String get descricao => switch (this) {
    Nivel.facil => 'Somar e subtrair',
    Nivel.medio => 'Contas maiores e multiplicação',
    Nivel.desafio => 'Multiplicação, divisão e desafios',
  };
  String get emoji => switch (this) {
    Nivel.facil => '🟢',
    Nivel.medio => '🟡',
    Nivel.desafio => '🔴',
  };
}

class TelaNivel extends StatelessWidget {
  const TelaNivel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔢 Matemática')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Escolha seu nível!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '🤖 O Miguelito vai torcer por você!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 28),
          for (final nivel in Nivel.values)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: Text(
                  nivel.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                title: Text(
                  nivel.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(nivel.descricao),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaMatematica(nivel: nivel),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Pergunta {
  final String enunciado;
  final int correta;
  final List<int> alternativas;
  const Pergunta(this.enunciado, this.correta, this.alternativas);
}

class TelaMatematica extends StatefulWidget {
  final Nivel nivel;
  const TelaMatematica({super.key, required this.nivel});

  @override
  State<TelaMatematica> createState() => _TelaMatematicaState();
}

class _TelaMatematicaState extends State<TelaMatematica> {
  final FlutterTts _vozMiguelito = FlutterTts();

  Future<void> _falarPergunta() async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;
    if (!mounted || _selecionada != null) return;

    final indiceAtual = _indice;
    final perguntaAtual = _perguntas[indiceAtual];

    final pergunta = perguntaAtual.enunciado
        .replaceAll('+', ' mais ')
        .replaceAll('-', ' menos ')
        .replaceAll('×', ' vezes ')
        .replaceAll('÷', ' dividido por ')
        .replaceAll('=', ' é igual a ');

    final alternativas = perguntaAtual.alternativas
        .asMap()
        .entries
        .map((item) => 'Opção ${String.fromCharCode(65 + item.key)}: ${item.value}.')
        .join(' ');

    final prefs = await SharedPreferences.getInstance();
    if (!mounted || indiceAtual != _indice || _selecionada != null) return;

    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final mensagem = nome.isNotEmpty
        ? '$nome, vamos lá! $pergunta $alternativas'
        : 'Vamos lá! $pergunta $alternativas';

    await _vozMiguelito.stop();
    await _vozMiguelito.setLanguage('pt-BR');
    await VozMiguelito.configurar(_vozMiguelito);

    if (!mounted || indiceAtual != _indice || _selecionada != null) return;
    await _vozMiguelito.speak(mensagem);
  }

  @override
  void dispose() {
    _cronometroTimer?.cancel();
    _vozMiguelito.stop();
    super.dispose();
  }

  Timer? _cronometroTimer;
  final Random _random = Random();
  late List<Pergunta> _perguntas;
  int _indice = 0;
  int _pontos = 0;
  int? _selecionada;

  // Controle da dificuldade adaptativa
  int _dificuldadeAdaptativa = 1;
  int _acertosConsecutivos = 0;
  int _errosConsecutivos = 0;

  // Histórico para evitar perguntas repetidas
  final Set<String> _perguntasUtilizadas = {};

  @override
  void initState() {
    super.initState();
    _perguntas = [_gerarPergunta()];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _falarPergunta();
      }
    });
  }

  int _entre(int minimo, int maximo) =>
      minimo + _random.nextInt(maximo - minimo + 1);

  Pergunta _gerarPergunta() {
    final config = ConfiguracoesJogo.instancia;

    final Nivel nivelAtual;

    if (config.nivel == NivelJogo.adaptativo) {
      nivelAtual = switch (_dificuldadeAdaptativa) {
        1 => Nivel.facil,
        2 => Nivel.medio,
        _ => Nivel.desafio,
      };
    } else {
      nivelAtual = switch (config.nivel) {
        NivelJogo.facil => Nivel.facil,
        NivelJogo.medio => Nivel.medio,
        NivelJogo.dificil => Nivel.desafio,
        NivelJogo.adaptativo => Nivel.facil,
      };
    }

    for (var tentativa = 0; tentativa < 200; tentativa++) {
      final operacoes = switch (nivelAtual) {
        Nivel.facil => ['+', '-'],
        Nivel.medio => ['+', '-', '×'],
        Nivel.desafio => ['+', '-', '×', '÷'],
      };

      final operacao = operacoes[_random.nextInt(operacoes.length)];

      late int a;
      late int b;
      late int resultado;

      switch (operacao) {
        case '+':
          final limite = nivelAtual == Nivel.facil
              ? 20
              : (nivelAtual == Nivel.medio ? 60 : 150);
          a = _entre(1, limite);
          b = _entre(1, limite);
          resultado = a + b;
          break;

        case '-':
          final limite = nivelAtual == Nivel.facil
              ? 20
              : (nivelAtual == Nivel.medio ? 80 : 200);
          a = _entre(1, limite);
          b = _entre(1, a);
          resultado = a - b;
          break;

        case '×':
          a = _entre(2, nivelAtual == Nivel.medio ? 9 : 12);
          b = _entre(2, 12);
          resultado = a * b;
          break;

        case '÷':
          b = _entre(2, 12);
          resultado = _entre(2, 12);
          a = b * resultado;
          break;

        default:
          throw StateError('Operação desconhecida');
      }

      final chave = '$a $operacao $b';

      if (_perguntasUtilizadas.contains(chave)) {
        continue;
      }

      _perguntasUtilizadas.add(chave);

      final opcoes = <int>{resultado};

      var tentativasOpcoes = 0;

      while (opcoes.length < 4 && tentativasOpcoes < 100) {
        tentativasOpcoes++;

        final deslocamento = _entre(1, nivelAtual == Nivel.facil ? 10 : 20);

        final candidato =
            resultado + (_random.nextBool() ? deslocamento : -deslocamento);

        if (candidato >= 0) {
          opcoes.add(candidato);
        }
      }

      var candidato = resultado + 1;

      while (opcoes.length < 4) {
        opcoes.add(candidato++);
      }

      final alternativas = opcoes.toList()..shuffle(_random);

      return Pergunta('$a $operacao $b = ?', resultado, alternativas);
    }

    throw StateError('Não foi possível gerar uma pergunta inédita.');
  }

  void _responder(int resposta) {
    if (_selecionada != null) return;

    final acertou = resposta == _perguntas[_indice].correta;

    setState(() {
      _selecionada = resposta;

      if (acertou) {
        _pontos += 10;
        _acertosConsecutivos++;
        _errosConsecutivos = 0;

        if (_acertosConsecutivos >= 2 && _dificuldadeAdaptativa < 3) {
          _dificuldadeAdaptativa++;
          _acertosConsecutivos = 0;
        }
      } else {
        _errosConsecutivos++;
        _acertosConsecutivos = 0;

        if (_errosConsecutivos >= 2 && _dificuldadeAdaptativa > 1) {
          _dificuldadeAdaptativa--;
          _errosConsecutivos = 0;
        }
      }
    });

    _falarResultado(acertou);
  }

  Future<void> _falarResultado(bool acertou) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;

    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final mensagem = acertou
        ? (nome.isNotEmpty
              ? 'Uhuuul! Parabéns, $nome! Você acertou! Muito bem!'
              : 'Uhuuul! Parabéns! Você acertou! Muito bem!')
        : (nome.isNotEmpty
              ? 'Não foi dessa vez, $nome! A resposta correta é ${_perguntas[_indice].correta}. Continue tentando!'
              : 'Não foi dessa vez! A resposta correta é ${_perguntas[_indice].correta}. Continue tentando!');

    await _vozMiguelito.stop();
    await _vozMiguelito.setLanguage('pt-BR');
    await VozMiguelito.configurar(_vozMiguelito);
    await _vozMiguelito.speak(mensagem);
  }

  void _proxima() {
    if (_selecionada == null) return;

    if (_indice >= 9) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TelaResultado(pontos: _pontos, nivel: widget.nivel),
        ),
      );
      return;
    }

    setState(() {
      if (_indice + 1 >= _perguntas.length) {
        _perguntas.add(_gerarPergunta());
      }

      _indice++;
      _selecionada = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _falarPergunta();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = _perguntas[_indice];
    final respondida = _selecionada != null;
    final acertou = _selecionada == pergunta.correta;
    final modoTranquilo = ConfiguracoesJogo.instancia.modoTranquilo;
    return Scaffold(
      appBar: AppBar(title: Text('🔢 Matemática • ${widget.nivel.titulo}')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pergunta ${_indice + 1} de 10',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '⭐ $_pontos pontos',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_indice + 1) / 10,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 30),
                Card(
                  color: modoTranquilo
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFFE8E0FF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 35,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🤖 Miguelito pergunta:',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pergunta.enunciado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (ConfiguracoesJogo.instancia.instrucoesAudio)
                          FilledButton.icon(
                            onPressed: _falarPergunta,
                            icon: const Icon(Icons.volume_up),
                            label: const Text('🔊 Ouvir pergunta e alternativas'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: pergunta.alternativas.length,
                  itemBuilder: (context, i) {
                    final valor = pergunta.alternativas[i];
                    final correta = valor == pergunta.correta;
                    final erradaEscolhida =
                        respondida && valor == _selecionada && !correta;
                    final cor = respondida && correta
                        ? const Color(0xFFB8F3C9)
                        : erradaEscolhida
                        ? const Color(0xFFFFC7C7)
                        : Colors.white;
                    return Material(
                      color: cor,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: respondida ? null : () => _responder(valor),
                        child: Center(
                          child: Text(
                            '$valor',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                if (respondida) ...[
                  Text(
                    acertou
                        ? '🎉 Muito bem! Você acertou!'
                        : '💪 Boa tentativa! A resposta é ${pergunta.correta}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _proxima,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                    ),
                    child: Text(
                      _indice == 9 ? 'VER RESULTADO 🏆' : 'PRÓXIMA PERGUNTA ➡️',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelaResultado extends StatelessWidget {
  final int pontos;
  final Nivel nivel;
  const TelaResultado({super.key, required this.pontos, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final acertos = pontos ~/ 10;
    final mensagem = acertos >= 8
        ? 'Incrível! Você arrasou!'
        : acertos >= 5
        ? 'Muito bem! Continue praticando!'
        : 'Cada tentativa ajuda você a aprender!';
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Resultado')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 95)),
                const SizedBox(height: 18),
                const Text(
                  'Parabéns por jogar!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  '⭐ $pontos pontos',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$acertos de 10 respostas corretas',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 18),
                Text(
                  '🤖 $mensagem',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaMatematica(nivel: nivel),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('JOGAR NOVAMENTE'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ESCOLHER OUTRO NÍVEL'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelaIdentificacao extends StatefulWidget {
  final void Function(String) aoContinuar;

  const TelaIdentificacao({super.key, required this.aoContinuar});

  @override
  State<TelaIdentificacao> createState() => _TelaIdentificacaoState();
}

class _TelaIdentificacaoState extends State<TelaIdentificacao> {
  final TextEditingController _nomeController = TextEditingController();

  Future<void> _salvarNome() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_crianca', nome);

    if (!mounted) return;
    widget.aoContinuar(nome);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_boas_vindas.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎮 Bem-vindo ao Mundo Kids!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Olá! Eu sou o Miguelito!\n'
                    'Como você se chama?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _nomeController,
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Seu primeiro nome',
                          hintText: 'Digite seu nome aqui',
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xFF6F42C1),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6F42C1),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _salvarNome,
                    child: const Text('Começar minha aventura! 🚀'),
                  ),
                ], // Fecha a lista children
              ), // Fecha a Column
            ), // Container do formulário
          ), // Padding
        ), // Align
      ), // Container do fundo
    ); // Scaffold
  }
}

class EntradaMundoKids extends StatefulWidget {
  const EntradaMundoKids({super.key});

  @override
  State<EntradaMundoKids> createState() => _EntradaMundoKidsState();
}

class _EntradaMundoKidsState extends State<EntradaMundoKids> {
  String? _nome;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _verificarCadastro();
  }

  Future<void> _verificarCadastro() async {
    final prefs = await SharedPreferences.getInstance();
    final nomeSalvo = prefs.getString('nome_crianca');

    if (!mounted) return;

    setState(() {
      _nome = nomeSalvo;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_nome == null || _nome!.trim().isEmpty) {
      return TelaIdentificacao(
        aoContinuar: (nome) {
          setState(() {
            _nome = nome;
          });
        },
      );
    }

    return const TelaInicial();
  }
}
