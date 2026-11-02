import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/jogos_extras.dart';

void main() {
  final bancos = <String, List<Pergunta>>{
    'Português': perguntasPortugues,
    'Português (instruções em inglês)': perguntasPortuguesIngles,
    'Cores e formas': perguntasCores,
    'Cores e formas (inglês)': perguntasCoresIngles,
    'Matemática (equipes)': perguntasMatematica,
    'Matemática (equipes, inglês)': perguntasMatematicaIngles,
  };

  for (final entrada in bancos.entries) {
    test('${entrada.key}: questões com alternativas e gabarito válidos', () {
      expect(entrada.value, isNotEmpty);
      final textos = <String>{};
      for (final pergunta in entrada.value) {
        expect(pergunta.texto.trim(), isNotEmpty);
        expect(textos.add(pergunta.texto), isTrue,
            reason: 'Questão repetida: ${pergunta.texto}');
        expect(pergunta.alternativas.length, 4,
            reason: pergunta.texto);
        expect(pergunta.correta, inInclusiveRange(0, 3),
            reason: pergunta.texto);
        expect(pergunta.alternativas.every((opcao) => opcao.trim().isNotEmpty),
            isTrue, reason: pergunta.texto);
        expect(pergunta.alternativas.toSet().length, 4,
            reason: pergunta.texto);
      }
    });
  }

  test('Português possui questões correspondentes nos dois idiomas', () {
    expect(perguntasPortuguesIngles.length, perguntasPortugues.length);
    for (var i = 0; i < perguntasPortugues.length; i++) {
      expect(perguntasPortuguesIngles[i].correta, perguntasPortugues[i].correta);
    }
  });

  test('Cores e formas possuem questões correspondentes nos dois idiomas', () {
    expect(perguntasCoresIngles.length, perguntasCores.length);
    for (var i = 0; i < perguntasCores.length; i++) {
      expect(perguntasCoresIngles[i].correta, perguntasCores[i].correta);
    }
  });

  test('Há perguntas disponíveis em todas as faixas de dificuldade', () {
    for (final perguntas in [
      perguntasPortugues,
      perguntasPortuguesIngles,
      perguntasCores,
      perguntasCoresIngles,
    ]) {
      expect(perguntas.take(4), isNotEmpty);
      expect(perguntas.skip(4).take(4), isNotEmpty);
      expect(perguntas.skip(8), isNotEmpty);
    }
  });
}
