import { VisionCameraProxy, type Frame } from 'react-native-vision-camera'
import { NativeModules, Platform } from 'react-native';
import type { CustomModelConfig, ScanConfig, ScanResult } from './Definitions';
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
 * Update the runtime settings with a template
 */
export function updateTemplate(template:string): Promise<boolean> {
  return VisionCameraDynamsoftLabelRecognizer.updateTemplate(template);
}

/**
 * Reset the runtime settings
 */
export function resetRuntimeSettings(): Promise<boolean> {
  return VisionCameraDynamsoftLabelRecognizer.resetRuntimeSettings();
}

/**
 * Use a custom model
 */
export function useCustomModel(config:CustomModelConfig): Promise<boolean> {
  return VisionCameraDynamsoftLabelRecognizer.useCustomModel(config);
}

/**
 * Recognize text from base64
 */
export function decodeBase64(base64:string): Promise<ScanResult> {
  return VisionCameraDynamsoftLabelRecognizer.decodeBase64(base64);
}

const plugin = VisionCameraProxy.initFrameProcessorPlugin('recognize')

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
      record["scanRegion"] = config.scanRegion;
    }
    return plugin.call(frame,record) as any;
  }else{
    return plugin.call(frame) as any;
  }
}
