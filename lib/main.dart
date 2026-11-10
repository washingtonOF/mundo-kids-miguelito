import 'abrir_central.dart';
import 'botoes_navegacao.dart';
// Miguelzãoo — em desenvolvimento.
// Propriedade: Washington Santos de Souza - IsamigShop.
// Uma homenagem ao meu filho amado, Lucas Miguel.
// Mensagem reservada ao código-fonte; não exibir na interface.

import 'dart:math';
import 'controles_janela.dart';

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

  // Os jogos individuais devem abrir mesmo sem conexão com a internet.
  // O multiplayer continuará exigindo autenticação e acesso ao Firebase.
  await ConfiguracoesJogo.instancia.carregar();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.signInAnonymously();
  } catch (erro) {
    debugPrint('Miguelzãoo: serviços online indisponíveis: $erro');
  }

  runApp(const MundoKidsApp());
}

class MundoKidsApp extends StatelessWidget {
  const MundoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miguelzãoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC928),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF6DB),
      ),
      builder: (context, child) => ControlesJanela(child: child ?? const SizedBox.shrink()),
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

/// Mascote vetorial independente de arquivos externos: aparece também offline.
class AvatarMiguelito extends StatelessWidget {
  final double tamanho;
  const AvatarMiguelito({super.key, this.tamanho = 220});

  @override
  Widget build(BuildContext context) => Semantics(
    label: ConfiguracoesJogo.instancia.idioma == 'en-US'
        ? 'Miguelzãoo, the friendly yellow mascot'
        : 'Miguelzãoo, o mascote amarelo e sorridente',
    image: true,
    child: SizedBox(
      width: tamanho,
      height: tamanho,
      child: CustomPaint(painter: _PintorMiguelito()),
    ),
  );
}

class _PintorMiguelito extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 220, size.height / 220);
    final amarelo = Paint()..color = const Color(0xFFFFD332);
    final azul = Paint()..color = const Color(0xFF1765D1);
    final escuro = Paint()..color = const Color(0xFF372510);
    final cabelo = Paint()..color = const Color(0xFF171719);
    final branco = Paint()..color = Colors.white;
    void oval(Rect r, Paint p) => canvas.drawOval(r, p);
    void rr(Rect r, double rad, Paint p) => canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(rad)), p);
    // Corpo, braços, pernas e tênis.
    rr(const Rect.fromLTWH(76, 142, 69, 53), 17, azul);
    rr(const Rect.fromLTWH(81, 187, 23, 22), 10, amarelo);
    rr(const Rect.fromLTWH(118, 187, 23, 22), 10, amarelo);
    oval(const Rect.fromLTWH(68, 201, 42, 15), azul);
    oval(const Rect.fromLTWH(114, 201, 42, 15), azul);
    rr(const Rect.fromLTWH(59, 147, 23, 42), 12, amarelo);
    rr(const Rect.fromLTWH(139, 147, 23, 42), 12, amarelo);
    // Cabeça, orelhas e cabelo.
    oval(const Rect.fromLTWH(30, 79, 35, 39), amarelo);
    oval(const Rect.fromLTWH(155, 79, 35, 39), amarelo);
    oval(const Rect.fromLTWH(44, 27, 132, 136), amarelo);
    for (final r in [
      const Rect.fromLTWH(56, 18, 45, 35),
      const Rect.fromLTWH(88, 11, 48, 42),
      const Rect.fromLTWH(124, 22, 40, 34),
    ]) { oval(r, cabelo); }
    // Olhos grandes e sorriso.
    oval(const Rect.fromLTWH(72, 84, 29, 37), branco);
    oval(const Rect.fromLTWH(120, 84, 29, 37), branco);
    oval(const Rect.fromLTWH(84, 96, 12, 19), escuro);
    oval(const Rect.fromLTWH(126, 96, 12, 19), escuro);
    oval(const Rect.fromLTWH(89, 98, 4, 6), branco);
    oval(const Rect.fromLTWH(131, 98, 4, 6), branco);
    final sorriso = Path()
      ..moveTo(91, 129)
      ..quadraticBezierTo(110, 151, 132, 129);
    canvas.drawPath(sorriso, Paint()
      ..color = escuro.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round);
    // Letra M na camiseta.
    final texto = TextPainter(
      text: const TextSpan(text: 'M', style: TextStyle(
        color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(canvas, const Offset(97, 150));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ConfiguracoesJogo.instancia,
      builder: (context, _) {
        final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, dimensoes) {
              final largura = dimensoes.maxWidth;
              final compacto = dimensoes.maxHeight < 680;
              final tamanhoMascote = (largura * 0.56).clamp(145.0, compacto ? 190.0 : 245.0);
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF159BEE), Color(0xFF83D9FF), Color(0xFF9CE63A)],
                    stops: [0, 0.68, 1],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton.filledTonal(
                                tooltip: ingles ? 'Settings' : 'Configurações',
                                onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TelaConfiguracoes())),
                                icon: const Icon(Icons.settings, size: 28),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Text(
                                ingles ? '✨ LEARN • PLAY • DISCOVER' : '✨ APRENDER • BRINCAR • DESCOBRIR',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Miguelzãoo', style: TextStyle(
                                fontSize: compacto ? 49 : 57,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFD22A),
                                shadows: const [
                                  Shadow(color: Color(0xFF063D9E), offset: Offset(3, 5), blurRadius: 2),
                                  Shadow(color: Colors.white, blurRadius: 7),
                                ],
                              )),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1765D1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(ingles ? 'Learning Through Play' : 'Aprender Brincando',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                            ),
                            SizedBox(height: compacto ? 4 : 14),
                            Container(
                              width: tamanhoMascote + 48,
                              height: tamanhoMascote + 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(colors: [
                                  Color(0xFFF8FDFF), Color(0xFFB9EEFF), Color(0x0083D9FF),
                                ]),
                                boxShadow: [BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  blurRadius: 28, spreadRadius: 5,
                                )],
                              ),
                              child: Image.asset(
                                'Menino feliz com tablet azul.png',
                                fit: BoxFit.contain,
                                semanticLabel: ingles
                                    ? 'Miguelzãoo using a tablet'
                                    : 'Miguelzãoo usando um tablet',
                                errorBuilder: (_, __, ___) =>
                                    AvatarMiguelito(tamanho: tamanhoMascote),
                              ),
                            ),
                            SizedBox(height: compacto ? 8 : 18),
                            Row(
                              children: [
                                Expanded(child: _botaoIdioma('pt-BR', '🇧🇷 Português')),
                                const SizedBox(width: 8),
                                Expanded(child: _botaoIdioma('en-US', '🇺🇸 English')),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 72,
                              child: FilledButton.icon(
                                onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TelaModoJogo())),
                                icon: const Icon(Icons.play_arrow_rounded, size: 36),
                                label: Text(ingles ? 'START' : 'INICIAR',
                                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF12BA13),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: abrirCentralDeJogos,
                                icon: const Icon(Icons.sports_esports_rounded),
                                label: Text(ingles ? 'GAMES HUB' : 'CENTRAL DE JOGOS'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF5941A5),
                                  side: const BorderSide(color: Color(0xFF6B4EE6), width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.menu_book, size: 36, color: Color(0xFF1857B3)),
                                Icon(Icons.edit, size: 32, color: Color(0xFFFFD22A)),
                                Icon(Icons.public, size: 36, color: Color(0xFF1857B3)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _botaoIdioma(String idioma, String rotulo) {
    final selecionado = ConfiguracoesJogo.instancia.idioma == idioma;
    return OutlinedButton(
      onPressed: () => ConfiguracoesJogo.instancia.alterarIdioma(idioma),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF142857),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        side: BorderSide(
          color: selecionado ? const Color(0xFF168D2A) : Colors.white,
          width: selecionado ? 3 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: FittedBox(fit: BoxFit.scaleDown,
        child: Text(rotulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
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
        actions: const [BotoesNavegacao()],
        title: Text(ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? '🎮 Como vamos jogar?' : '🎮 How shall we play?'),
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
                      Text(
                        ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'Escolha como quer se divertir!' : 'Choose how you want to play!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF31235B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'O Miguelzãoo está pronto para a aventura!' : 'Miguelzãoo is ready for adventure!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 28),
                      _opcao(
                        context: context,
                        emoji: '👤',
                        titulo: ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'JOGAR SOZINHO' : 'PLAY SOLO',
                        descricao: ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'Escolha uma matéria e aprenda no seu ritmo.' : 'Choose a subject and learn at your own pace.',
                        destino: const TelaJogos(),
                      ),
                      const SizedBox(height: 14),
                      _opcao(
                        context: context,
                        emoji: '👥',
                        titulo: ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'JOGAR EM EQUIPE' : 'PLAY WITH FRIENDS',
                        descricao: ConfiguracoesJogo.instancia.idioma == 'pt-BR' ? 'Crie uma sala ou entre com o código dos amigos.' : 'Create a room or join with a friend code.',
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
          MaterialPageRoute(settings: destino is TelaJogos ? const RouteSettings(name: '/jogos') : null, builder: (_) => destino),
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
    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    final atividades = [
      ('🔢', ingles ? 'Math' : 'Matemática'),
      ('🔤', ingles ? 'Portuguese' : 'Português'),
      ('🧠', ingles ? 'Memory' : 'Memória'),
      ('🎨', ingles ? 'Colors and shapes' : 'Cores e formas'),
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

    Widget menu() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            ingles ? 'Which adventure shall we play today?' : 'Qual aventura vamos jogar hoje?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF31235B)),
          ),
        ),
        const SizedBox(height: 10),
        for (int index = 0; index < atividades.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white.withValues(alpha: 0.96),
              elevation: 3,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => abrirAtividade(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(
                    children: [
                      Text(atividades[index].$1, style: const TextStyle(fontSize: 25)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(atividades[index].$2,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF31235B))),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6B4EE6)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    Widget avatar({double altura = 240}) => SizedBox(
      height: altura,
      child: Image.asset(
        'Menino feliz com tablet azul.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: AvatarMiguelito(tamanho: altura * 0.9),
        ),
      ),
    );

    Widget painel() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ingles ? 'Which adventure shall we play today?' : 'Qual aventura vamos jogar hoje?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF31235B)),
        ),
        const SizedBox(height: 12),
        for (int index = 0; index < atividades.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.white.withValues(alpha: 0.95),
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => abrirAtividade(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: Row(children: [
                    Text(atividades[index].$1, style: const TextStyle(fontSize: 25)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(atividades[index].$2,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF31235B)))),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B4EE6)),
                  ]),
                ),
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFE1F5FF),
        titleSpacing: 4,
        title: Row(children: [
          IconButton(
            tooltip: ingles ? 'Back' : 'Voltar',
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) navigator.pop();
            },
          ),
          IconButton(
            tooltip: ingles ? 'Games home' : 'Início - jogos',
            icon: const Icon(Icons.home_outlined, size: 22),
            onPressed: () {
              final navigator = Navigator.of(context);
              var encontrouMenu = false;
              navigator.popUntil((route) {
                if (route.settings.name == '/jogos') {
                  encontrouMenu = true;
                  return true;
                }
                return route.isFirst;
              });
              if (!encontrouMenu) {
                navigator.push(MaterialPageRoute(
                  settings: const RouteSettings(name: '/jogos'),
                  builder: (_) => const TelaJogos(),
                ));
              }
            },
          ),
          const SizedBox(width: 5),
          Flexible(child: Text(
            ingles ? 'Choose an adventure!' : 'Escolha uma aventura!',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          )),
        ]),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF31B9FF), Color(0xFFB7EEFF), Color(0xFFDEF7C5)],
          ),
        ),
        child: LayoutBuilder(builder: (context, dimensoes) {
          final amplo = dimensoes.maxWidth >= 720;
          if (amplo) {
            return Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(children: [
                Expanded(child: avatar(altura: (dimensoes.maxHeight * 0.76).clamp(230.0, 530.0))),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: painel(),
                )),
              ]),
            ));
          }
          return SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Column(children: [
                avatar(altura: (dimensoes.maxHeight * 0.30).clamp(125.0, 230.0)),
                const SizedBox(height: 10),
                painel(),
              ]),
            )),
          ));
        }),
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
      appBar: AppBar(
        actions: const [BotoesNavegacao()],title: const Text('🔢 Matemática')),
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
            '🤖 O Miguelzãoo vai torcer por você!',
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

    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    final pergunta = perguntaAtual.enunciado
        .replaceAll('+', ingles ? ' plus ' : ' mais ')
        .replaceAll('-', ingles ? ' minus ' : ' menos ')
        .replaceAll('×', ingles ? ' times ' : ' vezes ')
        .replaceAll('÷', ingles ? ' divided by ' : ' dividido por ')
        .replaceAll('=', ingles ? ' equals ' : ' é igual a ');

    final alternativas = perguntaAtual.alternativas
        .asMap()
        .entries
        .map((item) => '${ingles ? 'Option' : 'Opção'} ${String.fromCharCode(65 + item.key)}: ${item.value}.')
        .join(' ');

    final prefs = await SharedPreferences.getInstance();
    if (!mounted || indiceAtual != _indice || _selecionada != null) return;

    final nome = prefs.getString('nome_crianca')?.trim() ?? '';

    final mensagem = nome.isNotEmpty
        ? '$nome, ${ingles ? 'let’s go!' : 'vamos lá!'} $pergunta $alternativas'
        : '${ingles ? 'Let’s go!' : 'Vamos lá!'} $pergunta $alternativas';

    await _vozMiguelito.stop();
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
          // O resultado também deve respeitar o teto da dificuldade.
          a = _entre(1, limite - 1);
          b = _entre(1, limite - a);
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
          b = _entre(2, nivelAtual == Nivel.medio ? 9 : 12);
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
      }

      // Ajustes automáticos só são aplicados no modo Adaptativo.
      if (ConfiguracoesJogo.instancia.nivel == NivelJogo.adaptativo) {
        if (acertou) {
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
      }
    });

    _falarResultado(acertou);
  }

  Future<void> _falarResultado(bool acertou) async {
    if (!ConfiguracoesJogo.instancia.instrucoesAudio) return;

    final indiceRespondido = _indice;
    final respostaCorreta = _perguntas[indiceRespondido].correta;
    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || indiceRespondido != _indice) return;
    final nome = prefs.getString('nome_crianca')?.trim() ?? '';
    final saudacao = nome.isEmpty ? '' : '$nome, ';

    final mensagem = ingles
        ? (acertou
            ? 'Great job! ${saudacao}You got it right!'
            : 'Not quite, ${saudacao}the correct answer is $respostaCorreta. Keep trying!')
        : (acertou
            ? 'Parabéns! ${saudacao}Você acertou! Muito bem!'
            : 'Não foi dessa vez, ${saudacao}a resposta correta é $respostaCorreta. Continue tentando!');

    await _vozMiguelito.stop();
    if (!mounted || indiceRespondido != _indice) return;
    await VozMiguelito.configurar(_vozMiguelito);
    if (!mounted || indiceRespondido != _indice) return;
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
      appBar: AppBar(
        actions: const [BotoesNavegacao()],title: Text('🔢 Matemática • ${widget.nivel.titulo}')),
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
                if (ConfiguracoesJogo.instancia.instrucoesAudio)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: respondida
                          ? () => _falarResultado(acertou)
                          : _falarPergunta,
                      icon: const Icon(Icons.volume_up),
                      label: Text(ConfiguracoesJogo.instancia.idioma == 'en-US'
                          ? (respondida ? 'Hear feedback again' : 'Hear question and options')
                          : (respondida ? 'Ouvir resultado novamente' : 'Ouvir pergunta e alternativas')),
                    ),
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
                          '🤖 Miguelzãoo pergunta:',
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
      appBar: AppBar(
        actions: const [BotoesNavegacao()],title: const Text('🏆 Resultado')),
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
  String _idioma = 'pt-BR';

  @override
  void initState() {
    super.initState();
    _carregarIdioma();
  }

  Future<void> _carregarIdioma() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _idioma = prefs.getString('idioma_miguelito') ?? 'pt-BR');
  }

  Future<void> _mudarIdioma(String idioma) async {
    await ConfiguracoesJogo.instancia.alterarIdioma(idioma);
    if (mounted) setState(() => _idioma = idioma);
  }

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
    final ingles = _idioma == 'en-US';
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1099EF), Color(0xFF76D8FF), Color(0xFFE4F9FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, size) {
              final pequeno = size.maxHeight < 650;
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        Text(
                          'Miguelzãoo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: pequeno ? 38 : 48,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD32B),
                            shadows: const [
                              Shadow(color: Color(0xFF074CA7), offset: Offset(2, 4), blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ingles ? 'Learning Through Play' : 'Aprender Brincando',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: pequeno ? 8 : 16),
                        // Mascote em área própria: não fica atrás do título ou do formulário.
                        SizedBox(
                          height: pequeno ? 130 : 200,
                          child: Image.asset(
                            'Menino feliz com tablet azul.png',
                            fit: BoxFit.contain,
                            semanticLabel: ingles ? 'Miguelzãoo using a tablet' : 'Miguelzãoo usando um tablet',
                            errorBuilder: (_, __, ___) => const AvatarMiguelito(tamanho: 150),
                          ),
                        ),
                        SizedBox(height: pequeno ? 8 : 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.97),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33075E9B), blurRadius: 22, offset: Offset(0, 9)),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ingles ? '🌟 Welcome, explorer!' : '🌟 Olá, explorador!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF153A79),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ingles ? 'What is your first name?' : 'Como você se chama?',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF395577), fontSize: 17),
                              ),
                              const SizedBox(height: 18),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'pt-BR', label: Text('🇧🇷 Português')),
                                  ButtonSegment(value: 'en-US', label: Text('🇺🇸 English')),
                                ],
                                selected: {_idioma},
                                onSelectionChanged: (v) => _mudarIdioma(v.first),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _nomeController,
                                maxLength: 30,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _salvarNome(),
                                decoration: InputDecoration(
                                  labelText: ingles ? 'Your first name' : 'Seu primeiro nome',
                                  hintText: ingles ? 'Enter your name' : 'Digite seu nome',
                                  prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF1765D1)),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F8FF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: _salvarNome,
                                  icon: const Icon(Icons.rocket_launch_rounded),
                                  label: Text(
                                    ingles ? 'START MY ADVENTURE' : 'COMEÇAR AVENTURA',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF15B72B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
