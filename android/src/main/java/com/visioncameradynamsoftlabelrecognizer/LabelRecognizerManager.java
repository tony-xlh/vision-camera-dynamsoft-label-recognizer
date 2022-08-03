package com.visioncameradynamsoftlabelrecognizer;

import android.content.res.AssetManager;
import android.util.Log;

import com.dynamsoft.dlr.DLRLicenseVerificationListener;
import com.dynamsoft.dlr.LabelRecognizer;
import com.dynamsoft.dlr.LabelRecognizerException;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableNativeMap;

import com.dynamsoft.dlr.*;

import java.io.InputStream;

public class LabelRecognizerInitializer {

    private LabelRecognizer recognizer = null;
    private ReactApplicationContext mContext;
    public LabelRecognizerInitializer(ReactApplicationContext context, String license){
        mContext = context;
        initDLR(license);
    }

    public LabelRecognizer getRecognizer(){
        return recognizer;
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

    private void loadCustomModel(String modelFolder, ReadableArray fileNames) {
        if (customModelLoaded == false) {
            try {
                for(int i = 0;i<fileNames.size();i++) {
                    AssetManager manager = context.getAssets();
                    InputStream isPrototxt = manager.open(modelFolder+"/"+fileNames.getString(i)+".prototxt");
                    byte[] prototxt = new byte[isPrototxt.available()];
                    isPrototxt.read(prototxt);
                    isPrototxt.close();
                    InputStream isCharacterModel = manager.open(modelFolder+"/"+fileNames.getString(i)+".caffemodel");
                    byte[] characterModel = new byte[isCharacterModel.available()];
                    isCharacterModel.read(characterModel);
                    isCharacterModel.close();
                    InputStream isTxt = manager.open(modelFolder+"/"+fileNames.getString(i)+".txt");
                    byte[] txt = new byte[isTxt.available()];
                    isTxt.read(txt);
                    isTxt.close();
                    recognizer.appendCharacterModelBuffer(fileNames.getString(i), prototxt, txt, characterModel);
                }
                Log.d("DLR","custom model loaded");
                customModelLoaded = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void updateTemplate(String template){
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
    }

    private void useCustomModel(String templateName, String modelFolder, ReadableArray modelFileNames){
        String templateName = "";

        if (config.hasKey("templateName")) {
            templateName = config.getString("templateName");
        }

        if (config.hasKey("customModelConfig")) {
            ReadableNativeMap customModelConfig = config.getMap("customModelConfig");
            String modelFolder = customModelConfig.getString("customModelFolder");
            ReadableArray modelFileNames = customModelConfig.getArray("customModelFileNames");
            if (modelFolder.equals(currentModelFolder) == false) {
                loadCustomModel(modelFolder, modelFileNames);
                currentModelFolder = modelFolder;
            }
        }




    }
}
