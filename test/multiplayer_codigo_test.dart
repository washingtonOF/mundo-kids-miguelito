import 'package:flutter_test/flutter_test.dart';
import 'package:mundo_kids/multiplayer_online.dart';

void main() {
  test('Aceita códigos de convite com seis caracteres permitidos', () {
    expect(ServicoMultiplayer.codigoValido('ABC234'), isTrue);
    expect(ServicoMultiplayer.codigoValido('HJK789'), isTrue);
    expect(ServicoMultiplayer.codigoValido(' abc234 '), isTrue);
  });

  test('Rejeita tentativas de injeção de caminho Firebase nos convites', () {
    for (final codigo in [
      '../ABC234',
      'ABC234/vagas',
      'ABC.34',
      'ABC#34',
      'ABC[34',
      'ABC]34',
      r'ABC$34',
      'ABC234?admin=true',
    ]) {
      expect(ServicoMultiplayer.codigoValido(codigo), isFalse,
          reason: 'Código malformado aceito: $codigo');
    }
  });

  test('Normaliza convites copiados ou digitados', () {
    expect(ServicoMultiplayer.normalizarCodigo(' abc234 '), 'ABC234');
  });

  test('Rejeita códigos curtos, longos ou com caracteres ambíguos', () {
    for (final codigo in ['ABC12', 'ABC1234', 'ABO234', 'ABI234', 'ABL234', 'AB0234', 'ABC 34', 'ABC-34', 'ABC234\nXYZ', '']) {
      expect(
        ServicoMultiplayer.codigoValido(codigo),
        isFalse,
        reason: 'Código inválido aceito: $codigo',
      );
    }
  });
}
