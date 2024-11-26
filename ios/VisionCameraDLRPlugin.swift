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
    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
        super.init(proxy: proxy, options: options)
    }
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get CVPixelBuffer!")
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
          print("Failed to create CGImage!")
          return nil
        }
        var image = UIImage(cgImage: cgImage)
        var degree = 0.0;
        if frame.orientation == UIImage.Orientation.left {
            degree = 90.0;
        }else if frame.orientation == UIImage.Orientation.down {
            degree = 180.0;
        }
        if degree != 0.0 {
            image = VisionCameraDLRPlugin.rotate(image:image,degree:degree)
        }
        let scanRegion = arguments?["scanRegion"] as? [String: Int]
        if scanRegion != nil {
            let imgWidth = Double(image.cgImage!.width)
            let imgHeight = Double(image.cgImage!.height)
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

            let cropped = image.cgImage!.cropping(
                to: cropRect
            )!
            image = UIImage(cgImage: cropped)
            print("use cropped image")
        }
        var templateName = "ReadPassportAndId"
        if arguments != nil {
            if arguments?["template"] != nil {
                let template = arguments?["template"] as! String
                if template != "" {
                    templateName = template
                }
            }
        }
        
        var scanResult: [String:Any] = [:]
        var returned_results: [Any] = []
        print("template: %s",templateName)
        let capturedResult = VisionCameraDynamsoftLabelRecognizer.router.captureFromImage(image, templateName: templateName)
        
        
        let linesResult = capturedResult.recognizedTextLinesResult
        if linesResult != nil {
            returned_results.append(Utils.wrapLinesResult(result:linesResult!))
        }


        scanResult["results"] = returned_results
        let includeImageBase64 = arguments!["includeImageBase64"] as? Bool ?? false
        if includeImageBase64 == true {
            scanResult["imageBase64"] = Utils.getBase64FromImage(image)
        }
        
        return scanResult
    }
    
    public static func rotate(image: UIImage, degree: CGFloat) -> UIImage {
        let radians = degree / (180.0 / .pi)
        let rotatedSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            image.draw(in: CGRect(x: -origin.y, y: -origin.x,
                                  width: image.size.width, height: image.size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? image
        }
        return image
    }
}
