import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'korebotplugin_method_channel.dart';

abstract class KorebotpluginPlatform extends PlatformInterface {
  /// Constructs a KorebotpluginPlatform.
  KorebotpluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static KorebotpluginPlatform _instance = MethodChannelKorebotplugin();

  /// The default instance of [KorebotpluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelKorebotplugin].
  static KorebotpluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KorebotpluginPlatform] when
  /// they register themselves.
  static set instance(KorebotpluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
