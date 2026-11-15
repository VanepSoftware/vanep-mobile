import 'package:share_plus/share_plus.dart';

abstract class TextSharer {
  Future<void> shareText(String text);
}

class SharePlusTextSharer implements TextSharer {
  const SharePlusTextSharer();

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
