package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.camera.core.ImageProxy;

import com.dynamsoft.core.ImageData;
import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;
import com.dynamsoft.dlr.*;

import java.nio.ByteBuffer;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    private LabelRecognizer recognizer = null;
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        // code goes here
        if (recognizer == null) {
            Log.d("DLR","init");
            initDLR();
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

    private void initDLR() {
        LabelRecognizer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInByb2R1Y3RzIjoyfQ==", new DLRLicenseVerificationListener() {
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


    VisionCameraDLRPlugin() {
        super("recognize");
    }
}