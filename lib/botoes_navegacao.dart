import 'package:flutter/material.dart';

/// Atalho compacto para a tela inicial do Miguelzãoo.
/// Preserva a navegação do sistema e evita empilhar telas duplicadas.
class BotoesNavegacao extends StatelessWidget {
  const BotoesNavegacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Voltar ao início do Miguelzãoo',
        visualDensity: VisualDensity.compact,
        iconSize: 23,
        icon: const Icon(Icons.home_rounded),
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }
}
