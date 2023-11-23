package com.visioncameradynamsoftlabelrecognizer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.dynamsoft.core.CoreException;
import com.dynamsoft.core.LicenseManager;
import com.dynamsoft.core.LicenseVerificationListener;
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
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;

import java.io.IOException;

@ReactModule(name = VisionCameraDynamsoftLabelRecognizerModule.NAME)
public class VisionCameraDynamsoftLabelRecognizerModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VisionCameraDynamsoftLabelRecognizer";
    private LabelRecognizer recognizer = null;
    private LabelRecognizerManager manager = null;
    private ReactApplicationContext mContext;
    public VisionCameraDynamsoftLabelRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
        initDLR();
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    public LabelRecognizer getRecognizer() {
        return recognizer;
    }

    @ReactMethod
    public void decodeBase64(String base64, Promise promise) {
        WritableNativeMap scanResult = new WritableNativeMap();
        WritableNativeArray array = new WritableNativeArray();
        Bitmap bitmap = Utils.base642Bitmap(base64);
        try {
            DLRResult[] results = recognizer.recognizeImage(bitmap);
            for (DLRResult result:results) {
                array.pushMap(Utils.getMapFromDLRResult(result));
            }
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
        scanResult.putArray("results",array);
        promise.resolve(scanResult);
    }

    @ReactMethod
    private void initLicense(String license, Promise promise){
        LicenseManager.initLicense(license, mContext, new LicenseVerificationListener() {
            @Override
            public void licenseVerificationCallback(boolean isSuccess, CoreException error) {
                if(!isSuccess){
                    error.printStackTrace();
                    promise.resolve(false);
                }else{
                    promise.resolve(true);
                }
            }
        });
    }

    private void initDLR(){
        manager = new LabelRecognizerManager(mContext);
        recognizer = manager.getRecognizer();
    }

    @ReactMethod
    public void useCustomModel(ReadableMap customModelConfig, Promise promise) {
        String modelFolder = customModelConfig.getString("customModelFolder");
        ReadableArray modelFileNames = customModelConfig.getArray("customModelFileNames");
        try {
            manager.useCustomModel(modelFolder,modelFileNames);
            promise.resolve(true);
        } catch (IOException e) {
            e.printStackTrace();
            promise.reject(e.getMessage(),e);
        }
    }

    @ReactMethod
    public void updateTemplate(String template, Promise promise){
        Log.d("DLR","update template");
        try {
            manager.updateTemplate(template);
            promise.resolve(true);
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
            promise.reject(e.getMessage(),e);
        }
    }

    @ReactMethod
    public void resetRuntimeSettings(Promise promise){
        try {
            manager.resetRuntimeSettings();
            promise.resolve(true);
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
            promise.reject(e.getMessage(),e);
        }
    }

}