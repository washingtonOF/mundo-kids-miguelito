import 'package:flutter/material.dart';
import 'configuracoes_jogo.dart';

/// Atalho visual para a mesma preferência persistida em Configurações.
class BotaoVoz extends StatelessWidget {
  const BotaoVoz({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfiguracoesJogo.instancia;
    return AnimatedBuilder(
      animation: config,
      builder: (context, _) {
        final ligada = config.instrucoesAudio;
        final ingles = config.idioma == 'en-US';
        return Tooltip(
          message: ingles
              ? (ligada ? 'Turn voice off' : 'Turn voice on')
              : (ligada ? 'Desligar voz' : 'Ligar voz'),
          child: Semantics(
            label: ingles
                ? (ligada ? 'Voice on' : 'Voice off')
                : (ligada ? 'Voz ligada' : 'Voz desligada'),
            button: true,
            child: IconButton(
              icon: Icon(ligada ? Icons.volume_up : Icons.volume_off),
              onPressed: () => config.alterarInstrucoesAudio(!ligada),
            ),
          ),
        );
      },
    );
  }
}
