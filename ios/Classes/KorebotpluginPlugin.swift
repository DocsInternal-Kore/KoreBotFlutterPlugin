import Flutter
import UIKit

public class KorebotpluginPlugin: NSObject, FlutterPlugin {
  private let botConnect = BotConnect()
  private var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "kore.botsdk/chatbot",
      binaryMessenger: registrar.messenger()
    )
    let instance = KorebotpluginPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initialize":
      configureBot(with: call.arguments)
      result("OK")
    case "getChatWindow":
      configureBot(with: call.arguments)
      DispatchQueue.main.async { [weak self] in
        self?.botConnect.show()
      }
      result("OK")
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func configureBot(with arguments: Any?) {
    let config = arguments as? [String: Any] ?? [:]

    let clientId = stringValue(config, keys: ["clientId"])
    let clientSecret = stringValue(config, keys: ["clientSecret"])
    let botId = stringValue(config, keys: ["botId"])
    let botName = stringValue(config, keys: ["chatBotName", "botName"])
    let identity = stringValue(config, keys: ["identity"])
    let jwtServerUrl = stringValue(config, keys: ["jwt_server_url", "jwtServerUrl"])
    let botServerUrl = stringValue(config, keys: ["server_url", "serverUrl"])
    let brandingUrl = stringValue(
      config,
      keys: ["branding_url", "brandingUrl"],
      fallback: botServerUrl
    )
    let jwtToken = stringValue(config, keys: ["jwtToken"])
    let customData = config["customData"] as? [String: Any] ?? [:]

    var queryParameters = config["queryParameters"] as? [[String: Any]] ?? []
    if queryParameters.isEmpty, let queryParams = config["queryParams"] as? [String: Any] {
      queryParameters = [queryParams]
    }

    botConnect.koreSDkLanguage = stringValue(
      config,
      keys: ["preferredLanguage", "preferred_language"],
      fallback: "en"
    )
    botConnect.networkOnResumeCallingHistory =
      config["historyOnNetworkResume"] as? Bool ?? true

    botConnect.initialize(
      clientId,
      clientSecret: clientSecret,
      botId: botId,
      chatBotName: botName,
      identity: identity,
      isAnonymous: config["isAnonymous"] as? Bool ?? false,
      isWebhookEnabled:
        config["isWebHook"] as? Bool
        ?? config["is_webhook"] as? Bool
        ?? false,
      JWTServerUrl: jwtServerUrl,
      BOTServerUrl: botServerUrl,
      BrandingUrl: brandingUrl,
      customData: customData,
      queryParameters: queryParameters,
      customJWToken: jwtToken
    )

    botConnect.closeOrMinimizeEvent = { [weak self] event in
      self?.channel?.invokeMethod("Callbacks", arguments: event)
    }
  }

  private func stringValue(
    _ config: [String: Any],
    keys: [String],
    fallback: String = ""
  ) -> String {
    for key in keys {
      if let value = config[key] as? String, !value.isEmpty {
        return value
      }
    }
    return fallback
  }
}
