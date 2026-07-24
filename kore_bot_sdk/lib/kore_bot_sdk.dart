/// Pure Flutter Kore Bot SDK.
///
/// Replaces the native Android/iOS chat UI previously launched via
/// MethodChannel `kore.botsdk/chatbot`. Host apps open chat with
/// [KoreBotChat.open] using the same config keys as the legacy plugin.
library kore_bot_sdk;

export 'src/config/bot_config.dart';
export 'src/controller/bot_chat_controller.dart';
export 'src/models/branding_theme.dart';
export 'src/models/chat_message.dart';
export 'src/models/template_payload.dart';
export 'src/net/bot_connection_state.dart';
export 'src/session/bot_chat_session_state.dart';
export 'src/ui/kore_bot_chat.dart';
export 'src/ui/bot_chat_screen.dart';
export 'src/ui/chat_header_builder.dart';
export 'src/ui/chat_footer_builder.dart';
export 'src/ui/theme/bot_chat_theme.dart';
export 'src/services/speech_services.dart';
