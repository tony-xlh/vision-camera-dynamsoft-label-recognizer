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
    private static var manager:LabelRecognizerManager!
    private static let context = CIContext(options: nil)

    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        let config = getConfig(withArgs: args)
        if manager == nil {
            let license: String = config?["license"] as? String ?? "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="
            manager = LabelRecognizerManager(license: license)
            recognizer = manager.getRecognizer();
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

        if config!["customModelConfig"] != nil {
            let customModelConfig = config?["customModelConfig"] as? [String:Any]
            let modelFolder = customModelConfig!["customModelFolder"] as! String
            let modelFileNames = customModelConfig!["customModelFileNames"] as! [String]
            manager.useCustomModel(modelFolder: modelFolder, modelFileNames: modelFileNames)
        }
        
        let template = config?["template"] as? String ?? ""
        if (template != "") {
            manager.updateTemplate(template: template)
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

        let results = try? recognizer.recognizeImage(image)
        
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
