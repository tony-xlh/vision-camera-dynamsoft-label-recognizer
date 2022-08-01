//
//  VisionCameraDLRPlugin.swift
//  vision-camera-dynamsoft-label-recognizer
//
//  Created by xulihang on 2022/7/29.
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
