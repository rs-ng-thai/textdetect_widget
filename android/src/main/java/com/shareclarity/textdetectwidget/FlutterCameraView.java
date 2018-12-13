package com.shareclarity.textdetectwidget;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.shareclarity.textdetectwidget.camera.CameraSource;
import com.shareclarity.textdetectwidget.camera.CameraSourcePreview;
import com.shareclarity.textdetectwidget.others.GraphicOverlay;
import com.shareclarity.textdetectwidget.text_detection.TextRecognitionProcessor;

import java.io.IOException;
import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterCameraView implements PlatformView, MethodChannel.MethodCallHandler {
    public final MethodChannel methodChannel;
    private Context context;
    private View mView;

    private CameraSource cameraSource = null;
    private CameraSourcePreview preview;
    private GraphicOverlay graphicOverlay;
    private TextRecognitionProcessor processor;
    private Application.ActivityLifecycleCallbacks activityLifecycleCallbacks;

    public RelativeLayout focusLayout;
    public ImageView plusImageView;

    private static String TAG = CameraActivity.class.getSimpleName().toString().trim();
    private HashMap<String,String> companies;

    FlutterCameraView(Context _context, BinaryMessenger messenger, int id, Object object) {
        context = _context;
        methodChannel = new MethodChannel(messenger, "textdetect_widget_" + id);
        methodChannel.setMethodCallHandler(this);
        companies = (HashMap<String, String>)object;
        this.activityLifecycleCallbacks =
                new Application.ActivityLifecycleCallbacks() {
                    @Override
                    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

                    @Override
                    public void onActivityStarted(Activity activity) {

                    }

                    @Override
                    public void onActivityResumed(Activity activity) {
                        startCameraSource();
                    }

                    @Override
                    public void onActivityPaused(Activity activity) {
                        preview.stop();
                    }

                    @Override
                    public void onActivityStopped(Activity activity) {

                    }

                    @Override
                    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

                    @Override
                    public void onActivityDestroyed(Activity activity) {
                        if (cameraSource != null) {
                            cameraSource.release();
                        }
                    }
                };
        TextdetectWidgetPlugin.mActivity
                .getApplication()
                .registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks);
    }


    @Override
    public View getView() {
        LayoutInflater inflater = LayoutInflater.from(TextdetectWidgetPlugin.mActivity); // or (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mView = inflater.inflate(R.layout.view_camera, null);
        initUI();
        return mView;
    }

    private void initUI() {
        preview = mView.findViewById(R.id.camera_source_preview);
        if (preview == null) {
            Log.d(TAG, "Preview is null");
        }
        graphicOverlay = (GraphicOverlay) mView.findViewById(R.id.graphics_overlay);
        if (graphicOverlay == null) {
            Log.d(TAG, "graphicOverlay is null");
        }
        focusLayout = (RelativeLayout) mView.findViewById(R.id.rl_focus);
        plusImageView = (ImageView) mView.findViewById(R.id.imv_plus);

        createCameraSource();
        startCameraSource();

    }

    public void hidePlusImage() {
        TextdetectWidgetPlugin.mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                plusImageView.setVisibility(View.INVISIBLE);
                methodChannel.invokeMethod("detect",null);
            }
        });
    }

    private void createCameraSource() {

        if (cameraSource == null) {
            cameraSource = new CameraSource(TextdetectWidgetPlugin.mActivity, graphicOverlay);
            cameraSource.setFacing(CameraSource.CAMERA_FACING_BACK);
        }
        processor = new TextRecognitionProcessor(companies,this);
        cameraSource.setMachineLearningFrameProcessor(processor);
    }

    private void startCameraSource() {
        if (cameraSource != null) {
            try {
                if (preview == null) {
                    Log.d(TAG, "resume: Preview is null");
                }
                if (graphicOverlay == null) {
                    Log.d(TAG, "resume: graphOverlay is null");
                }
                preview.start(cameraSource, graphicOverlay);
            } catch (IOException e) {
                Log.e(TAG, "Unable to start camera source.", e);
                cameraSource.release();
                cameraSource = null;
            }
        }
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "resumeDetection":
                processor.setPaused(false);
                break;
            case "stopDetection":
                processor.setPaused(true);
                break;
            case "hideFocus":
                hidePlusImage();
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void dispose() {
        if ( cameraSource!=null ) {
            cameraSource.stop();
        }
    }
}
