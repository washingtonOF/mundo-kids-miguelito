import 'package:flutter_tts/flutter_tts.dart';
import 'configuracoes_jogo.dart';

/// Configuração de voz comum às modalidades individual e multiplayer.
class VozMiguelito {
  static bool get habilitada => ConfiguracoesJogo.instancia.instrucoesAudio;

  static bool get _ingles => ConfiguracoesJogo.instancia.idioma == 'en-US';

  /// Expande símbolos para que o sintetizador pronuncie a pergunta no idioma ativo.
  static String preparar(String texto) {
    if (_ingles) {
      return texto
          .replaceAll('🔴', 'red circle')
          .replaceAll('🔵', 'blue circle')
          .replaceAll('🟡', 'yellow circle')
          .replaceAll('🟩', 'green square')
          .replaceAll('🔺', 'red triangle')
          .replaceAll('⬛', 'black square')
          .replaceAll('⚪', 'white circle')
          .replaceAll('🔷', 'blue diamond')
          .replaceAll('×', ' times ')
          .replaceAll('÷', ' divided by ')
          .replaceAll('+', ' plus ')
          .replaceAll('-', ' minus ')
          .replaceAll('=', ' equals ');
    }
    return texto
        .replaceAll('🔴', 'círculo vermelho')
        .replaceAll('🔵', 'círculo azul')
        .replaceAll('🟡', 'círculo amarelo')
        .replaceAll('🟩', 'quadrado verde')
        .replaceAll('🔺', 'triângulo vermelho')
        .replaceAll('⬛', 'quadrado preto')
        .replaceAll('⚪', 'círculo branco')
        .replaceAll('🔷', 'losango azul')
        .replaceAll('×', ' vezes ')
        .replaceAll('÷', ' dividido por ')
        .replaceAll('+', ' mais ')
        .replaceAll('-', ' menos ')
        .replaceAll('=', ' é igual a ');
  }

  static String pergunta(String texto, List<String> opcoes) {
    final rotulo = _ingles ? 'Option' : 'Opção';
    final alternativas = opcoes.asMap().entries.map(
      (e) => '$rotulo ${String.fromCharCode(65 + e.key)}: ${preparar(e.value)}.',
    ).join(' ');
    return '${preparar(texto)}. $alternativas';
  }

  static Future<void> configurar(FlutterTts voz) async {
    await voz.setLanguage(_ingles ? 'en-US' : 'pt-BR');
    await voz.setSpeechRate(0.48);
    await voz.setVolume(1.0);
    await voz.setPitch(1.05);
  }
}
