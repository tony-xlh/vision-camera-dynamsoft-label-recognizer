package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.util.Log;
import androidx.camera.core.ImageProxy;

import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;
import com.dynamsoft.dlr.*;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    private LabelRecognizer recognizer = null;
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        // code goes here
        ReadableNativeMap config = getConfig(params);
        if (recognizer == null) {
            String license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
            if (config != null && config.hasKey("license")) {
                license = config.getString("license");
            }
            initDLR(license);
        }
        String templateName = "";
        if (config.hasKey("template")) {
            String template = config.getString("template");
            Log.d("DLR","template: "+template);
            try {
                recognizer.clearAppendedSettings();
                recognizer.appendSettingsFromString(template);
            } catch (LabelRecognizerException e) {
                e.printStackTrace();
            }
        }
        if (config.hasKey("templateName")) {
            templateName = config.getString("templateName");
        }

        WritableNativeArray array = new WritableNativeArray();
        @SuppressLint("UnsafeOptInUsageError")
        Bitmap bm = BitmapUtils.getBitmap(image);
        double left = 0;
        double top = 0;
        if (config != null && config.hasKey("scanRegion")) {
            ReadableNativeMap scanRegion = config.getMap("scanRegion");
            left = scanRegion.getInt("left") / 100.0 * bm.getWidth();
            top = scanRegion.getInt("top") / 100.0 * bm.getHeight();
            double width = scanRegion.getInt("width") / 100.0 * bm.getWidth();
            double height = scanRegion.getInt("height") / 100.0 * bm.getHeight();
            bm = Bitmap.createBitmap(bm, (int) left, (int) top, (int) width, (int) height, null, false);
        }
        try {
            DLRResult[] results = recognizer.recognizeByImage(bm,templateName);
            Log.d("DLR","using template: "+templateName);
            for (DLRResult result:results) {
                for (DLRLineResult line:result.lineResults) {
                    array.pushString(line.text);
                }
            }
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
        return array;
    }

    private void initDLR(String license) {
        LabelRecognizer.initLicense(license, new DLRLicenseVerificationListener() {
            @Override
            public void DLRLicenseVerificationCallback(boolean isSuccess, Exception error) {
                if(!isSuccess){
                    error.printStackTrace();
                }
            }
        });
        try {
            recognizer = new LabelRecognizer();
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
    }

    private ReadableNativeMap getConfig(Object[] params){
        if (params.length>0) {
            if (params[0] instanceof ReadableNativeMap) {
                ReadableNativeMap config = (ReadableNativeMap) params[0];
                return config;
            }
        }
        return null;
    }

    VisionCameraDLRPlugin() {
        super("recognize");
    }
}