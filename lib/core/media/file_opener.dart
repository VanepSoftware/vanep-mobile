import 'package:open_filex/open_filex.dart';

abstract class FileOpener {
  Future<bool> open(String path);
}

class SystemFileOpener implements FileOpener {
  const SystemFileOpener();

  @override
  Future<bool> open(String path) async {
    final result = await OpenFilex.open(path);
    return result.type == ResultType.done;
  }
}
