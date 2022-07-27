package com.visioncameradynamsoftlabelrecognizer;

import android.util.Log;

import androidx.camera.core.ImageProxy;

import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    @Override
    public Object callback(ImageProxy image, Object[] params) {
        // code goes here
        Log.d("DBR","decode");
        WritableNativeArray array = new WritableNativeArray();
        array.pushString("array 1");
        return array;
    }

    VisionCameraDLRPlugin() {
        super("decode");
    }
}