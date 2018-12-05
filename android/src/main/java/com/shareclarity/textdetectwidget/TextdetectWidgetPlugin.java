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
public class TextdetectWidgetPlugin {
    public static Result mResult;
    public static Activity mActivity;
    public static MethodChannel channel;

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        registrar.platformViewRegistry().registerViewFactory("textdetect_widget",new TextDetectFactory(registrar.messenger()));
        mActivity = registrar.activity();
        FirebaseApp.initializeApp(mActivity);
    }
}
