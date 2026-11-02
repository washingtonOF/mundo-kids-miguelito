# Miguelito 1.1.0 — entrega Android

## Estado da atualização
- Nome exibido: Miguelito.
- Versão do projeto: 1.1.0+2.
- Identificador Android atual: `com.example.mundo_kids`. **Não alterar sem planejar a migração:** o Android considera outro identificador um aplicativo diferente.
- Permissão `android.permission.INTERNET` declarada para autenticação e partidas via Firebase.
- Abertura Android com fundo amarelo suave.
- APK gerado pelo fluxo manual **Gerar APK Miguelito 1.1.0** no GitHub Actions.

## Criar e cadastrar a assinatura (uma única vez)

Em um computador com o JDK instalado, abra o PowerShell e execute:

```powershell
keytool -genkeypair -v -keystore miguelito-release.jks -alias miguelito -keyalg RSA -keysize 3072 -validity 10000 -storetype PKCS12
```

O comando solicitará as senhas e os dados do certificado. **Guarde o arquivo `miguelito-release.jks` e as senhas em um local seguro, fora do repositório.** Não envie essas informações por mensagens.

Para converter o arquivo em Base64, no PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path .\miguelito-release.jks))) | Set-Clipboard
```

No GitHub, abra **Settings → Secrets and variables → Actions → New repository secret** e cadastre:

- `MIGUELITO_KEYSTORE_BASE64`: conteúdo Base64 copiado.
- `MIGUELITO_STORE_PASSWORD`: senha do arquivo.
- `MIGUELITO_KEY_ALIAS`: `miguelito`.
- `MIGUELITO_KEY_PASSWORD`: senha da chave (pode ser igual à senha do arquivo).

Depois execute o fluxo manual em **Actions**. Não é possível confirmar a compilação até que as credenciais estejam configuradas e o fluxo termine com sucesso.

## Para obter o APK
1. Abrir **Actions** no repositório.
2. Selecionar **Gerar APK Miguelito 1.1.0**.
3. Clicar em **Run workflow** e selecionar a branch `main`.
4. Aguardar os passos `flutter analyze`, `flutter test` e `flutter build apk --release`.
5. Se o fluxo terminar com sucesso, baixar o artefato `Miguelito-1.1.0-Android`.

## Atenção à assinatura e às atualizações
A configuração atual exige uma **chave de produção** fornecida por variáveis de ambiente. O fluxo de APK não deve publicar uma versão sem credenciais de assinatura. O APK é verificado com `apksigner` antes de ser disponibilizado.

Para instalar uma atualização **sem desinstalar**, o APK novo precisa ter o **mesmo applicationId**, assinatura compatível com o aplicativo instalado e `versionCode` maior. Se o APK anterior foi assinado com outra chave, a atualização direta não será possível.

Antes da distribuição final, configurar uma chave de assinatura release própria, armazená-la com segurança e preservar essa mesma chave para futuras versões. Não colocar senhas ou arquivos de chave no GitHub.

## Checklist de aceitação
- [ ] GitHub Actions terminou com sucesso.
- [ ] APK instalado em aparelho Android de teste.
- [ ] Tela inicial, avatar e ícone conferidos visualmente.
- [ ] Matemática, português, memória e cores testados.
- [ ] Voz testada em português e inglês.
- [ ] Jogo individual testado sem internet.
- [ ] Sala multiplayer e placar testados em dois aparelhos.
- [ ] Atualização sobre a instalação anterior testada com assinatura compatível.

**Não considerar a entrega concluída antes da compilação e dos testes em aparelho.**
