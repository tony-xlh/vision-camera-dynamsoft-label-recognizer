//
//  VisionCameraDynamsoftLabelRecognizer.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//

import DynamsoftLabelRecognizer

@objc(VisionCameraDynamsoftLabelRecognizer)
class VisionCameraDynamsoftLabelRecognizer: NSObject, LicenseVerificationListener {

    static var recognizer:DynamsoftLabelRecognizer = DynamsoftLabelRecognizer();
    static var currentModelFolder = "";
    static var currentTemplate = "";
    var licenseResolveBlock:RCTPromiseResolveBlock!;
    var licenseRejectBlock:RCTPromiseRejectBlock!;
    @objc(initLicense:withResolver:withRejecter:)
    func initLicense(license: String, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        print("init license")
        licenseResolveBlock = resolve
        licenseRejectBlock = reject
        DynamsoftLicenseManager.initLicense(license,verificationDelegate:self)
        
    }
    
    func licenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = ""
        if(error != nil)
        {
            let err = error as NSError?
            if err?.code == -1009 {
                msg = "Dynamsoft Label Recognizer is unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
            }else{
                msg = err!.userInfo[NSUnderlyingErrorKey] as? String
                if(msg == nil)
                {
                    msg = err?.localizedDescription
                }
            }
            print(msg ?? "")
        }
        licenseResolveBlock(isSuccess)
    }
    
    @objc(decodeBase64:withResolver:withRejecter:)
    func decodeBase64(base64: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let image = Utils.convertBase64ToImage(base64)
        var scanResult:[String:Any] = [:]
        var returned_results: [Any] = []
        print("orientation")
        print(image?.imageOrientation.rawValue)
        if image != nil {
            let results = try? VisionCameraDynamsoftLabelRecognizer.recognizer.recognizeImage(image!)
            if results != nil {
                for result in results! {
                    returned_results.append(Utils.wrapDLRResult(result:result))
                }
            }
        }
        scanResult["results"] = returned_results
        resolve(scanResult)
    }
    
    @objc(updateTemplate:withResolver:withRejecter:)
    func updateTemplate(template: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        if (template != "" && VisionCameraDynamsoftLabelRecognizer.currentTemplate != template) {
            do {
                try VisionCameraDynamsoftLabelRecognizer.recognizer.initRuntimeSettings(template)
            } catch  {
                reject("error","invalid template",error)
            }
            VisionCameraDynamsoftLabelRecognizer.currentTemplate = template;
        }
        resolve(true)
    }
    
    @objc(resetRuntimeSettings:withRejecter:)
    func resetRuntimeSettings(resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        do {
            try VisionCameraDynamsoftLabelRecognizer.recognizer.resetRuntimeSettings()
        } catch  {
            reject("error","failed to reset runtime settings",error)
        }
    }
    
    @objc(useCustomModel:withResolver:withRejecter:)
    func useCustomModel(customModelConfig:[String:Any], resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let modelFolder = customModelConfig["customModelFolder"] as! String
        let modelFileNames = customModelConfig["customModelFileNames"] as! [String]
        if (modelFolder != VisionCameraDynamsoftLabelRecognizer.currentModelFolder) {
            VisionCameraDynamsoftLabelRecognizer.currentModelFolder = modelFolder
            for model in modelFileNames {
                
                guard let prototxt = Bundle.main.url(
                    forResource: model,
                    withExtension: "prototxt",
                    subdirectory: modelFolder
                ) else {
                    print("model not exist")
                    reject("error","model not exist", nil)
                    return
                }

                let datapro = try! Data.init(contentsOf: prototxt)
                let txt = Bundle.main.url(forResource: model, withExtension: "txt", subdirectory: modelFolder)
                let datatxt = try! Data.init(contentsOf: txt!)
                let caffemodel = Bundle.main.url(forResource: model, withExtension: "caffemodel", subdirectory: modelFolder)
                let datacaf = try! Data.init(contentsOf: caffemodel!)
                DynamsoftLabelRecognizer.appendCharacterModel(model, prototxtBuffer: datapro, txtBuffer: datatxt, characterModelBuffer: datacaf)
                print("load model %@", model)
            }
        }
        resolve(true)
    }
}
