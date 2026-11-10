import 'configuracoes_jogo.dart';
import 'banco_conteudo.dart' as banco;
import 'dart:math';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'voz_miguelito.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Salas online do Mundo Kids. Requer as regras do Realtime Database
/// fornecidas separadamente, antes de testar a criação/entrada.
class ServicoMultiplayer {
  static final FirebaseDatabase _banco = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL: 'https://mundo-kids-ee4e7-default-rtdb.firebaseio.com',
  );

  static final Random _random = Random.secure();

  // Garante uma sessão válida antes de acessar o banco.
  static Future<User> _usuarioAutenticado() async {
    final auth = FirebaseAuth.instance;
    final atual = auth.currentUser;
    if (atual != null) return atual;
    final credencial = await auth.signInAnonymously();
    final usuario = credencial.user;
    if (usuario == null) {
      throw StateError('Não foi possível autenticar o jogador no Firebase.');
    }
    return usuario;
  }
  static DatabaseReference sala(String codigo) => _banco.ref('salas/$codigo');

  static String _gerarCodigo() {
    const caracteres = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => caracteres[_random.nextInt(caracteres.length)],
    ).join();
  }

  static Future<String> criarSala(String apelido) async {
    final usuario = await _usuarioAutenticado();
    final nome = apelido.trim();
    if (nome.isEmpty || nome.length > 30) {
      throw ArgumentError('Digite um apelido de até 30 caracteres.');
    }

    // A criação usa set(), pois transações exigem leitura prévia.
    // O Firebase só autoriza criar uma sala ainda inexistente.
    final codigo = _gerarCodigo();
    await sala(codigo).set({
      'criador': usuario.uid,
      'status': 'aguardando',
      'maxJogadores': 20,
      'tipo': 'misto',
      'tempoPergunta': 20,
      'criadaEm': ServerValue.timestamp,
      'vagas': {
        'vaga0': {'uid': usuario.uid, 'nome': nome, 'pontos': 0},
      },
    });
    return codigo;
  }

  /// Apenas o criador pode iniciar, com pelo menos dois participantes.
  static Future<void> iniciarPartida(String codigo) async {
    final usuario = await _usuarioAutenticado();
    final referencia = sala(codigo);
    final snapshot = await referencia.get();
    if (!snapshot.exists || snapshot.value is! Map) {
      throw StateError('Sala não encontrada.');
    }
    final dados = Map<String, dynamic>.from(snapshot.value as Map);
    if (dados['criador'] != usuario.uid) {
      throw StateError('Somente o criador pode iniciar a partida.');
    }
    if (dados['status'] != 'aguardando') {
      throw StateError('A partida já foi iniciada.');
    }
    final vagas = dados['vagas'];
    if (vagas is! Map || vagas.length < 2) {
      throw StateError('São necessários pelo menos dois jogadores.');
    }
    // A regra do banco valida novamente todas as condições no servidor.
    await referencia.update({'status': 'jogando', 'inicioEm': ServerValue.timestamp});
  }

  /// Apenas o líder escolhe a modalidade antes de iniciar a partida.
  static Future<void> escolherTipo(String codigo, String tipo) async {
    const permitidos = {'matematica', 'portugues', 'cores', 'gerais', 'misto'};
    if (!permitidos.contains(tipo)) throw ArgumentError('Modalidade inválida.');
    final usuario = await _usuarioAutenticado();
    final snapshot = await sala(codigo).get();
    if (snapshot.value is! Map) throw StateError('Sala não encontrada.');
    final dados = Map<String, dynamic>.from(snapshot.value as Map);
    if (dados['criador'] != usuario.uid || dados['status'] != 'aguardando') {
      throw StateError('Somente o líder pode escolher antes da partida.');
    }
    await sala(codigo).child('tipo').set(tipo);
  }

  /// O anfitrião define o tempo antes do início da partida.
  static Future<void> escolherTempo(String codigo, int segundos) async {
    if (![20, 25, 30, 35].contains(segundos)) {
      throw ArgumentError('Tempo inválido.');
    }
    final usuario = await _usuarioAutenticado();
    final snapshot = await sala(codigo).get();
    if (snapshot.value is! Map) throw StateError('Sala não encontrada.');
    final dados = Map<String, dynamic>.from(snapshot.value as Map);
    if (dados['criador'] != usuario.uid || dados['status'] != 'aguardando') {
      throw StateError('Somente o líder pode alterar o tempo antes da partida.');
    }
    await sala(codigo).child('tempoPergunta').set(segundos);
  }

  /// Valida o convite localmente antes de tentar autenticar.
  static String normalizarCodigo(String codigo) => codigo.trim().toUpperCase();

  static bool codigoValido(String codigo) =>
      RegExp(r'^[A-HJ-KM-NP-Z2-9]{6}$').hasMatch(normalizarCodigo(codigo));

  static Future<void> entrarSala(String codigo, String apelido) async {
    codigo = normalizarCodigo(codigo);
    final nome = apelido.trim();
    if (nome.isEmpty || nome.length > 30) {
      throw ArgumentError('Digite um apelido de até 30 caracteres.');
    }
    if (!codigoValido(codigo)) {
      throw ArgumentError('Código inválido. Confira os seis caracteres.');
    }
    final usuario = await _usuarioAutenticado();
    final referencia = sala(codigo);
    // As regras de segurança só permitem ler a sala completa depois
    // de ingressar. Consultar apenas vagas individuais liberadas para
    // ingresso; nunca fazer get() na sala antes de ocupar uma vaga.
    // O ingresso não deve depender da leitura da sala nem de transações:
    // o Firebase Spark valida a vaga vazia de forma atômica na regra .write.
    // Uma escrita direta evita a exigência de .read do runTransaction().
    // Se a vaga já estiver ocupada, a regra !data.exists() rejeita o set().
    var vagasRecusadas = 0;
    for (var indice = 1; indice < 20; indice++) {
      try {
        await referencia.child('vagas/vaga$indice').set({
          'uid': usuario.uid,
          'nome': nome,
          'pontos': 0,
        });
        return;
      } on FirebaseException catch (erro) {
        if (erro.code == 'permission-denied') {
          vagasRecusadas++;
          continue; // Vaga ocupada ou sala fechada: tentar a próxima.
        }
        throw StateError('Erro ao ingressar: ${erro.code}.');
      }
    }
    if (vagasRecusadas == 19) {
      throw StateError(
        'O Firebase recusou todas as vagas. A sala pode estar cheia, '
        'encerrada ou as regras de escrita podem estar bloqueando o ingresso.',
      );
    }
    throw StateError('Não foi possível entrar. Confira o código ou as vagas disponíveis.');
  }
}

class TelaMultiplayerOnline extends StatefulWidget {
  final String? conviteSala;
  const TelaMultiplayerOnline({super.key, this.conviteSala});

  @override
  State<TelaMultiplayerOnline> createState() => _TelaMultiplayerOnlineState();
}

class _TelaMultiplayerOnlineState extends State<TelaMultiplayerOnline> {
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    final convite = widget.conviteSala;
    if (convite != null && convite.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entrarComCodigo(convite.toUpperCase());
      });
    }
  }

  Future<void> _entrarComCodigo(String codigo) async {
    if (_ocupado) return;
    final nome = await _apelido();
    if (nome == null || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await ServicoMultiplayer.entrarSala(codigo, nome);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => TelaEsperaMultiplayer(codigo: codigo),
      ));
    } catch (erro) {
      _erro(erro);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<String?> _apelido() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString('nome_crianca')?.trim() ?? '';
    if (salvo.isNotEmpty && salvo.length <= 30) return salvo;
    if (!mounted) return null;
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como o Miguelzãoo pode chamar você?'),
        content: TextField(
          controller: controller,
          maxLength: 30,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Primeiro nome ou apelido',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nome == null || nome.isEmpty) return null;
    await prefs.setString('nome_crianca', nome);
    return nome;
  }

  void _erro(Object erro) {
    if (!mounted) return;
    final mensagem =
        erro is FirebaseException && erro.code == 'permission-denied'
        ? 'Permissão negada no Realtime Database. Confira se as regras foram PUBLICADAS no projeto mundo-kids-ee4e7 e se a autenticação anônima está ativada.'
        : erro.toString().replaceFirst(
            RegExp(r'^(Bad state|Invalid argument): '),
            '',
          );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _criar() async {
    if (_ocupado) return;
    final nome = await _apelido();
    if (nome == null || !mounted) return;
    setState(() => _ocupado = true);
    try {
      final codigo = await ServicoMultiplayer.criarSala(nome);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaEsperaMultiplayer(codigo: codigo),
        ),
      );
    } catch (erro) {
      _erro(erro);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _entrar() async {
    if (_ocupado) return;
    final controller = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrar em uma sala'),
        content: TextField(
          controller: controller,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Código da sala',
            hintText: 'Ex.: ABC234',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim().toUpperCase()),
            child: const Text('ENTRAR'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (codigo == null || !mounted) return;
    await _entrarComCodigo(codigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Multiplayer Online'),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
      body: _fundo(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _painel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🤖 Miguelzãoo Multiplayer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31235B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jogue online com seus amigos!\nDe 2 a 20 jogadores por sala.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  if (_ocupado)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _ocupado ? null : _criar,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('CRIAR SALA'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _ocupado ? null : _entrar,
                      icon: const Icon(Icons.login),
                      label: const Text('ENTRAR EM UMA SALA'),
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

class TelaEsperaMultiplayer extends StatelessWidget {
  final String codigo;
  const TelaEsperaMultiplayer({super.key, required this.codigo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Sala de espera'),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
      body: _fundo(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _painel(
              child: StreamBuilder<DatabaseEvent>(
                stream: ServicoMultiplayer.sala(codigo).onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Não foi possível acompanhar a sala. Verifique as regras do Firebase.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final valor = snapshot.data!.snapshot.value;
                  if (valor == null || valor is! Map) {
                    return const Text('Esta sala não está mais disponível.');
                  }
                  final dados = Map<String, dynamic>.from(valor);
                  final jogadores = dados['vagas'] is Map
                      ? Map<String, dynamic>.from(dados['vagas'] as Map)
                      : <String, dynamic>{};
                  final nomes = jogadores.values.map((item) {
                    if (item is Map) {
                      return (item['nome'] ?? 'Jogador').toString();
                    }
                    return 'Jogador';
                  }).toList()..sort();
                  final tipo = dados['tipo']?.toString() ?? 'misto';
                   final tempo = (dados['tempoPergunta'] as num?)?.toInt() ?? 20;
                   final iniciado = dados['status'] == 'jogando';
                  final anfitriao = dados['criador'] ==
                      FirebaseAuth.instance.currentUser?.uid;
                  if (iniciado) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => TelaCampeonatoMultiplayer(codigo: codigo),
                        ));
                      }
                    });
                    return const CircularProgressIndicator();
                  }
                  // Convidados veem apenas a sala de espera, sem QR Code
                  // nem controles exclusivos do anfitrião.
                  if (!anfitriao) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_top_rounded,
                            size: 64, color: Color(0xFF6B4EE6)),
                        const SizedBox(height: 18),
                        const Text(
                          'Você entrou na sala! 🎉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF31235B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aguarde, vamos já começar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 18),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          'Jogadores na sala: ${nomes.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '👥 Participantes da sala',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF31235B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final entrada in jogadores.entries)
                          if (entrada.value is Map)
                            _NomeFlutuante(
                              key: ValueKey('participante_${entrada.key}'),
                              nome: (entrada.value['nome'] ?? 'Jogador').toString(),
                              anfitriao: entrada.value['uid'] == dados['criador'],
                            ),
                        const SizedBox(height: 12),
                        Text(
                          '🎮 ${tiposCampeonato[tipo] ?? 'Misto'} · $tempo segundos por pergunta',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'O anfitrião vai iniciar a partida. Você não precisa fazer mais nada.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🤖 Amigos reunidos!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF31235B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Compartilhe o código da sala:'),
                      const SizedBox(height: 8),
                      SelectableText(
                        codigo,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Color(0xFF6B4EE6),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: codigo));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Código copiado!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('COPIAR CÓDIGO'),
                      ),
                      const SizedBox(height: 12),
                      const Text('📱 Escaneie para entrar nesta sala'),
                      const SizedBox(height: 8),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: QrImageView(
                          data: 'https://washingtonof.github.io/mundo-kids-miguelito/?sala=$codigo',
                          version: QrVersions.auto,
                          size: 160,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Clipboard.setData(ClipboardData(
                          text: 'https://washingtonof.github.io/mundo-kids-miguelito/?sala=$codigo',
                        )),
                        icon: const Icon(Icons.link),
                        label: const Text('COPIAR LINK DO CONVITE'),
                      ),
                      const Divider(height: 28),
                      Text(
                        'Jogadores: ${nomes.length} de 20',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final nome in nomes)
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.person,
                            color: Color(0xFF6B4EE6),
                          ),
                          title: Text(nome),
                        ),
                      const SizedBox(height: 14),
                      if (anfitriao) ...[
                        const Text('👑 Escolha o tipo de campeonato',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: tiposCampeonato.containsKey(tipo) ? tipo : 'misto',
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Modalidade'),
                          items: tiposCampeonato.entries.map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                          onChanged: (escolha) async {
                            if (escolha == null) return;
                            try {
                              await ServicoMultiplayer.escolherTipo(codigo, escolha);
                            } catch (erro) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Não foi possível alterar: $erro')));
                            }
                          },
                        ),
                      ] else ...[
                        Text('🎮 Jogo escolhido pelo líder: ${tiposCampeonato[tipo] ?? 'Misto'} · $tempo segundos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                                             const SizedBox(height: 14),
                       if (anfitriao) ...[
                         const Text('⏱️ Tempo por pergunta',
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                         const SizedBox(height: 8),
                         DropdownButtonFormField<int>(
                           key: ValueKey('tempo_$tempo'),
                           initialValue: tempo,
                           isExpanded: true,
                           decoration: const InputDecoration(
                             border: OutlineInputBorder(), labelText: 'Duração da rodada'),
                           items: [20, 25, 30, 35].map((segundos) =>
                             DropdownMenuItem(value: segundos, child: Text('$segundos segundos'))).toList(),
                           onChanged: (segundos) async {
                             if (segundos == null) return;
                             try {
                               await ServicoMultiplayer.escolherTempo(codigo, segundos);
                             } catch (erro) {
                               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text('Não foi possível alterar o tempo: $erro')));
                             }
                           },
                         ),
                         const SizedBox(height: 14),
                        Text(
                          nomes.length < 2
                              ? 'Aguarde pelo menos mais um jogador.'
                              : 'Você é o anfitrião. Pode iniciar a partida!',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: nomes.length < 2
                                ? null
                                : () async {
                                    try {
                                      await ServicoMultiplayer.iniciarPartida(codigo);
                                    } catch (erro) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Não foi possível iniciar: $erro')),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('INICIAR PARTIDA'),
                          ),
                        ),
                      ] else
                        const Text(
                          'Aguardando o anfitrião iniciar a partida...',
                          textAlign: TextAlign.center,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão animado de participante: entra suavemente e flutua enquanto espera.
class _NomeFlutuante extends StatefulWidget {
  const _NomeFlutuante({
    super.key,
    required this.nome,
    required this.anfitriao,
  });

  final String nome;
  final bool anfitriao;

  @override
  State<_NomeFlutuante> createState() => _NomeFlutuanteState();
}

class _NomeFlutuanteState extends State<_NomeFlutuante>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flutuar;

  @override
  void initState() {
    super.initState();
    _flutuar = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.anfitriao ? 2200 : 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flutuar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destaque = widget.anfitriao;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, entrada, child) => Opacity(
        opacity: entrada.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.75 + 0.25 * entrada,
          child: child,
        ),
      ),
      child: AnimatedBuilder(
        animation: _flutuar,
        builder: (context, child) {
          // Deslocamento de 22px (antes eram apenas 4px, quase invisíveis).
          // A leve inclinação torna a flutuação perceptível também no celular.
          final fase = Curves.easeInOut.transform(_flutuar.value);
          return Transform.translate(
            offset: Offset(
              (fase - 0.5) * (destaque ? 7 : 11),
              (0.5 - fase) * 22,
            ),
            child: Transform.rotate(
              angle: (fase - 0.5) * (destaque ? 0.025 : 0.045),
              child: Transform.scale(
                scale: 0.97 + fase * 0.06,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 310),
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: destaque ? const Color(0xFFFFE7A0) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: destaque ? const Color(0xFFFFB930) : const Color(0xFFB7A4FF),
              width: destaque ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220C1550),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                destaque ? Icons.workspace_premium_rounded : Icons.person_rounded,
                color: destaque ? const Color(0xFF9D6200) : const Color(0xFF6B4EE6),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  widget.nome,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: destaque ? 19 : 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF31235B),
                  ),
                ),
              ),
              if (destaque) ...[
                const SizedBox(width: 7),
                const Text('👑', style: TextStyle(fontSize: 18)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Fundo sem personagem embutido: evita que o avatar fique atrás dos textos.
Widget _fundo({required Widget child}) => Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF83D8FF), Color(0xFFEAF8FF), Color(0xFFB7E5F7)],
    ),
  ),
  child: child,
);

Widget _painel({required Widget child}) => Container(
  constraints: const BoxConstraints(maxWidth: 520),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
  ),
  child: child,
);


/// Todos os clientes recebem a mesma modalidade via Firebase e usam
/// o mesmo conjunto ordenado de perguntas, definido nesta versão do app.
/// O placar é demonstrativo: para competições oficiais, a correção deve
/// ocorrer no servidor, com perguntas não expostas no cliente.
class PerguntaCampeonato {
  final String texto;
  final List<String> opcoes;
  final int correta;
  const PerguntaCampeonato(this.texto, this.opcoes, this.correta);
}

const tiposCampeonato = <String, String>{
  'matematica': '🔢 Matemática',
  'portugues': '🔤 Português',
  'cores': '🎨 Cores e Formas',
  'gerais': '🌍 Conhecimentos Gerais',
  'misto': '🎲 Misto',
};

const perguntasMatematica = <PerguntaCampeonato>[
  PerguntaCampeonato('Quanto é 8 × 7?', ['48','54','56','64'], 2),
  PerguntaCampeonato('Quanto é 90 ÷ 10?', ['9','10','8','7'], 0),
  PerguntaCampeonato('Quanto é 15 + 27?', ['32','42','52','40'], 1),
  PerguntaCampeonato('Quanto é 12 × 5?', ['50','55','60','65'], 2),
  PerguntaCampeonato('Quanto é 100 - 36?', ['74','64','66','54'], 1),
  PerguntaCampeonato('Quanto é 9 × 9?', ['72','90','81','99'], 2),
  PerguntaCampeonato('Quanto é 48 ÷ 6?', ['6','7','9','8'], 3),
  PerguntaCampeonato('Quanto é 23 + 19?', ['42','43','41','52'], 0),
  PerguntaCampeonato('Quanto é 7 × 6?', ['36','42','48','49'], 1),
  PerguntaCampeonato('Quanto é 80 - 25?', ['45','65','55','50'], 2),
];
const perguntasPortugues = <PerguntaCampeonato>[
  PerguntaCampeonato('Qual palavra está escrita corretamente?', ['Caza','Casa','Cassa','Cazza'], 1),
  PerguntaCampeonato('Qual é o plural de flor?', ['Flores','Florês','Floras','Flor'], 0),
  PerguntaCampeonato('Qual palavra é um verbo?', ['Azul','Bonito','Correr','Mesa'], 2),
  PerguntaCampeonato('Qual é o antônimo de feliz?', ['Alegre','Contente','Animado','Triste'], 3),
  PerguntaCampeonato('Qual é o feminino de ator?', ['Atriz','Atora','Atrora','Atorinha'], 0),
  PerguntaCampeonato('Qual palavra tem acento correto?', ['Cafe','Café','Cafê','Cáfe'], 1),
  PerguntaCampeonato('Qual palavra é um substantivo?', ['Pular','Rápido','Escola','Muito'], 2),
  PerguntaCampeonato('Qual é o plural de animal?', ['Animales','Animais','Animals','Animãos'], 1),
  PerguntaCampeonato('Qual sinal termina uma pergunta?', ['Ponto final','Vírgula','Exclamação','Interrogação'], 3),
  PerguntaCampeonato('Qual palavra rima com coração?', ['Canção','Janela','Livro','Bola'], 0),
];
const perguntasCores = <PerguntaCampeonato>[
  PerguntaCampeonato('Qual cor resulta da mistura de azul e amarelo?', ['Verde','Roxo','Laranja','Rosa'], 0),
  PerguntaCampeonato('Quantos lados tem um triângulo?', ['4','5','3','6'], 2),
  PerguntaCampeonato('Qual forma tem quatro lados iguais e quatro ângulos retos?', ['Círculo','Quadrado','Triângulo','Oval'], 1),
  PerguntaCampeonato('Qual cor é a de uma banana madura?', ['Azul','Verde','Amarelo','Roxo'], 2),
  PerguntaCampeonato('Qual forma não tem lados retos?', ['Retângulo','Quadrado','Triângulo','Círculo'], 3),
  PerguntaCampeonato('Qual cor resulta da mistura de vermelho e amarelo?', ['Laranja','Azul','Verde','Roxo'], 0),
  PerguntaCampeonato('Quantos lados tem um pentágono?', ['4','6','7','5'], 3),
  PerguntaCampeonato('Qual figura lembra uma bola vista de frente?', ['Triângulo','Círculo','Quadrado','Losango'], 1),
  PerguntaCampeonato('Qual cor resulta da mistura de vermelho e azul?', ['Amarelo','Verde','Roxo','Laranja'], 2),
  PerguntaCampeonato('Qual forma tem seis lados?', ['Hexágono','Pentágono','Triângulo','Octógono'], 0),
];
const perguntasGerais = <PerguntaCampeonato>[
  PerguntaCampeonato('Qual é a capital do Brasil?', ['Salvador','Brasília','Recife','Curitiba'], 1),
  PerguntaCampeonato('Qual planeta é conhecido como planeta vermelho?', ['Terra','Júpiter','Marte','Vênus'], 2),
  PerguntaCampeonato('Quantos minutos tem uma hora?', ['30','90','100','60'], 3),
  PerguntaCampeonato('Em qual continente fica o Brasil?', ['América do Sul','Europa','Ásia','África'], 0),
  PerguntaCampeonato('Qual animal é um mamífero?', ['Tubarão','Golfinho','Borboleta','Sapo'], 1),
  PerguntaCampeonato('Qual astro ilumina a Terra durante o dia?', ['Lua','Marte','Sol','Vênus'], 2),
  PerguntaCampeonato('Quantos dias tem uma semana?', ['5','6','8','7'], 3),
  PerguntaCampeonato('Qual órgão bombeia o sangue?', ['Coração','Pulmão','Estômago','Rim'], 0),
  PerguntaCampeonato('Qual é o maior oceano da Terra?', ['Atlântico','Pacífico','Índico','Ártico'], 1),
  PerguntaCampeonato('Qual instrumento mede a temperatura?', ['Régua','Bússola','Termômetro','Relógio'], 2),
];

List<PerguntaCampeonato> perguntasParaTipo(String tipo, String codigo) {
  List<PerguntaCampeonato> originais(String categoria) => switch (categoria) {
    'matematica' => perguntasMatematica,
    'portugues' => perguntasPortugues,
    'cores' => perguntasCores,
    _ => perguntasGerais,
  };
  final categorias = tipo == 'misto'
      ? <String>['matematica', 'portugues', 'cores', 'gerais']
      : <String>[tipo];
  final todas = <PerguntaCampeonato>[
    for (final categoria in categorias) ...[
      ...originais(categoria),
      for (final q in banco.questoesExtras[categoria] ?? <banco.QuestaoExtra>[])
        PerguntaCampeonato(q.texto, q.opcoes, q.correta),
    ],
  ];
  // A mesma sala recebe as mesmas 10 perguntas e ordem em todos os aparelhos.
  todas.shuffle(Random(banco.sementeSala('$codigo:$tipo')));
  return todas.take(10).toList();
}

// O Realtime Database pode representar chaves numericas como List.
// Normalizamos ambos os formatos antes de calcular o placar.
Map<String, dynamic> _mapaFirebase(dynamic valor) {
  if (valor is Map) {
    return valor.map((chave, item) => MapEntry(chave.toString(), item));
  }
  if (valor is List) {
    return {
      for (var i = 0; i < valor.length; i++)
        if (valor[i] != null) '$i': valor[i],
    };
  }
  return <String, dynamic>{};
}

int _pontosResposta(dynamic resposta, PerguntaCampeonato pergunta,
    int inicio, int rodada, int tempo) {
  if (resposta == null) return 0;
  final dados = _mapaFirebase(resposta);
  final alternativa = dados.isNotEmpty ? dados['alternativa'] : resposta;
  final marcada = alternativa is num
      ? alternativa.toInt()
      : int.tryParse(alternativa.toString());
  if (marcada != pergunta.correta) return 0;
  final momento = dados['respondidoEm'];
  if (momento is! num || tempo <= 0) return 10;
  final segundos = ((momento.toInt() - (inicio + rodada * tempo * 1000)) / 1000)
      .clamp(0.0, tempo.toDouble());
  final bonus = (5 * (1 - segundos / tempo)).ceil().clamp(0, 5);
  return 10 + bonus;
}

class TelaCampeonatoMultiplayer extends StatefulWidget {
  final String codigo;
  const TelaCampeonatoMultiplayer({super.key, required this.codigo});
  @override
  State<TelaCampeonatoMultiplayer> createState() => _TelaCampeonatoMultiplayerState();
}

class _TelaCampeonatoMultiplayerState extends State<TelaCampeonatoMultiplayer> {
  Timer? _relogio;
  StreamSubscription<DatabaseEvent>? _sincronizacaoHorario;
  int _deslocamentoServidorMs = 0;

  int get _agoraServidorMs =>
      DateTime.now().millisecondsSinceEpoch + _deslocamentoServidorMs;
  DateTime _agora = DateTime.now();
  bool _enviando = false;
  final FlutterTts _voz = FlutterTts();
  int _ultimaPerguntaLida = -1;
  int _ultimaRespostaNarrada = -1;
  bool _vozAtiva = true;

  int _sequenciaNarracao = 0;

  Future<void> _falar(String mensagem) async {
    if (!mounted || !_vozAtiva || !VozMiguelito.habilitada) return;
    final sequencia = ++_sequenciaNarracao;
    try {
      await _voz.stop();
      if (!mounted || !_vozAtiva || sequencia != _sequenciaNarracao) return;
      await VozMiguelito.configurar(_voz);
      if (!mounted || !_vozAtiva || sequencia != _sequenciaNarracao) return;
      await _voz.speak(mensagem);
    } catch (erro) {
      debugPrint('MUNDO_KIDS falha na narração: $erro');
    }
  }

  Future<void> _lerPergunta(PerguntaCampeonato pergunta) async {
    await _falar(VozMiguelito.pergunta(pergunta.texto, pergunta.opcoes));
  }

  Future<void> _narrarResultado(int pontos) async {
    final ingles = ConfiguracoesJogo.instancia.idioma == 'en-US';
    if (pontos >= 10) {
      await _falar(ingles
          ? 'Well done! You got it right and earned $pontos points!'
          : 'Muito bem! Você acertou e ganhou $pontos pontos!');
    } else {
      await _falar(ingles
          ? 'Not this time. Keep trying, you can do it!'
          : 'Não foi dessa vez. Continue tentando, você consegue!');
    }
  }
  @override
  void initState() {
    super.initState();
    VozMiguelito.configurar(_voz);
    _sincronizacaoHorario = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: 'https://mundo-kids-ee4e7-default-rtdb.firebaseio.com',
    ).ref('.info/serverTimeOffset').onValue.listen((evento) {
      final valor = evento.snapshot.value;
      if (mounted && valor is num) {
        setState(() => _deslocamentoServidorMs = valor.round());
      }
    });
    _relogio = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _agora = DateTime.now());
    });
  }
  @override
  void dispose() {
    _relogio?.cancel();
    _sincronizacaoHorario?.cancel();
    _sequenciaNarracao++;
    _vozAtiva = false;
    _voz.stop();
    super.dispose();
  }

  Future<void> _responder(int indice, int alternativa) async {
    if (_enviando) return;
    setState(() => _enviando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Jogador não autenticado.');
      final referencia = ServicoMultiplayer.sala(widget.codigo);
      final salaAtual = await referencia.get();
      if (salaAtual.value is! Map) throw StateError('Sala não encontrada.');
      final dados = Map<String, dynamic>.from(salaAtual.value as Map);
      final inicio = (dados['inicioEm'] as num?)?.toInt();
      if (inicio == null || dados['status'] != 'jogando') {
        throw StateError('A partida não está ativa.');
      }
             final tempo = (dados['tempoPergunta'] as num?)?.toInt() ?? 20;
       final rodadaLocal = ((_agoraServidorMs - inicio)
               .clamp(0, 999999999)) ~/ (tempo * 1000);
      if (rodadaLocal != indice) {
        throw StateError('A pergunta mudou. Aguarde a atualização da tela.');
      }
      final resposta = referencia.child('respostas/$indice/$uid');
      // Não sobrescreve uma resposta que já foi confirmada pelo banco.
      final existente = await resposta.get();
      if (existente.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sua resposta já foi registrada.')),
          );
        }
        return;
      }
             await resposta.set({
         'alternativa': alternativa,
         'respondidoEm': ServerValue.timestamp,
       });
    } catch (e) {
      debugPrint('MUNDO_KIDS erro ao responder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível registrar a resposta. Verifique a conexão e tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Campeonato Miguelzãoo')),
      body: _fundo(child: StreamBuilder<DatabaseEvent>(
        stream: ServicoMultiplayer.sala(widget.codigo).onValue,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Erro ao acompanhar o campeonato.'));
          if (!snap.hasData || snap.data!.snapshot.value is! Map) {
            return const Center(child: CircularProgressIndicator());
          }
          final dados = Map<String, dynamic>.from(snap.data!.snapshot.value as Map);
          final tipo = dados['tipo']?.toString() ?? 'misto';
          final perguntas = perguntasParaTipo(tipo, widget.codigo);
          final inicio = (dados['inicioEm'] as num?)?.toInt();
          if (inicio == null) return const Center(child: Text('Preparando a partida...'));
                     final tempo = (dados['tempoPergunta'] as num?)?.toInt() ?? 20;
           final decorrido = (_agoraServidorMs - inicio).clamp(0, 999999999);
           final rodada = decorrido ~/ (tempo * 1000);
           final restante = tempo - ((decorrido ~/ 1000) % tempo);
          final vagas = dados['vagas'] is Map ? Map<String, dynamic>.from(dados['vagas'] as Map) : <String, dynamic>{};
          final respostas = _mapaFirebase(dados['respostas']);
          final ranking = <({String nome, int pontos, int acertos})>[];
          for (final vaga in vagas.values) {
            if (vaga is! Map) continue;
            final uidJogador = vaga['uid']?.toString() ?? '';
            var pontos = 0;
            var acertos = 0;
            for (var i = 0; i < perguntas.length; i++) {
              final respostasRodada = _mapaFirebase(respostas['$i']);
              final respostaSalva = respostasRodada[uidJogador];
              final pontosRodada = _pontosResposta(
                  respostaSalva, perguntas[i], inicio, i, tempo);
              pontos += pontosRodada;
              if (pontosRodada >= 10) acertos++;
            }
            ranking.add((
              nome: vaga['nome']?.toString() ?? 'Jogador',
              pontos: pontos,
              acertos: acertos,
            ));
          }
          ranking.sort((a, b) {
            final comparacao = b.pontos.compareTo(a.pontos);
            return comparacao != 0 ? comparacao : a.nome.compareTo(b.nome);
          });
          final uid = FirebaseAuth.instance.currentUser?.uid;
          final minhas = _mapaFirebase(respostas['$rodada']);
          final respondeu = uid != null && minhas.containsKey(uid);
          final fim = rodada >= perguntas.length;
           final pontosMinhaResposta = !fim && respondeu
               ? _pontosResposta(minhas[uid], perguntas[rodada], inicio, rodada, tempo)
               : 0;
           // Narra o resultado somente após a resposta aparecer no Firebase.
           if (!fim && respondeu && _ultimaRespostaNarrada != rodada) {
             _ultimaRespostaNarrada = rodada;
             final pontosConfirmados = _pontosResposta(
                 minhas[uid], perguntas[rodada], inicio, rodada, tempo);
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted && _ultimaRespostaNarrada == rodada) {
                 _narrarResultado(pontosConfirmados);
               }
             });
           }
          if (!fim && rodada != _ultimaPerguntaLida) {
            _ultimaPerguntaLida = rodada;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              final pergunta = perguntas[rodada];
              if (_ultimaPerguntaLida == rodada && !respondeu) {
                await _lerPergunta(pergunta);
              }
            });
          }
          return Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _painel(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('🏠 Sala ${widget.codigo}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: widget.codigo)),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar código'),
              ),
              const SizedBox(height: 6),
              Text(tiposCampeonato[tipo] ?? '🎲 Misto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (fim) ...[
                const Text('🏆 Campeonato encerrado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (ranking.isNotEmpty) ...[
                  Text(
                    ranking.length > 1 && ranking[0].pontos == ranking[1].pontos
                        ? '🤝 Empate na liderança!'
                        : '🥇 Parabéns, ${ranking[0].nome}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold,
                        color: Color(0xFF31235B)),
                  ),
                  const SizedBox(height: 8),
                  Text('${ranking[0].pontos} pontos · ${ranking[0].acertos} acertos',
                    textAlign: TextAlign.center),
                ],
                const SizedBox(height: 18),
                for (var i = 0; i < ranking.length && i < 3; i++)
                  Card(
                    child: ListTile(
                      leading: Text(['🥇','🥈','🥉'][i],
                        style: const TextStyle(fontSize: 26)),
                      title: Text(ranking[i].nome,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${ranking[i].acertos} de ${perguntas.length} acertos'),
                      trailing: Text('${ranking[i].pontos} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 12),
                Text('Participantes: ${ranking.length}'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const TelaMultiplayerOnline(),
                      ),
                    ),
                    icon: const Icon(Icons.replay),
                    label: const Text('JOGAR NOVAMENTE · NOVA SALA'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Uma nova partida usa outro código de sala.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12)),

              ] else ...[
                Text('Pergunta ${rodada + 1} de ${perguntas.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                const SizedBox(height: 8),
                Text('⏱️ $restante segundos', style: const TextStyle(fontSize: 23, color: Color(0xFF6B4EE6))),
                const SizedBox(height: 20),
                Text(perguntas[rodada].texto,
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 10),
                 TextButton.icon(
                   onPressed: VozMiguelito.habilitada ? () => _lerPergunta(perguntas[rodada]) : null,
                   icon: const Icon(Icons.volume_up),
                   label: const Text('OUVIR PERGUNTA E ALTERNATIVAS NOVAMENTE'),
                 ),
                const SizedBox(height: 14),
                for (var i = 0; i < 4; i++) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(width: double.infinity, child: OutlinedButton(
                    onPressed: respondeu || _enviando ? null : () => _responder(rodada, i),
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8), child: Text(
                      '${String.fromCharCode(65+i)}. ${perguntas[rodada].opcoes[i]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                  )),
                ),
                if (respondeu) Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    pontosMinhaResposta >= 10
                        ? '✅ Resposta registrada! Acertou! +$pontosMinhaResposta pontos '
                          '(${pontosMinhaResposta - 10} de rapidez).'
                        : '✅ Resposta registrada! Não pontuou nesta pergunta.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text('${_mapaFirebase(respostas['$rodada']).length} de ${vagas.length} responderam'),
              ],
              if (respostas.isEmpty)
                const Text('Ainda não há respostas registradas nesta sala.',
                  style: TextStyle(fontSize: 12)),
              const Divider(height: 30),
              const Text('⭐ Placar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              for (var i = 0; i < ranking.length; i++)
                ListTile(dense: true, title: Text('${i+1}º ${ranking[i].nome}'),
                    trailing: Text('${ranking[i].pontos} pontos · ${ranking[i].acertos} acertos')),
            ]))),
          );
        },
      )),
    );
  }
}
