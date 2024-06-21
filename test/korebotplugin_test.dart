import 'package:flutter_test/flutter_test.dart';
import 'package:korebotplugin/korebotplugin.dart';
import 'package:korebotplugin/korebotplugin_platform_interface.dart';
import 'package:korebotplugin/korebotplugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKorebotpluginPlatform
    with MockPlatformInterfaceMixin
    implements KorebotpluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KorebotpluginPlatform initialPlatform = KorebotpluginPlatform.instance;

  test('$MethodChannelKorebotplugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKorebotplugin>());
  });

  test('getPlatformVersion', () async {
    Korebotplugin korebotpluginPlugin = Korebotplugin();
    MockKorebotpluginPlatform fakePlatform = MockKorebotpluginPlatform();
    KorebotpluginPlatform.instance = fakePlatform;

    expect(await korebotpluginPlugin.getPlatformVersion(), '42');
  });
}
