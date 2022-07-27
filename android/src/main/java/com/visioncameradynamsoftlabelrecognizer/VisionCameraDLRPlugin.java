package com.visioncameradynamsoftlabelrecognizer;

import androidx.camera.core.ImageProxy;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    @Override
    public Object callback(ImageProxy image, Object[] params) {
        // code goes here
        return null;
    }

    VisionCameraDLRPlugin() {
        super("decode");
    }
}