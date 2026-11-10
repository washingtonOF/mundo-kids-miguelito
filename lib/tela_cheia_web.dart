import 'dart:html' as html;

Future<void> alternarTelaCheia(bool ativar) async {
  if (ativar) {
    await html.document.documentElement?.requestFullscreen();
  } else if (html.document.fullscreenElement != null) {
    html.document.exitFullscreen();
  }
}

Future<void> abrirCentralJogos() async {
  html.window.location.assign('https://washingtonof.github.io/jogos/');
}
