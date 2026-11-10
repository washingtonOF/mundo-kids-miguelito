import 'package:flutter/material.dart';

/// Atalho para o início do Miguelzãoo. Durante atividades em andamento,
/// pede confirmação para evitar perda acidental do progresso.
class BotoesNavegacao extends StatelessWidget {
  final bool confirmarSaida;
  const BotoesNavegacao({super.key, this.confirmarSaida = false});

  Future<void> _voltarInicio(BuildContext context) async {
    if (confirmarSaida) {
      final sair = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sair da atividade?'),
          content: const Text(
            'Seu progresso nesta partida será perdido. Deseja voltar ao início?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Continuar jogando'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair'),
            ),
          ],
        ),
      );
      if (sair != true) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Voltar ao início do Miguelzãoo',
        visualDensity: VisualDensity.compact,
        iconSize: 23,
        icon: const Icon(Icons.home_rounded),
        onPressed: () => _voltarInicio(context),
      ),
    );
  }
}
