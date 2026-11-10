import 'package:flutter/material.dart';
import 'main.dart';

/// O AppBar já fornece a seta Voltar automaticamente quando há página anterior.
/// Este componente mantém somente o atalho compacto para o menu de jogos.
class BotoesNavegacao extends StatelessWidget {
  const BotoesNavegacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Início - jogos',
        visualDensity: VisualDensity.compact,
        iconSize: 21,
        icon: const Icon(Icons.home_outlined),
        onPressed: () {
          final navigator = Navigator.of(context);
          var encontrouMenu = false;
          navigator.popUntil((route) {
            if (route is MaterialPageRoute && route.settings.name == '/jogos') {
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
    );
  }
}
