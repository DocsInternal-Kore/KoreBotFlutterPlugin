package com.korebot.korebotplugin;

import static kore.botssdk.listener.BaseSocketConnectionManager.CONNECTION_STATE.DISCONNECTED;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import java.io.IOException;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import kore.botssdk.activity.BotChatActivity;
import kore.botssdk.event.KoreEventCenter;
import kore.botssdk.events.SocketDataTransferModel;
import kore.botssdk.listener.BaseSocketConnectionManager;
import kore.botssdk.listener.BotSocketConnectionManager;
import kore.botssdk.listener.SocketChatListener;
import kore.botssdk.models.BotResponse;
import kore.botssdk.models.CallBackEventModel;
import kore.botssdk.models.JWTTokenResponse;
import kore.botssdk.net.BotJWTRestBuilder;
import kore.botssdk.net.BotRestBuilder;
import kore.botssdk.net.SDKConfiguration;
import kore.botssdk.utils.BundleUtils;
import kore.botssdk.utils.LogUtils;
import kore.botssdk.utils.SharedPreferenceUtils;
import kore.botssdk.utils.StringUtils;
import okhttp3.ResponseBody;
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
    private final Gson gson = new Gson();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "kore.botsdk/chatbot");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        KoreEventCenter.register(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getChatWindow")) {
            SDKConfiguration.Client.bot_id = call.argument("botId");
            SDKConfiguration.Client.client_secret = call.argument("clientSecret");
            SDKConfiguration.Client.client_id = call.argument("clientId");
            SDKConfiguration.Client.bot_name = call.argument("chatBotName");
            SDKConfiguration.Client.identity = call.argument("identity");
            SDKConfiguration.Client.history_call = Boolean.TRUE.equals(call.argument("callHistory"));

            SDKConfiguration.Server.SERVER_URL = call.argument("server_url");
            SDKConfiguration.setJwtServerUrl(call.argument("jwt_server_url"));

            Intent intent = new Intent(context, BotChatActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Bundle bundle = new Bundle();
            bundle.putBoolean(BundleUtils.SHOW_PROFILE_PIC, false);
            if (!StringUtils.isNullOrEmpty(SDKConfiguration.Client.bot_name))
                bundle.putString(BundleUtils.BOT_NAME_INITIALS, String.valueOf(SDKConfiguration.Client.bot_name.charAt(0)));
            else
                bundle.putString(BundleUtils.BOT_NAME_INITIALS, "B");
            intent.putExtras(bundle);
            context.startActivity(intent);
        } else if (call.method.equals("initialize")) {
            SDKConfiguration.Client.bot_id = call.argument("botId");
            SDKConfiguration.Client.client_secret = call.argument("clientSecret");
            SDKConfiguration.Client.client_id = call.argument("clientId");
            SDKConfiguration.Client.bot_name = call.argument("chatBotName");
            SDKConfiguration.Client.identity = call.argument("identity");
            SDKConfiguration.Client.history_call = Boolean.TRUE.equals(call.argument("callHistory"));

            SDKConfiguration.Server.SERVER_URL = call.argument("server_url");
            SDKConfiguration.Server.KORE_BOT_SERVER_URL = call.argument("server_url");
            SDKConfiguration.setJwtServerUrl(call.argument("jwt_server_url"));

            //For jwtToken
            makeStsJwtCallWithConfig();
        } else if (call.method.equals("getSearchResults")) {
            getSearchResults(call.argument("searchQuery"));
        }
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
        retrofit2.Call<ResponseBody> getBankingConfigService = BotRestBuilder.getBotRestService().getAdvancedSearch(SDKConfiguration.Client.bot_id, SharedPreferenceUtils.getInstance(context).getKeyValue("JwtToken", ""), getSearchObject(searchQuery));
        getBankingConfigService.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(@NonNull retrofit2.Call<ResponseBody> call, @NonNull Response<ResponseBody> response) {

                if (response.isSuccessful()) {
                    try {
                        if (response.body() != null)
                            channel.invokeMethod("Callbacks", new Gson().toJson(response.body().string()));
                        else
                            channel.invokeMethod("Callbacks", "No response received.");
                    } catch (IOException e) {
                        channel.invokeMethod("Callbacks", "No response received.");
                        throw new RuntimeException(e);
                    }
                } else {
                    channel.invokeMethod("Callbacks", "No response received.");
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable t) {
                LogUtils.d("token refresh", t.getMessage());
            }
        });
    }

    public void onEvent(CallBackEventModel callBackEventModel) {
        channel.invokeMethod("Callbacks", gson.toJson(callBackEventModel));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        KoreEventCenter.unregister(this);
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

    private HashMap<String, Object> getSearchObject(String query) {
        HashMap<String, Object> hsh = new HashMap<>();
        hsh.put("query", query);
        return hsh;
    }
}
