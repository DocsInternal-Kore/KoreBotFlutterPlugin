/// Process-wide close/minimize restore flags (SPM `isShowWelcomeMsg` / `historyLimit`).
class BotChatSessionState {
  BotChatSessionState._();

  /// Next chat open mode after Close / Minimize / first launch.
  static BotChatNextOpen nextOpen = BotChatNextOpen.fresh;

  /// Messages visible when the user last tapped Minimize (capped like SPM).
  static int historyMessageLimit = 0;

  static const int maxHistoryLimit = 20;

  static void markClosed() {
    // End bot session — next open must not continue previous conversation.
    nextOpen = BotChatNextOpen.afterClose;
    historyMessageLimit = 0;
  }

  static void markMinimized(int displayedMessageCount) {
    nextOpen = BotChatNextOpen.afterMinimize;
    final n = displayedMessageCount < 0 ? 0 : displayedMessageCount;
    historyMessageLimit = n > maxHistoryLimit ? maxHistoryLimit : n;
  }

  static void reset() {
    nextOpen = BotChatNextOpen.fresh;
    historyMessageLimit = 0;
  }
}

enum BotChatNextOpen {
  /// First open in this process — follow [BotConfig.callHistory], show welcome.
  fresh,

  /// After Close — show welcome, do not load history.
  afterClose,

  /// After Minimize — load [BotChatSessionState.historyMessageLimit], no welcome.
  afterMinimize,
}
