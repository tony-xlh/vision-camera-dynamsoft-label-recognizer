package com.visioncameradynamsoftlabelrecognizer;

import android.content.res.AssetManager;
import android.util.Log;

import com.dynamsoft.core.CoreException;
import com.dynamsoft.core.LicenseManager;
import com.dynamsoft.core.LicenseVerificationListener;
import com.dynamsoft.dlr.LabelRecognizer;
import com.dynamsoft.dlr.LabelRecognizerException;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;

import java.io.InputStream;

public class LabelRecognizerManager {
    private String currentTemplate = "";
    private String currentModelFolder = "";
    private LabelRecognizer recognizer = null;
    private ReactApplicationContext mContext;
    private String mLicense;
    public LabelRecognizerManager(ReactApplicationContext context, String license){
        mContext = context;
        mLicense = license;
        initDLR(license);
    }

    public LabelRecognizer getRecognizer(){
        if (recognizer == null) {
            initDLR(mLicense);
        }
        return recognizer;
    }

    private void initDLR(String license) {
        LicenseManager.initLicense(license, mContext, new LicenseVerificationListener() {
            @Override
            public void licenseVerificationCallback(boolean isSuccess, CoreException error) {
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
        try {
            for(int i = 0;i<fileNames.size();i++) {
                AssetManager manager = mContext.getAssets();
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
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateTemplate(String template){
        if (currentTemplate.equals(template) == false) {
            try {
                recognizer.initRuntimeSettings(template);
                Log.d("DLR","set template: "+template);
            } catch (LabelRecognizerException e) {
                e.printStackTrace();
            }
            currentTemplate = template;
        }
    }

    public void useCustomModel(String modelFolder, ReadableArray modelFileNames){
        if (modelFolder.equals(currentModelFolder) == false) {
            loadCustomModel(modelFolder, modelFileNames);
            currentModelFolder = modelFolder;
        }
    }

    public void destroy(){
        recognizer = null;
    }
}
