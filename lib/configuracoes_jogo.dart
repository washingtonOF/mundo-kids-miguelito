import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum NivelJogo { adaptativo, facil, medio, dificil }

class ConfiguracoesJogo extends ChangeNotifier {
  ConfiguracoesJogo._();

  static final ConfiguracoesJogo instancia = ConfiguracoesJogo._();

  NivelJogo _nivel = NivelJogo.adaptativo;
  bool _modoTranquilo = true;
  bool _instrucoesAudio = true;
  bool _cronometro = true;
  String _idioma = 'pt-BR';
  String get idioma => _idioma;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _nivel = NivelJogo.values.firstWhere(
      (e) => e.name == prefs.getString('nivel_miguelito'),
      orElse: () => NivelJogo.adaptativo,
    );
    _modoTranquilo = prefs.getBool('modo_tranquilo_miguelito') ?? true;
    _instrucoesAudio = prefs.getBool('audio_miguelito') ?? true;
    _cronometro = prefs.getBool('cronometro_miguelito') ?? true;
    _idioma = prefs.getString('idioma_miguelito') ?? 'pt-BR';
    notifyListeners();
  }

  Future<void> alterarIdioma(String valor) async {
    _idioma = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma_miguelito', valor);
  }

  NivelJogo get nivel => _nivel;
  bool get modoTranquilo => _modoTranquilo;
  bool get instrucoesAudio => _instrucoesAudio;
  bool get cronometro => _cronometro;

  void alterarNivel(NivelJogo valor) {
    _nivel = valor;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setString('nivel_miguelito', valor.name));
  }

  void alterarModoTranquilo(bool valor) {
    _modoTranquilo = valor;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('modo_tranquilo_miguelito', valor));
  }

  void alterarInstrucoesAudio(bool valor) {
    _instrucoesAudio = valor;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('audio_miguelito', valor));
  }

  void alterarCronometro(bool valor) {
    _cronometro = valor;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('cronometro_miguelito', valor));
  }
}

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfiguracoesJogo.instancia;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: AnimatedBuilder(
        animation: config,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Personalize sua aventura!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<NivelJogo>(
                initialValue: config.nivel,
                decoration: const InputDecoration(
                  labelText: 'Nível do jogo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: NivelJogo.adaptativo,
                    child: Text('Adaptativo'),
                  ),
                  DropdownMenuItem(
                    value: NivelJogo.facil,
                    child: Text('Fácil'),
                  ),
                  DropdownMenuItem(
                    value: NivelJogo.medio,
                    child: Text('Médio'),
                  ),
                  DropdownMenuItem(
                    value: NivelJogo.dificil,
                    child: Text('Difícil'),
                  ),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    config.alterarNivel(valor);
                  }
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Modo tranquilo'),
                subtitle: const Text('Experiência com menos estímulos.'),
                value: config.modoTranquilo,
                onChanged: config.alterarModoTranquilo,
              ),
              SwitchListTile(
                title: const Text('Instruções em áudio'),
                subtitle: const Text('Permitir orientações faladas.'),
                value: config.instrucoesAudio,
                onChanged: config.alterarInstrucoesAudio,
              ),
              SwitchListTile(
                title: const Text('Cronômetro'),
                subtitle: const Text('Permitir atividades com tempo.'),
                value: config.cronometro,
                onChanged: config.alterarCronometro,
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma / Language'),
                subtitle: Text(config.idioma == 'pt-BR' ? '🇧🇷 Português' : '🇺🇸 English'),
                trailing: DropdownButton<String>(
                  value: config.idioma,
                  items: const [
                    DropdownMenuItem(value: 'pt-BR', child: Text('Português')),
                    DropdownMenuItem(value: 'en-US', child: Text('English')),
                  ],
                  onChanged: (valor) {
                    if (valor != null) config.alterarIdioma(valor);
                  },
                ),
              ),
              const Divider(height: 16),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.deepPurple),
                title: const Text('Trocar jogador'),
                subtitle: const Text('Entrar com o nome de outra criança'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('nome_crianca');

                  if (!context.mounted) return;

                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
