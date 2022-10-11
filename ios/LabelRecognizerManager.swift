//
//  LabelRecognizerManager.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import DynamsoftLabelRecognizer

class LabelRecognizerManager:NSObject, LicenseVerificationListener {

    private var recognizer:DynamsoftLabelRecognizer!;
    private var currentModelFolder = "";
    private var currentTemplate = "";
    private var mLicense = "";
    
    init(license:String){
        super.init()
        mLicense = license
        initDLR(license: license)
    }
    
    public func getRecognizer() -> DynamsoftLabelRecognizer{
        if recognizer == nil {
            initDLR(license: mLicense)
        }
        return recognizer
    }
    
    public func destroy() {
        recognizer = nil
    }
    
    private func initDLR(license:String) {
        DynamsoftLicenseManager.initLicense(license,verificationDelegate:self)
        recognizer = DynamsoftLabelRecognizer.init()
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
    }
    
    
    public func updateTemplate(template:String){
        if (currentTemplate != template) {
            try! recognizer.initRuntimeSettings(template)
            currentTemplate = template;
        }
    }
    

    public func useCustomModel(modelFolder:String,modelFileNames: [String])   {
        if (modelFolder != currentModelFolder) {
            currentModelFolder = modelFolder
            for model in modelFileNames {
                
                guard let prototxt = Bundle.main.url(
                    forResource: model,
                    withExtension: "prototxt",
                    subdirectory: modelFolder
                ) else {
                    print("model not exist")
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
    }
}
