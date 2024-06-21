import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korebotplugin/korebotplugin_method_channel.dart';

void main() {
  MethodChannelKorebotplugin platform = MethodChannelKorebotplugin();
  const MethodChannel channel = MethodChannel('korebotplugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
