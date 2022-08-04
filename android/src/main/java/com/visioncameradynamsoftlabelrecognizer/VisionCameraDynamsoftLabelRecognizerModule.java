package com.visioncameradynamsoftlabelrecognizer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.dynamsoft.dlr.DLRLineResult;
import com.dynamsoft.dlr.DLRResult;
import com.dynamsoft.dlr.LabelRecognizer;
import com.dynamsoft.dlr.LabelRecognizerException;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = VisionCameraDynamsoftLabelRecognizerModule.NAME)
public class VisionCameraDynamsoftLabelRecognizerModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VisionCameraDynamsoftLabelRecognizer";
    private String templateName = "";
    private LabelRecognizer recognizer = null;
    private LabelRecognizerManager manager = null;
    private ReactApplicationContext mContext;
    public VisionCameraDynamsoftLabelRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    private static Bitmap base642Bitmap(String base64) {
        byte[] decode = Base64.decode(base64,Base64.DEFAULT);
        Bitmap bitmap = BitmapFactory.decodeByteArray(decode,0,decode.length);
        return bitmap;
    }

    @ReactMethod
    public void destroy(Promise promise) {
        manager.destroy();
        manager = null;
        recognizer = null;
        promise.resolve(true);
    }

    @ReactMethod
    public void decodeBase64(String base64, ReadableMap config, Promise promise) {
        Log.d("DLR",config.toString());
        if (recognizer == null) {
            initDLR((ReadableNativeMap) config);
        }
        updateSettings((ReadableNativeMap) config);
        WritableNativeArray array = new WritableNativeArray();
        try {
            Bitmap bitmap = base642Bitmap(base64);
            DLRResult[] results = recognizer.recognizeByImage(bitmap,templateName);
            Log.d("DLR","use template name"+templateName);
            for (DLRResult result:results) {
                for (DLRLineResult line:result.lineResults) {
                    array.pushString(line.text);
                    Log.d("DLR",line.text);
                }
            }
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
        promise.resolve(array);
    }

    private void initDLR(ReadableNativeMap config){
        String license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
        if (config != null && config.hasKey("license")) {
            license = config.getString("license");
            Log.d("DLR","use license from config");
            Log.d("DLR",license);
        }
        manager = new LabelRecognizerManager(mContext,license);
        recognizer = manager.getRecognizer();
    }

    private void updateSettings(ReadableNativeMap config){
        Log.d("DLR","update settings");
        Log.d("DLR",config.toString());
        if (config.hasKey("templateName")) {
            templateName = config.getString("templateName");
        }else{
            templateName = "";
        }

        if (config.hasKey("customModelConfig")) {
            ReadableNativeMap customModelConfig = config.getMap("customModelConfig");
            String modelFolder = customModelConfig.getString("customModelFolder");
            ReadableArray modelFileNames = customModelConfig.getArray("customModelFileNames");
            manager.useCustomModel(modelFolder,modelFileNames);
        }else{
            manager.eraseAllCharacterModels();
        }

        if (config.hasKey("template")) {
            String template = config.getString("template");
            manager.updateTemplate(template);
        }
    }

}