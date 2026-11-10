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
      duration: const Duration(milliseconds: 1250),
      lowerBound: 0.45,
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
                child: OutlinedButton.icon(
                  onPressed: _maximizar,
                  icon: Icon(
                    _telaCheia ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _telaCheia ? 'RESTAURAR' : 'TELA CHEIA',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xEAF8FAFF),
                    foregroundColor: const Color(0xFF5946A5),
                    side: const BorderSide(color: Color(0x886B4EE6)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 34),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
