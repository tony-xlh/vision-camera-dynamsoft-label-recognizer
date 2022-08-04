//
//  VisionCameraDynamsoftLabelRecognizer.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//

import DynamsoftLabelRecognizer

@objc(VisionCameraDynamsoftLabelRecognizer)
class VisionCameraDynamsoftLabelRecognizer: NSObject {

    private var manager:LabelRecognizerManager!
    private var recognizer:DynamsoftLabelRecognizer!
    
    
    @objc(destroy:withRejecter:)
    func destroy(resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        manager.destroy()
        manager = nil
        recognizer = nil
    }
    
    @objc(decodeBase64:config:withResolver:withRejecter:)
    func decodeBase64(base64: String, config:[String:Any], resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        //print(config)
        if manager == nil {
            let license: String = config["license"] as? String ?? "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="
            initDLR(license: license)
        }
        updateSettings(config: config)
        let templateName = config["templateName"] as? String ?? ""
        var error : NSError? = NSError()
        let image = convertStrToImage(base64)
        var returned_results: [Any] = []
        print("orientation")
        print(image?.imageOrientation.rawValue)
        if image != nil {
            print("use template name ", templateName)
            let results = recognizer.recognizeByImage(image: image!, templateName: templateName, error: &error)
            for result in results {
                for line in result.lineResults! {
                    returned_results.append(line.text!)
                }
            }
            if error?.code != 0 {
                var errorMsg:String? = ""
                errorMsg = error!.userInfo[NSUnderlyingErrorKey] as? String
                print("error")
                print(errorMsg ?? "")
            }
            resolve(returned_results)
        }else{
            resolve(returned_results)
        }
    }
    
    func convertStrToImage(_ imageStr:String) ->UIImage?{
        if let data: NSData = NSData(base64Encoded: imageStr, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        {
            if let image: UIImage = UIImage(data: data as Data)
            {
                return image
            }
        }
        return nil
    }

    
    private func updateSettings(config:[String:Any]){

        if config["customModelConfig"] != nil {
            let customModelConfig = config["customModelConfig"] as? [String:Any]
            let modelFolder = customModelConfig!["customModelFolder"] as! String
            let modelFileNames = customModelConfig!["customModelFileNames"] as! [String]
            manager.useCustomModel(modelFolder: modelFolder, modelFileNames: modelFileNames)
        }
        
        let template = config["template"] as? String ?? ""
        if (template != "") {
            manager.updateTemplate(template: template)
        }
    }
    
    private func initDLR(license:String){
        manager = LabelRecognizerManager(license: license)
        recognizer = manager.getRecognizer();
    }
}
