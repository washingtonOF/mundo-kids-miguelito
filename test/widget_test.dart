import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mundo_kids/configuracoes_jogo.dart';
import 'package:mundo_kids/voz_miguelito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'idioma_miguelito': 'pt-BR'});
    await ConfiguracoesJogo.instancia.carregar();
  });

  test('Narração em português converte símbolos matemáticos', () {
    final texto = VozMiguelito.preparar('3 × 4 + 2 = 14');
    expect(texto, contains('vezes'));
    expect(texto, contains('mais'));
    expect(texto, contains('é igual a'));
  });

  test('Narração em português identifica cores e alternativas', () {
    final texto = VozMiguelito.pergunta(
      '🔴 Qual é esta cor?',
      ['Azul', 'Verde', 'Vermelho', 'Amarelo'],
    );
    expect(texto, contains('círculo vermelho'));
    expect(texto, contains('Opção A: Azul'));
    expect(texto, contains('Opção D: Amarelo'));
  });

  test('Narração em inglês converte símbolos matemáticos', () async {
    await ConfiguracoesJogo.instancia.alterarIdioma('en-US');
    final texto = VozMiguelito.preparar('3 × 4 + 2 = 14');
    expect(texto, contains('times'));
    expect(texto, contains('plus'));
    expect(texto, contains('equals'));
    expect(texto, isNot(contains('vezes')));
  });

  test('Narração em inglês identifica cores e alternativas', () async {
    await ConfiguracoesJogo.instancia.alterarIdioma('en-US');
    final texto = VozMiguelito.pergunta(
      '🔴 What color is this?',
      ['Blue', 'Green', 'Red', 'Yellow'],
    );
    expect(texto, contains('red circle'));
    expect(texto, contains('Option A: Blue'));
    expect(texto, contains('Option D: Yellow'));
  });

  test('Idioma escolhido permanece salvo nas preferências', () async {
    await ConfiguracoesJogo.instancia.alterarIdioma('en-US');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('idioma_miguelito'), 'en-US');
    await ConfiguracoesJogo.instancia.carregar();
    expect(ConfiguracoesJogo.instancia.idioma, 'en-US');
  });
}
