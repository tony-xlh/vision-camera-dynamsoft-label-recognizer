//
//  VisionCameraDLRPlugin.m
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/7/31.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>
#import "VisionCameraDynamsoftLabelRecognizer-Swift.h"

@interface VisionCameraDLRPlugin (FrameProcessorPluginLoader)
@end

@implementation VisionCameraDLRPlugin (FrameProcessorPluginLoader)

+ (void)load
{
  [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"recognize"
                                        withInitializer:^FrameProcessorPlugin* (NSDictionary* options) {
    return [[VisionCameraDLRPlugin alloc] init];
  }];
}

@end
