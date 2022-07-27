import type { Frame } from 'react-native-vision-camera'

export interface DLRConfig{
  template?:string;
  license?:string;
}

export function recognize(frame: Frame,config: DLRConfig): [] {
  'worklet'
  // @ts-ignore
  // eslint-disable-next-line no-undef
  return __recognize(frame, config)
}