//
//  VisionCameraDLRPlugin.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/7/31.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation

@objc(VisionCameraDLRPlugin)
public class VisionCameraDLRPlugin: NSObject, FrameProcessorPluginBase {
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
         // code goes here
        return ["asd"]
    }
}
