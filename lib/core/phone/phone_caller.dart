import 'package:url_launcher/url_launcher.dart';

Uri phoneCallUri(String phone) {
  final dialable = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  return Uri(scheme: 'tel', path: dialable);
}

abstract class PhoneCaller {
  Future<bool> callPhone(String phone);
}

class UrlLauncherPhoneCaller implements PhoneCaller {
  const UrlLauncherPhoneCaller();

  @override
  Future<bool> callPhone(String phone) {
    return launchUrl(phoneCallUri(phone));
  }
}
