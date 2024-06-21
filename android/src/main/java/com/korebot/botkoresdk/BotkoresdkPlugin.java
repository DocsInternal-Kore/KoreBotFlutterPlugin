package com.korebot.botkoresdk;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import kore.botssdk.net.SDKConfiguration;
import kore.botssdk.utils.StringUtils;

/** BotkoresdkPlugin */
public class BotkoresdkPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "kore.botsdk/chatbot");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if(call.method.equals("getChatWindow"))
    {
      SDKConfiguration.Client.bot_id = "st-b7cde454-5022-5f5a-80ee-e6755849a235";
      SDKConfiguration.Client.client_secret = "pqtjXJSDBYfKehsNdbrBPxQVXvlZIMqm8hxM5gXV724=";
      SDKConfiguration.Client.client_id = "cs-35a729ed-028d-5428-96b4-118db6f36d52";
      SDKConfiguration.Client.bot_name = "SDKBot";
      SDKConfiguration.Client.identity = "anilkumar.routhu@kore.com";

//      BotSocketConnectionManager.getInstance().startAndInitiateConnectionWithConfig(context, null);
//
//      Intent intent = new Intent(context, BotChatActivity.class);
//      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//      Bundle bundle = new Bundle();
//      bundle.putBoolean(BundleUtils.SHOW_PROFILE_PIC, false);
//      if(!StringUtils.isNullOrEmpty(SDKConfiguration.Client.bot_name))
//        bundle.putString(BundleUtils.BOT_NAME_INITIALS,SDKConfiguration.Client.bot_name.charAt(0)+"");
//      else
//        bundle.putString(BundleUtils.BOT_NAME_INITIALS,"B");
//      intent.putExtras(bundle);
//      context.startActivity(intent);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
