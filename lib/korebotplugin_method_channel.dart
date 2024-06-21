import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'korebotplugin_platform_interface.dart';

/// An implementation of [KorebotpluginPlatform] that uses method channels.
class MethodChannelKorebotplugin extends KorebotpluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('korebotplugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
