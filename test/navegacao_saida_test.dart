import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/botoes_navegacao.dart';

void main() {
  testWidgets('Cancelar saída mantém a atividade aberta', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(body: _PaginaAtividade()),
    ));
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Sair da atividade?'), findsOneWidget);
    await tester.tap(find.text('Continuar jogando'));
    await tester.pumpAndSettle();
    expect(find.text('Atividade em andamento'), findsOneWidget);
    expect(find.text('Sair da atividade?'), findsNothing);
  });

  testWidgets('Confirmar saída retorna à primeira rota', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: Center(child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const _PaginaAtividade()),
          ),
          child: const Text('Abrir atividade'),
        )),
      )),
    ));
    await tester.tap(find.text('Abrir atividade'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir atividade'), findsOneWidget);
    expect(find.text('Atividade em andamento'), findsNothing);
  });
}

class _PaginaAtividade extends StatelessWidget {
  const _PaginaAtividade();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(actions: const [BotoesNavegacao(confirmarSaida: true)]),
    body: const Center(child: Text('Atividade em andamento')),
  );
}
