import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/banco_conteudo.dart' as banco;

void main() {
  test('O vocabulário educativo contém 200 palavras distribuídas por categoria', () {
    expect(banco.palavrasEducativas.length, 10);
    final palavras = banco.palavrasEducativas.values.expand((grupo) => grupo).toList();
    expect(palavras.length, 200);
    for (final grupo in banco.palavrasEducativas.entries) {
      expect(grupo.value.length, 20, reason: grupo.key);
      expect(grupo.value.every((palavra) => palavra.trim().isNotEmpty), isTrue);
      expect(grupo.value.toSet().length, grupo.value.length, reason: grupo.key);
    }
  });

  test('As 200 questões extras têm quatro alternativas distintas e gabarito válido', () {
    final questoes = banco.questoesExtras.values.expand((grupo) => grupo).toList();
    expect(questoes.length, 200);
    for (final questao in questoes) {
      expect(questao.texto.trim(), isNotEmpty);
      expect(questao.opcoes.length, 4, reason: questao.texto);
      expect(questao.correta, inInclusiveRange(0, 3), reason: questao.texto);
      expect(questao.opcoes.every((opcao) => opcao.trim().isNotEmpty), isTrue);
      expect(questao.opcoes.toSet().length, 4, reason: questao.texto);
    }
  });

  test('A mesma sala sempre produz a mesma semente', () {
    expect(banco.sementeSala('ABC234'), banco.sementeSala('ABC234'));
    expect(banco.sementeSala('ABC234'), isNot(banco.sementeSala('XYZ789')));
  });
}
