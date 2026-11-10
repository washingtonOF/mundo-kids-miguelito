import 'package:flutter/material.dart';
import 'tela_cheia_stub.dart' if (dart.library.html) 'tela_cheia_web.dart' as tela;

class ControlesJanela extends StatefulWidget {
  final Widget child;
  const ControlesJanela({super.key, required this.child});
  @override
  State<ControlesJanela> createState() => _ControlesJanelaState();
}

class _ControlesJanelaState extends State<ControlesJanela>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso;
  bool _telaCheia = false;

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.65,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  Future<void> _maximizar() async {
    try {
      await tela.alternarTelaCheia(!_telaCheia);
      if (mounted) setState(() => _telaCheia = !_telaCheia);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tela cheia indisponível neste navegador.')),
      );
    }
  }

  Future<void> _fechar() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Sair do jogo?'),
        content: const Text('Você quer voltar à central de jogos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogo, false),
              child: const Text('CONTINUAR')),
          FilledButton(onPressed: () => Navigator.pop(dialogo, true),
              child: const Text('SAIR')),
        ],
      ),
    );
    if (sair != true || !mounted) return;
    if (_telaCheia) {
      try { await tela.alternarTelaCheia(false); } catch (_) {}
    }
    await tela.abrirCentralJogos();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final reduzirMovimento = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _pulso,
                builder: (context, child) => Opacity(
                  opacity: reduzirMovimento ? 1 : _pulso.value,
                  child: child,
                ),
                child: FilledButton.icon(
                  onPressed: _maximizar,
                  icon: Icon(_telaCheia ? Icons.fullscreen_exit : Icons.fullscreen),
                  label: Text(_telaCheia ? 'RESTAURAR' : 'MAXIMIZAR'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC928),
                    foregroundColor: const Color(0xFF172C58),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 42),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Fechar jogo',
                onPressed: _fechar,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFD83C42),
                  foregroundColor: Colors.white,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
