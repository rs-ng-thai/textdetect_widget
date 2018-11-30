package com.shareclarity.textdetectwidget;

import android.app.Activity;
import android.content.Intent;

import com.google.firebase.FirebaseApp;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TextdetectWidgetPlugin */
public class TextdetectWidgetPlugin implements MethodCallHandler {
    public static Result mResult;
    static Activity mActivity;
    public static MethodChannel channel;

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), "textdetect_widget");
        mActivity = registrar.activity();
        FirebaseApp.initializeApp(mActivity);
        channel.setMethodCallHandler(new TextdetectWidgetPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("openCamera")) {
            HashMap<String,String> companyList  = call.argument("companies");
            Intent intent = new Intent(mActivity, CameraActivity.class);
            intent.putExtra("companies",companyList);
            mResult = result;
            mActivity.startActivity(intent);
        } else {
            result.notImplemented();
        }
    }
}
