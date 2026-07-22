package com.korebot.korebotplugin;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import kore.botssdk.activity.NewBotChatActivity;
import kore.botssdk.models.JWTTokenResponse;
import kore.botssdk.net.BotJWTRestBuilder;
import kore.botssdk.net.RestResponse;
import kore.botssdk.net.SDKConfig;
import kore.botssdk.net.SDKConfiguration;
import kore.botssdk.utils.BundleUtils;
import kore.botssdk.utils.LogUtils;
import kore.botssdk.utils.SharedPreferenceUtils;
import kore.botssdk.utils.StringUtils;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * KorebotpluginPlugin
 */
@SuppressLint("UnknownNullness")
public class KorebotpluginPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    MethodChannel channel;
    Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "kore.botsdk/chatbot");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getChatWindow":
                configureSdk(call);

                Intent intent = new Intent(context, NewBotChatActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                Bundle bundle = new Bundle();
                bundle.putBoolean(BundleUtils.SHOW_PROFILE_PIC, false);
                if (!StringUtils.isNullOrEmpty(SDKConfiguration.Client.bot_name))
                    bundle.putString(BundleUtils.BOT_NAME_INITIALS, String.valueOf(SDKConfiguration.Client.bot_name.charAt(0)));
                else
                    bundle.putString(BundleUtils.BOT_NAME_INITIALS, "B");
                intent.putExtras(bundle);
                context.startActivity(intent);
                result.success("OK");
                break;
            case "initialize":
                configureSdk(call);

                //For jwtToken
                makeStsJwtCallWithConfig();
                result.success("OK");
                break;
            case "getSearchResults":
                getSearchResults(call.argument("searchQuery"));
                result.success("OK");
                break;
            default:
                result.notImplemented();
        }
    }

    private void configureSdk(@NonNull MethodCall call) {
        String botId = call.argument("botId");
        String botName = call.argument("chatBotName");
        String clientId = call.argument("clientId");
        String clientSecret = call.argument("clientSecret");
        String identity = call.argument("identity");
        String serverUrl = call.argument("server_url");
        String jwtServerUrl = call.argument("jwt_server_url");
        String brandingUrl = firstStringArg(call, "branding_url", "brandingUrl");
        String jwtToken = call.argument("jwtToken");

        SDKConfig.initialize(botId, botName, clientId, clientSecret, identity, jwtToken == null ? "" : jwtToken, serverUrl, StringUtils.isNotEmpty(brandingUrl) ? brandingUrl : serverUrl, jwtServerUrl);
        applyOptionalSdkConfig(call);
    }

    private void applyOptionalSdkConfig(@NonNull MethodCall call) {
        SDKConfiguration.OverrideKoreConfig.history_initial_call = boolArg(call, "callHistory", false);
        SDKConfiguration.OverrideKoreConfig.showHamburgerMenu = boolArg(call, "showHamburgerMenu", false);
        SDKConfiguration.OverrideKoreConfig.showTextToSpeech = boolArg(call, "showTextToSpeech", false);
        SDKConfig.setIsShowIcon(boolArg(call, "showIcon", true));

        applyBoolean(call, "isWebHook", SDKConfig::isWebHook);
        applyBoolean(call, "is_webhook", SDKConfig::isWebHook);
        applyString(call, "deviceId", SDKConfig::setDeviceId);
        applyString(call, "notificationDeviceId", SDKConfig::setDeviceId);
        applyBoolean(call, "showHeader", SDKConfig::setIsShowHeader);
        applyBoolean(call, "showHeaderMinimize", SDKConfig::showHeaderMinimize);
        applyBoolean(call, "showActionBar", SDKConfig::setIsShowActionBar);
        applyBoolean(call, "showIconTop", SDKConfig::setIsShowIconTop);
        applyBoolean(call, "timeStampsRequired", SDKConfig::setIsTimeStampsRequired);
        applyBoolean(call, "updateStatusBarColor", SDKConfig::setIsUpdateStatusBarColor);
        applyString(call, "bubbleDateFormat", SDKConfig::setBubbleDateFormat);
        String preferredLanguage = firstStringArg(call, "preferredLanguage", "preferred_language");
        SDKConfig.setPreferredLanguage(preferredLanguage == null ? "en" : preferredLanguage);

        HashMap<String, Object> queryParams = mapArg(call, "queryParams") ;
        if (queryParams != null) SDKConfig.setQueryParams(queryParams);

        HashMap<String, Object> customDataMap = mapArg(call, "customData");
        if (customDataMap != null) {
            RestResponse.BotCustomData customData = new RestResponse.BotCustomData();
            customData.putAll(customDataMap);
            SDKConfig.setCustomData(customData);
        }

        applyString(call, "connectionMode", value -> SDKConfiguration.Client.connection_mode = value);
        applyBoolean(call, "connectionModeOnReconnect", value -> SDKConfiguration.Client.connection_mode_on_reconnect = value);
        applyBoolean(call, "historyOnNetworkResume", value -> SDKConfiguration.Client.history_on_network_resume = value);
        applyBoolean(call, "enableAckDelivery", value -> SDKConfiguration.Client.enable_ack_delivery = value);

        applyBoolean(call, "emojiShortcutEnable", value -> SDKConfiguration.OverrideKoreConfig.isEmojiShortcutEnable = value);
        applyInteger(call, "typingIndicatorTimeout", value -> SDKConfiguration.OverrideKoreConfig.typing_indicator_timeout = value);
        applyBoolean(call, "historyEnable", value -> SDKConfiguration.OverrideKoreConfig.history_enable = value);
        applyInteger(call, "historyBatchSize", value -> SDKConfiguration.OverrideKoreConfig.history_batch_size = value);
        applyBoolean(call, "paginatedScrollEnable", value -> SDKConfiguration.OverrideKoreConfig.paginated_scroll_enable = value);
        applyInteger(call, "paginatedScrollBatchSize", value -> SDKConfiguration.OverrideKoreConfig.paginated_scroll_batch_size = value);
        applyString(call, "paginatedScrollLoadingLabel", value -> SDKConfiguration.OverrideKoreConfig.paginated_scroll_loading_label = value);
        applyBoolean(call, "showAttachment", value -> SDKConfiguration.OverrideKoreConfig.showAttachment = value);
        applyBoolean(call, "showASRMicroPhone", value -> SDKConfiguration.OverrideKoreConfig.showASRMicroPhone = value);
        applyBoolean(call, "showMicrophone", value -> SDKConfiguration.OverrideKoreConfig.showASRMicroPhone = value);
        applyBoolean(call, "disableActionBar", value -> SDKConfiguration.OverrideKoreConfig.disable_action_bar = value);
        applyBoolean(call, "disableAlertOnMaxReconnection", value -> SDKConfiguration.OverrideKoreConfig.disable_alert_on_max_reconnection = value);
        applyBoolean(call, "updateCustomDataToUserMessage", value -> SDKConfiguration.OverrideKoreConfig.update_custom_data_to_user_message = value);
        applyBoolean(call, "showLocalNotification", value -> SDKConfiguration.OverrideKoreConfig.showLocalNotification = value);
        applyBoolean(call, "reconnectionBySDK", value -> SDKConfiguration.OverrideKoreConfig.reconnectionBySDK = value);
        applyBoolean(call, "sendAllDeepLink", value -> SDKConfiguration.OverrideKoreConfig.sendAllDeepLink = value);
        applyBoolean(call, "defaultNotifications", value -> SDKConfiguration.OverrideKoreConfig.default_notifications = value);

        applyString(call, "botIconUrl", SDKConfiguration.BubbleColors::setIcon_url);
        applyString(call, "agentIconUrl", value -> SDKConfig.setAgentAvatar(null, value));
        applyString(call, "footerHintText", value -> SDKConfiguration.BubbleColors.footer_hint_text = value);
    }

    private interface BooleanSetter {
        void set(boolean value);
    }

    private interface IntegerSetter {
        void set(int value);
    }

    private interface StringSetter {
        void set(String value);
    }

    private void applyBoolean(@NonNull MethodCall call, String key, BooleanSetter setter) {
        if (call.hasArgument(key)) setter.set(boolArg(call, key, false));
    }

    private void applyInteger(@NonNull MethodCall call, String key, IntegerSetter setter) {
        Integer value = intArg(call, key);
        if (value != null) setter.set(value);
    }

    private void applyString(@NonNull MethodCall call, String key, StringSetter setter) {
        String value = call.argument(key);
        if (StringUtils.isNotEmpty(value)) setter.set(value);
    }

    private boolean boolArg(@NonNull MethodCall call, String key, boolean defaultValue) {
        Object value = call.argument(key);
        return value instanceof Boolean ? (Boolean) value : defaultValue;
    }

    private Integer intArg(@NonNull MethodCall call, String key) {
        Object value = call.argument(key);
        return value instanceof Number ? ((Number) value).intValue() : null;
    }

    private String firstStringArg(@NonNull MethodCall call, String... keys) {
        for (String key : keys) {
            String value = call.argument(key);
            if (StringUtils.isNotEmpty(value)) return value;
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private HashMap<String, Object> mapArg(@NonNull MethodCall call, String key) {
        Object value = call.argument(key);
        return value instanceof Map ? new HashMap<>((Map<String, Object>) value) : null;
    }

    private void makeStsJwtCallWithConfig() {
        retrofit2.Call<JWTTokenResponse> getBankingConfigService = BotJWTRestBuilder.getBotJWTRestAPI().getJWTToken(getRequestObject());
        getBankingConfigService.enqueue(new Callback<JWTTokenResponse>() {
            @Override
            public void onResponse(@NonNull retrofit2.Call<JWTTokenResponse> call, @NonNull Response<JWTTokenResponse> response) {

                if (response.isSuccessful()) {
                    JWTTokenResponse jwtTokenResponse = response.body();
                    if (jwtTokenResponse != null) {
                        String jwt = jwtTokenResponse.getJwt();
                        SharedPreferenceUtils.getInstance(context).putKeyValue("JwtToken", jwt);
                    }
                }
            }

            @Override
            public void onFailure(@NonNull Call<JWTTokenResponse> call, @NonNull Throwable t) {
                LogUtils.d("token refresh", t.getMessage());
            }
        });
    }

    private void getSearchResults(String searchQuery) {
        channel.invokeMethod("Callbacks", "Search query callbacks are not available in the latest native Android SDK.");
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private HashMap<String, Object> getRequestObject() {
        HashMap<String, Object> hsh = new HashMap<>();
        hsh.put("clientId", SDKConfiguration.Client.client_id);
        hsh.put("clientSecret", SDKConfiguration.Client.client_secret);
        hsh.put("identity", SDKConfiguration.Client.identity);
        hsh.put("aud", "https://idproxy.kore.com/authorize");
        hsh.put("isAnonymous", false);

        return hsh;
    }
}
