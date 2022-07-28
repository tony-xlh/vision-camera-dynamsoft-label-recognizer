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
        String license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
        if (config != null && config.hasKey("license")) {
          license = config.getString("license");
        }
        if (recognizer == null) {
            Log.d("DLR","init");
            initDLR(license);
        }
        WritableNativeArray array = new WritableNativeArray();
        @SuppressLint("UnsafeOptInUsageError")
        Bitmap bm = BitmapUtils.getBitmap(image);
        try {
            DLRResult[] results = recognizer.recognizeByImage(bm,"");
            for (DLRResult result:results) {
                for (DLRLineResult line:result.lineResults) {
                    Log.d("DLR",line.text);
                    array.pushString(line.text);
                }
            }

            Log.d("DLR","length: "+results.length);
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