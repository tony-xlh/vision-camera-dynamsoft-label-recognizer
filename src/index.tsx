import type { Frame } from 'react-native-vision-camera'
import { NativeModules, Platform } from 'react-native';
import type { DLRResult } from './Definitions';
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

export function decodeBase64(base64:string,config:DLRConfig): Promise<[]> {
  return VisionCameraDynamsoftLabelRecognizer.decodeBase64(base64,config);
}

export function destroy(): Promise<[]> {
  return VisionCameraDynamsoftLabelRecognizer.destroy();
}

export interface ScanRegion{
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface DLRConfig{
  template?: string;
  templateName?: string;
  license?: string;
  scanRegion?: ScanRegion;
  customModelConfig?: CustomModelConfig;
}

export interface CustomModelConfig {
  customModelFolder: string;
  customModelFileNames: string[];
}

export function recognize(frame: Frame,config: DLRConfig): DLRResult[] {
  'worklet'
  // @ts-ignore
  // eslint-disable-next-line no-undef
  return __recognize(frame, config)
}
