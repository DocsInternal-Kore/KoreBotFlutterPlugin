
import 'korebotplugin_platform_interface.dart';

class Korebotplugin {
  Future<String?> getPlatformVersion() {
    return KorebotpluginPlatform.instance.getPlatformVersion();
  }
}
