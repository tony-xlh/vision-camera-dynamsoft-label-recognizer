package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import androidx.camera.core.ImageProxy;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
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
        WritableNativeMap scanResult = new WritableNativeMap();
        WritableNativeArray array = new WritableNativeArray();
        @SuppressLint("UnsafeOptInUsageError")
        Bitmap bm = BitmapUtils.getBitmap(image);

        if (config != null && config.hasKey("scanRegion")) {
            ReadableNativeMap scanRegion = config.getMap("scanRegion");
            double left = scanRegion.getInt("left") / 100.0 * bm.getWidth();
            double top = scanRegion.getInt("top") / 100.0 * bm.getHeight();
            double width = scanRegion.getInt("width") / 100.0 * bm.getWidth();
            double height = scanRegion.getInt("height") / 100.0 * bm.getHeight();
            bm = Bitmap.createBitmap(bm, (int) left, (int) top, (int) width, (int) height, null, false);
        }
        try {
            DLRResult[] results = recognizer.recognizeImage(bm);
            for (DLRResult result:results) {
                array.pushMap(Utils.getMapFromDLRResult(result));
            }
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
        scanResult.putArray("results",array);
        if (config != null && config.hasKey("includeImageBase64")) {
            if (config.getBoolean("includeImageBase64") == true) {
                scanResult.putString("imageBase64",Utils.bitmap2Base64(bm));
            }
        }
        return scanResult;
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