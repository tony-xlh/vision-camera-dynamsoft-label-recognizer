//
//  VisionCameraDLRPlugin.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/7/31.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import DynamsoftLabelRecognizer

@objc(VisionCameraDLRPlugin)
public class VisionCameraDLRPlugin: NSObject, FrameProcessorPluginBase {
    private static var recognizer:DynamsoftLabelRecognizer!
    private static let context = CIContext(options: nil)
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        let config = getConfig(withArgs: args)
        if recognizer == nil {
            initDLR()
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get CVPixelBuffer!")
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
          print("Failed to create CGImage!")
          return nil
        }
        var returned_results: [Any] = []
        let image = UIImage(cgImage: cgImage)
        var error : NSError? = NSError()
        let results = recognizer.recognizeByImage(image: image, templateName: "", error: &error)
        for result in results {
            for line in result.lineResults! {
                returned_results.append(line.text!)
            }
        }

        return returned_results
    }
    
    static func initDLR() {
        DynamsoftLabelRecognizer.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
        recognizer = DynamsoftLabelRecognizer.init()
    }

    static func getConfig(withArgs args: [Any]!) -> [String:String]! {
        if args.count>0 {
            let config = args[0] as? [String: String]
            return config
        }
        return nil
    }

}
