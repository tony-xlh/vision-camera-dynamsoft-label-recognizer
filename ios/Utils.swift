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
    static func wrapDLRResult (result:iDLRResult) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["confidence"] = result.confidence
        dict["pageNumber"] = result.pageNumber
        dict["referenceRegionName"] = result.refereneceRegionName
        dict["textAreaName"] = result.textAreaName
        dict["location"] = wrapLocation(location:result.location)
        
        var lineResults: [[String:Any]] = []
        for lineResult in result.lineResults! {
            let lineResultDict: [String: Any] = wrapDLRLineResult(result: lineResult)
            lineResults.append(lineResultDict)
        }
        dict["lineResults"] = lineResults
                
        return dict
    }
    
    static private func wrapDLRLineResult (result:iDLRLineResult) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["confidence"] = result.confidence
        dict["text"] = result.text
        dict["characterModelName"] = result.characterModelName
        dict["lineSpecificationName"] = result.lineSpecificationName
        dict["location"] = wrapLocation(location:result.location)
        var characterResults: [[String:Any]] = []
        for characterResult in result.characterResults! {
            let characterResultDict: [String: Any] = wrapDLRCharacterResult(result: characterResult)
            characterResults.append(characterResultDict)
        }
        dict["characterResults"] = characterResults
        return dict
    }
    
    static private func wrapDLRCharacterResult (result:iDLRCharacterResult) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["characterH"] = result.characterH
        dict["characterHConfidence"] = result.characterHConfidence
        dict["characterM"] = result.characterM
        dict["characterMConfidence"] = result.characterMConfidence
        dict["characterL"] = result.characterL
        dict["characterLConfidence"] = result.characterLConfidence
        dict["location"] = wrapLocation(location:result.location)
        return dict
    }
    
    static private func wrapLocation (location:iQuadrilateral?) -> [String: Any] {
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
