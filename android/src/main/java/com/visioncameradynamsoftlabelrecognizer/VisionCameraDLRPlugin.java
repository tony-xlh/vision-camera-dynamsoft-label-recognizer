package com.visioncameradynamsoftlabelrecognizer;

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
            initDLR();
        }
        WritableNativeArray array = new WritableNativeArray();
        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
        int nRowStride = image.getPlanes()[0].getRowStride();
        int nPixelStride = image.getPlanes()[0].getPixelStride();
        int length = buffer.remaining();
        byte[] bytes = new byte[length];
        buffer.get(bytes);
        ImageData img = new ImageData();
        img.bytes = bytes;
        img.format = image.getFormat();
        img.height = image.getHeight();
        img.width = image.getWidth();
        img.stride = nRowStride*nPixelStride;
        try {
            DLRResult[] results = recognizer.recognizeByBuffer(img,"");
            for (DLRResult result:results) {
                for (DLRLineResult line:result.lineResults) {
                    array.pushString(line.text);
                }
            }
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