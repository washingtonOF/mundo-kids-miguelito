import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/configuracoes_jogo.dart';
import 'package:mundo_kids/voz_miguelito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Voz converte operações matemáticas em português', () {
    expect(ConfiguracoesJogo.instancia.idioma, 'pt-BR');
    final texto = VozMiguelito.preparar('3 × 4 + 2 = 14');
    expect(texto, contains('vezes'));
    expect(texto, contains('mais'));
    expect(texto, contains('é igual a'));
  });

  test('Voz identifica cores e enumera alternativas', () {
    final texto = VozMiguelito.pergunta(
      '🔴 Qual é esta cor?',
      ['Azul', 'Verde', 'Vermelho', 'Amarelo'],
    );
    expect(texto, contains('círculo vermelho'));
    expect(texto, contains('Opção A: Azul'));
    expect(texto, contains('Opção D: Amarelo'));
  });
}
