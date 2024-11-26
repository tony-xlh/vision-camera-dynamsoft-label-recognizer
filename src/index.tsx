import { VisionCameraProxy, type Frame } from 'react-native-vision-camera'
import { NativeModules, Platform } from 'react-native';
import type { ScanConfig, ScanResult } from './Definitions';
export * from './Definitions';
const LINKING_ERROR =
  `The package 'vision-camera-dynamsoft-label-recognizer' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const VisionCameraDynamsoftLabelRecognizer = NativeModules.VisionCameraDynamsoftLabelRecognizer  ? NativeModules.VisionCameraDynamsoftLabelRecognizer  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

/**
 * Initialize the license of Dynamsoft Label Recognizer
 */
export function initLicense(license:string): Promise<boolean> {
  return VisionCameraDynamsoftLabelRecognizer.initLicense(license);
}

/**
 * Recognize text from base64
 */
export function decodeBase64(base64:string,template?:string): Promise<ScanResult> {
  return VisionCameraDynamsoftLabelRecognizer.decodeBase64(base64,template ?? "ReadPassportAndId");
}

/**
 * Update the runtime settings
 */
export function initRuntimeSettings(template:string): Promise<boolean> {
  return VisionCameraDynamsoftLabelRecognizer.initRuntimeSettings(template);
}

const plugin = VisionCameraProxy.initFrameProcessorPlugin('recognize',{})

/**
 * Recognize text from the camera preview
 */
export function recognize(frame: Frame,config: ScanConfig): ScanResult {
  'worklet'
  if (plugin == null) throw new Error('Failed to load Frame Processor Plugin "recognize"!')
  if (config) {
    let record:Record<string,any> = {};
    if (config.includeImageBase64 != undefined && config.includeImageBase64 != null) {
      record["includeImageBase64"] = config.includeImageBase64;
    }
    if (config.scanRegion) {
      let scanRegionRecord:Record<string,any> = {};
      scanRegionRecord["left"] = config.scanRegion.left;
      scanRegionRecord["top"] = config.scanRegion.top;
      scanRegionRecord["width"] = config.scanRegion.width;
      scanRegionRecord["height"] = config.scanRegion.height;
      record["scanRegion"] = scanRegionRecord;
    }
    if (config.template) {
      record["template"] = config.template;
    }
    return plugin.call(frame,record) as any;
  }else{
    return plugin.call(frame) as any;
  }
}
