import 'dart:html' as html;

Future<void> alternarTelaCheia(bool ativar) async {
  if (ativar) {
    await html.document.documentElement?.requestFullscreen();
  } else if (html.document.fullscreenElement != null) {
    html.document.exitFullscreen();
  }
}
