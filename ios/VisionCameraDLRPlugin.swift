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
public class VisionCameraDLRPlugin: FrameProcessorPlugin {
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
        let config = getConfig(withArgs: args)

        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get CVPixelBuffer!")
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
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
        
        var scanResult: [String:Any] = [:]
        var returned_results: [Any] = []

        let results = try? VisionCameraDynamsoftLabelRecognizer.recognizer.recognizeImage(image)
        
        if results != nil {
            for result in results! {
                returned_results.append(Utils.wrapDLRResult(result:result))
            }
        }


        scanResult["results"] = returned_results
        let includeImageBase64 = config!["includeImageBase64"] as? Bool ?? false
        if includeImageBase64 == true {
            scanResult["imageBase64"] = Utils.getBase64FromImage(image)
        }
        
        return scanResult
    }

    static func getConfig(withArgs args: [Any]!) -> [String:Any]! {
        if args.count>0 {
            let config = args[0] as? [String: Any]
            return config
        }
        return nil
    }

}
