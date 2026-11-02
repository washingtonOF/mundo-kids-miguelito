import 'package:flutter_tts/flutter_tts.dart';
import 'configuracoes_jogo.dart';

/// Configuração de voz comum às modalidades individual e multiplayer.
class VozMiguelito {
  static bool get habilitada => ConfiguracoesJogo.instancia.instrucoesAudio;

  static String preparar(String texto) => texto
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
      .replaceAll('=', ' é igual a ');

  static String pergunta(String texto, List<String> opcoes) {
    final alternativas = opcoes.asMap().entries.map((e) =>
        'Opção ${String.fromCharCode(65 + e.key)}: ${preparar(e.value)}.').join(' ');
    return '${preparar(texto)}. $alternativas';
  }

  static Future<void> configurar(FlutterTts voz) async {
    await voz.setLanguage('pt-BR');
    await voz.setSpeechRate(0.48);
    await voz.setVolume(1.0);
    await voz.setPitch(1.05);
  }
}
