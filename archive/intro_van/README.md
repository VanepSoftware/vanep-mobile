# Intro "van" (arquivada)

Segunda versão da animação de abertura: a van atravessa a tela e revela o
logo. Foi substituída pela intro das letras (`archive/intro_letras`, hoje
ativa em `lib/core/ui/`).

Prévia: `preview/intro_van.mp4` / `preview/intro_van.gif`.

Esta pasta é só um snapshot — fica fora do build e do `flutter analyze`
(`archive/**` está no `exclude` do `analysis_options.yaml`) e os testes daqui
não rodam no `flutter test`.

## Como reativar

1. Copie `lib/core/ui/*` e `test/core/ui/*` desta pasta por cima dos
   arquivos de mesmo nome em `lib/core/ui/` e `test/core/ui/`.
2. Remova `vanep_intro_frame.dart` e `test/core/ui/vanep_intro_frame_test.dart`
   se não for usar mais as letras.
3. `make lint && make test`.
