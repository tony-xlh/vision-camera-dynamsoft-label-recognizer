//
//  VisionCameraDynamsoftLabelRecognizer.m
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VisionCameraDynamsoftLabelRecognizer, NSObject)

RCT_EXTERN_METHOD(initLicense:(NSString *)license
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initRuntimeSettings:(NSString *)template
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(decodeBase64:(NSString *)base64
                  template:(NSString *)template
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
