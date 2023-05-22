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

import java.io.IOException;
import java.io.InputStream;

public class LabelRecognizerManager {
    private String currentTemplate = "";
    private String currentModelFolder = "";
    private LabelRecognizer recognizer = null;
    private ReactApplicationContext mContext;
    public LabelRecognizerManager(ReactApplicationContext context){
        mContext = context;
        initDLR();
    }

    public LabelRecognizer getRecognizer(){
        if (recognizer == null) {
            initDLR();
        }
        return recognizer;
    }

    private void initDLR() {
        try {
            recognizer = new LabelRecognizer();
        } catch (LabelRecognizerException e) {
            e.printStackTrace();
        }
    }

    private void loadCustomModel(String modelFolder, ReadableArray fileNames) throws IOException {
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
            LabelRecognizer.appendCharacterModelBuffer(fileNames.getString(i), prototxt, txt, characterModel);
        }
        Log.d("DLR","custom model loaded");
    }

    public void updateTemplate(String template) throws LabelRecognizerException {
        if (currentTemplate.equals(template) == false) {
            recognizer.initRuntimeSettings(template);
            Log.d("DLR","set template: "+template);
            currentTemplate = template;
        }
    }

    public void resetRuntimeSettings() throws LabelRecognizerException {
        recognizer.resetRuntimeSettings();
    }

    public void useCustomModel(String modelFolder, ReadableArray modelFileNames) throws IOException {
        if (modelFolder.equals(currentModelFolder) == false) {
            loadCustomModel(modelFolder, modelFileNames);
            currentModelFolder = modelFolder;
        }
    }
}
