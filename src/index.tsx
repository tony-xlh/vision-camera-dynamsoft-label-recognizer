import type { Frame } from 'react-native-vision-camera'

export interface ScanRegion{
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface DLRConfig{
  template?: string;
  license?: string;
  scanRegion?: ScanRegion;
}

export function recognize(frame: Frame,config: DLRConfig): [] {
  'worklet'
  // @ts-ignore
  // eslint-disable-next-line no-undef
  return __recognize(frame, config)
}
