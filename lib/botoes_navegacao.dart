import 'package:flutter/material.dart';
import 'main.dart';

/// Navegação acessível compartilhada pelas telas do Miguelzãoo.
class BotoesNavegacao extends StatelessWidget {
  const BotoesNavegacao({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: 'Voltar',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: navigator.canPop() ? () => navigator.pop() : null,
      ),
      IconButton(
        tooltip: 'Início - jogos',
        icon: const Icon(Icons.home_rounded),
        onPressed: () {
          var encontrouMenu = false;
          navigator.popUntil((route) {
            if (route is MaterialPageRoute && route.builder(context) is TelaJogos) {
              encontrouMenu = true;
              return true;
            }
            return route.isFirst;
          });
          if (!encontrouMenu) {
            navigator.push(MaterialPageRoute(builder: (_) => const TelaJogos()));
          }
        },
      ),
    ]);
  }
}
