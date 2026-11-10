import 'package:flutter/services.dart';

Future<void> alternarTelaCheia(bool ativar) async {
  await SystemChrome.setEnabledSystemUIMode(
    ativar ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
  );
}

Future<void> abrirCentralJogos() async {}
