# vision-camera-dynamsoft-label-recognizer


React Native Vision Camera Frame Processor Plugin of [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/)

[Demo video](https://user-images.githubusercontent.com/5462205/183386819-18d32deb-2c6c-48ec-b596-636331f004a4.mp4)

## Installation

```sh
npm install vision-camera-dynamsoft-label-recognizer
```

make sure you correctly setup react-native-reanimated and add this to your `babel.config.js`

```js
[
  'react-native-reanimated/plugin',
  {
    globals: ['__recognize'],
  },
]
```

## Usage

1. Live scanning using React Native Vision Camera.

   ```ts
   import * as React from 'react';
   import { StyleSheet } from 'react-native';
   import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
   import { recognize, ScanConfig } from 'vision-camera-dynamsoft-label-recognizer';
   import * as REA from 'react-native-reanimated';

   export default function App() {
     const [hasPermission, setHasPermission] = React.useState(false);
     const devices = useCameraDevices();
     const device = devices.back;
     const frameProcessor = useFrameProcessor((frame) => {
       'worklet'
       const config:ScanConfig = {};
       config.license = "<license>" //apply for a 30-day trial license here: https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr
       const result = recognize(frame,config);
     }, [])

     React.useEffect(() => {
       (async () => {
         const status = await Camera.requestCameraPermission();
         setHasPermission(status === 'authorized');
       })();
     }, []);

     return (
       device != null &&
       hasPermission && (
         <>
           <Camera
             style={StyleSheet.absoluteFill}
             device={device}
             isActive={true}
             frameProcessor={frameProcessor}
             frameProcessorFps={1}
           />
         </>
       )
     );
   }

   const styles = StyleSheet.create({
     container: {
       flex: 1,
       alignItems: 'center',
       justifyContent: 'center',
     },
   });
   ```

2. Recognizing text from static images.

   ```ts
   import type { ScanConfig } from "vision-camera-dynamsoft-label-recognizer";
   import * as DLR from "vision-camera-dynamsoft-label-recognizer";
   
   const config:ScanConfig = {};
   config.license = "<license>" //apply for a 30-day trial license here: https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr
   const result = await DLR.decodeBase64(base64,config);
   ```

## Interfaces

Scanning configuration:

```ts
//the value is in percentage
export interface ScanRegion{
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface ScanConfig{
  template?: string;
  templateName?: string;
  license?: string;
  scanRegion?: ScanRegion;
  customModelConfig?: CustomModelConfig;
  includeImageBase64?: boolean;
}

export interface CustomModelConfig {
  customModelFolder: string;
  customModelFileNames: string[];
}
```

You can use a custom model like a model for MRZ passport reading using the `CustomModelConfig` prop.

You need to put the model folder in the `assets` folder for Android or the root for iOS.

About the result:

```ts
export interface ScanResult {
  results: DLRResult[];
  imageBase64?: string;
}

export interface DLRResult {
  referenceRegionName: string;
  textAreaName: string;
  pageNumber: number;
  location: Quadrilateral;
  lineResults: DLRLineResult[];
}

export interface Quadrilateral{
  points:Point[];
}

export interface Point {
  x:number;
  y:number;
}

export interface DLRLineResult {
  text: string;
  confidence: number;
  characterModelName: string;
  characterResults: DLRCharacherResult[];
  lineSpecificationName: string;
  location: Quadrilateral;
}

export interface DLRCharacherResult {
  characterH: string;
  characterM: string;
  characterL: string;
  characterHConfidence: number;
  characterMConfidence: number;
  characterLConfidence: number;
  location: Quadrilateral;
}
```

## Supported Platforms

* Android
* iOS

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
