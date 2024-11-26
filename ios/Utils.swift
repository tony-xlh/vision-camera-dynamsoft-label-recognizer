//
//  Utils.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/5.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import DynamsoftCore
import DynamsoftLabelRecognizer


class Utils {
    static public func convertBase64ToImage(_ imageStr:String) ->UIImage?{
        if let data: NSData = NSData(base64Encoded: imageStr, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        {
            if let image: UIImage = UIImage(data: data as Data)
            {
                return image
            }
        }
        return nil
    }
    
    static func getBase64FromImage(_ image:UIImage) -> String{
        let dataTmp = image.jpegData(compressionQuality: 100)
        if let data = dataTmp {
            return data.base64EncodedString()
        }
        return ""
    }
    
    static func wrapLinesResult (result:RecognizedTextLinesResult) -> [String: Any] {
        var dict: [String: Any] = [:]
        var lineResults: [[String:Any]] = []
        for lineResult in result.items! {
            let lineResultDict: [String: Any] = wrapDLRLineResult(result: lineResult)
            lineResults.append(lineResultDict)
        }
        dict["lineResults"] = lineResults
        return dict
    }
    
    static private func wrapDLRLineResult (result:TextLineResultItem) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["confidence"] = result.confidence
        dict["text"] = result.text
        print(result.text)
        dict["lineSpecificationName"] = result.taskName
        dict["location"] = wrapLocation(location:result.location)
        var characterResults: [[String:Any]] = []
        for characterResult in result.charResult! {
            let characterResultDict: [String: Any] = wrapDLRCharacterResult(result: characterResult)
            characterResults.append(characterResultDict)
        }
        dict["characterResults"] = characterResults
        return dict
    }
    
    static private func wrapDLRCharacterResult (result:CharacterResult) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["characterH"] = convertCodeToStr(char: result.characterH)
        dict["characterHConfidence"] = result.characterHConfidence
        dict["characterM"] = convertCodeToStr(char: result.characterM)
        dict["characterMConfidence"] = result.characterMConfidence
        dict["characterL"] = convertCodeToStr(char: result.characterL)
        dict["characterLConfidence"] = result.characterLConfidence
        dict["location"] = wrapLocation(location:result.location)
        return dict
    }
    static private func convertCodeToStr(char:UniChar) -> String{
        var str = ""
        str.append(Character(UnicodeScalar(char)!))
        return str;
    }
    
    
    static private func wrapLocation (location:Quadrilateral?) -> [String: Any] {
        var dict: [String: Any] = [:]
        var points: [[String:CGFloat]] = []
        let CGPoints = location!.points as! [CGPoint]
        for point in CGPoints {
            var pointDict: [String:CGFloat] = [:]
            pointDict["x"] = point.x
            pointDict["y"] = point.y
            points.append(pointDict)
        }
        dict["points"] = points
        return dict
    }
}
