enum BotConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

extension BotConnectionStateX on BotConnectionState {
  bool get isConnected => this == BotConnectionState.connected;

  String get label {
    switch (this) {
      case BotConnectionState.idle:
        return 'Idle';
      case BotConnectionState.connecting:
        return 'Connecting…';
      case BotConnectionState.connected:
        return 'Online';
      case BotConnectionState.reconnecting:
        return 'Reconnecting…';
      case BotConnectionState.disconnected:
        return 'Disconnected';
      case BotConnectionState.error:
        return 'Connection error';
    }
  }
}
