import type { Frame } from 'react-native-vision-camera'
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

export function decodeBase64(base64:string,config:ScanConfig): Promise<ScanResult> {
  return VisionCameraDynamsoftLabelRecognizer.decodeBase64(base64,config);
}

export function destroy(): Promise<[]> {
  return VisionCameraDynamsoftLabelRecognizer.destroy();
}

export function recognize(frame: Frame,config: ScanConfig): ScanResult {
  'worklet'
  // @ts-ignore
  // eslint-disable-next-line no-undef
  return __recognize(frame, config)
}
