# Intro "letras" (arquivada)

Primeira versão da animação de abertura: fundo navy com gradiente, letras do
`vanep` subindo uma a uma, brilho diagonal e fade para o app. Foi substituída
pela intro da van (`lib/core/ui/vanep_van_intro.dart`).

Prévia: `preview/intro_letras.mp4` / `preview/intro_letras.gif`.

Esta pasta é só um snapshot — fica fora do build e do `flutter analyze`
(`archive/**` está no `exclude` do `analysis_options.yaml`) e os testes daqui
não rodam no `flutter test`.

## Como reativar

1. Copie `lib/core/ui/*` e `test/core/ui/*` desta pasta por cima dos
   arquivos de mesmo nome em `lib/core/ui/` e `test/core/ui/`.
2. Em `lib/core/ui/vanep_intro_gate.dart` (a versão daqui) o overlay usado é
   o `VanepIntroOverlay` com duração `vanepIntroDuration` (2 s).
3. Remova `vanep_van_intro.dart`, `vanep_van_intro_timeline.dart` e
   `test/core/ui/vanep_van_intro_test.dart`, se não for usar mais a van.
4. `make lint && make test`.
