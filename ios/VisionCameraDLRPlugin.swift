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
    private static var currentModelFolder = "";
    private static var currentTemplate = "";
    private static var customModelLoaded = false;
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        let config = getConfig(withArgs: args)
        if recognizer == nil {
            let license: String = config?["license"] as? String ?? "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="
            initDLR(license: license)
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
        
        let templateName = config?["templateName"] as? String ?? ""

        if config!["customModelConfig"] != nil {
            let customModelConfig = config?["customModelConfig"] as? [String:Any]
            let modelFolder = customModelConfig!["customModelFolder"] as! String
            let modelFileNames = customModelConfig!["customModelFileNames"] as! [String]
            if modelFolder != currentModelFolder {
                loadCustomModel(modelFolder: modelFolder, modelFileNames: modelFileNames)
                currentModelFolder = modelFolder
            }
        }
        
        let template = config?["template"] as? String ?? ""
        if (template != "") {
            if (currentTemplate != template) {
                var clearErr : NSError? = NSError()
                recognizer.clearAppendedSettings(error: &clearErr)
                var err : NSError? = NSError()
                recognizer.appendSettingsFromString(content: template, error: &err)
                print("template added")
                print(template)
                if err?.code != 0 {
                    print("error")
                    var errMsg:String? = ""
                    errMsg = err!.userInfo[NSUnderlyingErrorKey] as? String
                    print(errMsg ?? "")
                }
                currentTemplate = template;
            }
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
        print("using template name")
        print(templateName)
        let results = recognizer.recognizeByImage(image: image, templateName: templateName, error: &error)
        
        
        if error?.code != 0 {
            var errorMsg:String? = ""
            errorMsg = error!.userInfo[NSUnderlyingErrorKey] as? String
            print(errorMsg ?? "")
        }
        
        for result in results {
            for line in result.lineResults! {
                returned_results.append(line.text!)
            }
        }

        return returned_results
    }
    
    static func loadCustomModel(modelFolder:String,modelFileNames: [String]){
        if customModelLoaded == false {
            for model in modelFileNames {
                let prototxt = Bundle.main.url(forResource: model, withExtension: "prototxt", subdirectory: modelFolder)
                print(prototxt?.absoluteString ?? "not exist")
                let datapro = try! Data.init(contentsOf: prototxt!)
                let txt = Bundle.main.url(forResource: model, withExtension: "txt", subdirectory: modelFolder)
                let datatxt = try! Data.init(contentsOf: txt!)
                let caffemodel = Bundle.main.url(forResource: model, withExtension: "caffemodel", subdirectory: modelFolder)
                let datacaf = try! Data.init(contentsOf: caffemodel!)
                DynamsoftLabelRecognizer.appendCharacterModel(name: model, prototxtBuffer: datapro, txtBuffer: datatxt, characterModelBuffer: datacaf)
            }
            print("model loaded")
            
            customModelLoaded = true
        }
        
    }
    
    static func initDLR(license:String) {
        DynamsoftLabelRecognizer.initLicense(license, verificationDelegate: self)
        recognizer = DynamsoftLabelRecognizer.init()
    }

    static func getConfig(withArgs args: [Any]!) -> [String:Any]! {
        if args.count>0 {
            let config = args[0] as? [String: Any]
            return config
        }
        return nil
    }

}
