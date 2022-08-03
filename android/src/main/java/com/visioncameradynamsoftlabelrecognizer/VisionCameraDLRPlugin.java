package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.util.Log;
import androidx.camera.core.ImageProxy;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;
import com.dynamsoft.dlr.*;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    private ReactApplicationContext context;

    private LabelRecognizer recognizer = null;
    private LabelRecognizerManager manager = null;
    public void setContext(ReactApplicationContext reactContext){
        context = reactContext;
    }

    @Override
    public Object callback(ImageProxy image, Object[] params) {
        // code goes here
        ReadableNativeMap config = getConfig(params);
        if (manager == null) {
            String license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
            if (config != null && config.hasKey("license")) {
                license = config.getString("license");
            }
            manager = new LabelRecognizerManager(context,license);
            recognizer = manager.getRecognizer();
        }

        String templateName = "";

        if (config.hasKey("templateName")) {
            templateName = config.getString("templateName");
        }

        if (config.hasKey("customModelConfig")) {
            ReadableNativeMap customModelConfig = config.getMap("customModelConfig");
            String modelFolder = customModelConfig.getString("customModelFolder");
            ReadableArray modelFileNames = customModelConfig.getArray("customModelFileNames");
            manager.useCustomModel(modelFolder,modelFileNames);
        }

        if (config.hasKey("template")) {
            String template = config.getString("template");
            manager.updateTemplate(template);
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
            Log.d("DLR","use template name: "+templateName);
            DLRResult[] results = recognizer.recognizeByImage(bm,templateName);
            Log.d("DLR","result length: "+ results.length);
            for (DLRResult result:results) {
                for (DLRLineResult line:result.lineResults) {
                    array.pushString(line.text);
                    Log.d("DLR",line.text);
                }
            }
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
        return array;
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