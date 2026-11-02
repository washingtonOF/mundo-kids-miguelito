import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/jogos_extras.dart';

void main() {
  test('Bancos educativos têm perguntas completas e respostas válidas', () {
    final bancos = {
      'Português': perguntasPortugues,
      'Português com instruções em inglês': perguntasPortuguesIngles,
      'Cores e formas': perguntasCores,
      'Colors and shapes': perguntasCoresIngles,
      'Matemática': perguntasMatematica,
      'Math': perguntasMatematicaIngles,
    };

    for (final entry in bancos.entries) {
      expect(entry.value, isNotEmpty, reason: entry.key);
      for (final pergunta in entry.value) {
        expect(pergunta.texto.trim(), isNotEmpty, reason: entry.key);
        expect(pergunta.alternativas.length, 4, reason: pergunta.texto);
        expect(pergunta.correta, inInclusiveRange(0, 3), reason: pergunta.texto);
        expect(
          pergunta.alternativas.every((opcao) => opcao.trim().isNotEmpty),
          isTrue,
          reason: pergunta.texto,
        );
        expect(
          pergunta.alternativas.toSet().length,
          pergunta.alternativas.length,
          reason: 'Alternativas repetidas: ${pergunta.texto}',
        );
      }
    }
  });

  test('Bancos de português e cores têm 10 questões em cada idioma', () {
    expect(perguntasPortugues.length, 10);
    expect(perguntasPortuguesIngles.length, 10);
    expect(perguntasCores.length, 10);
    expect(perguntasCoresIngles.length, 10);
  });
}
