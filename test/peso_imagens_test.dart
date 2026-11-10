import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imagens do jogo respeitam limite de tamanho', () {
    final diretorio = Directory('assets/images');
    expect(diretorio.existsSync(), isTrue);

    final imagens = diretorio
        .listSync(recursive: true)
        .whereType<File>()
        .where((arquivo) => RegExp(r'\.(png|jpg|jpeg|webp)$',
                caseSensitive: false)
            .hasMatch(arquivo.path))
        .toList();

    expect(imagens, isNotEmpty);
    const limitePorImagem = 3 * 1024 * 1024;
    const limiteTotal = 12 * 1024 * 1024;
    var total = 0;
    for (final imagem in imagens) {
      final bytes = imagem.lengthSync();
      total += bytes;
      expect(bytes, lessThan(limitePorImagem),
          reason: 'Imagem muito pesada: ${imagem.path}');
    }
    expect(total, lessThan(limiteTotal),
        reason: 'Pacote de imagens muito pesado para conexões móveis');
  });
}
