package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.util.Log;
import androidx.camera.core.ImageProxy;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;
import com.dynamsoft.dlr.*;

import java.io.InputStream;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {
    private LabelRecognizer recognizer = null;
    private ReactApplicationContext context;
    private String currentTemplateName = "";
    private String currentTemplate = "";
    private Boolean mrzModelLoaded = false;

    public void setContext(ReactApplicationContext reactContext){
        context = reactContext;
    }

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

        if (config.hasKey("templateName")) {
            templateName = config.getString("templateName");
            if (currentTemplateName.equals(templateName) == false && templateName.equals("locr")) {
                Log.d("DLR","load mrz model");
                loadMRZModel();
            }
            currentTemplateName = templateName;
        }

        if (config.hasKey("template")) {
            String template = config.getString("template");
            if (currentTemplate.equals(template) == false) {
                try {
                    recognizer.clearAppendedSettings();
                    recognizer.appendSettingsFromString(template);
                    Log.d("DLR","append template: "+template);
                } catch (LabelRecognizerException e) {
                    e.printStackTrace();
                }
            }
            currentTemplate = template;
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

    private void loadMRZModel() {
        if (mrzModelLoaded == false) {
            try {
                String[] fileNames = {"NumberUppercase","NumberUppercase_Assist_1lIJ","NumberUppercase_Assist_8B","NumberUppercase_Assist_8BHR","NumberUppercase_Assist_number","NumberUppercase_Assist_O0DQ","NumberUppercase_Assist_upcase"};
                for(int i = 0;i<fileNames.length;i++) {
                    AssetManager manager = context.getAssets();
                    InputStream isPrototxt = manager.open("MRZ/"+fileNames[i]+".prototxt");
                    byte[] prototxt = new byte[isPrototxt.available()];
                    isPrototxt.read(prototxt);
                    isPrototxt.close();
                    InputStream isCharacterModel = manager.open("MRZ/"+fileNames[i]+".caffemodel");
                    byte[] characterModel = new byte[isCharacterModel.available()];
                    isCharacterModel.read(characterModel);
                    isCharacterModel.close();
                    InputStream isTxt = manager.open("MRZ/"+fileNames[i]+".txt");
                    byte[] txt = new byte[isTxt.available()];
                    isTxt.read(txt);
                    isTxt.close();
                    recognizer.appendCharacterModelBuffer(fileNames[i], prototxt, txt, characterModel);
                }
                Log.d("DLR","mrz model loaded");
                mrzModelLoaded = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
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