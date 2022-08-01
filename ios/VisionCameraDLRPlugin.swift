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
        
        let image:UIImage;
        let scanRegion = config?["scanRegion"] as? [String: Int]
        if scanRegion != nil {
            let imgWidth = Double(cgImage.width)
            let imgHeight = Double(cgImage.height)
            let left:Double = Double(scanRegion?["left"] ?? 0) / 100.0 * imgWidth
            let top:Double = Double(scanRegion?["top"] ?? 0) / 100.0 * imgHeight
            let width:Double = Double(scanRegion?["width"] ?? 100) / 100.0 * imgWidth
            let height:Double = Double(scanRegion?["height"] ?? 100) / 100.0 * imgHeight

            // The cropRect is the rect of the image to keep,
            // in this case centered
            let cropRect = CGRect(
                x: left,
                y: top,
                width: width,
                height: height
            ).integral

            let cropped = cgImage.cropping(
                to: cropRect
            )!
            image = UIImage(cgImage: cropped)
            print("use cropped image")
        }else{
            image = UIImage(cgImage: cgImage)
        }
        
        var returned_results: [Any] = []
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

    static func getConfig(withArgs args: [Any]!) -> [String:NSObject]! {
        if args.count>0 {
            let config = args[0] as? [String: NSObject]
            return config
        }
        return nil
    }

}
