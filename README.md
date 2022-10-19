# vision-camera-dynamsoft-label-recognizer


React Native Vision Camera Frame Processor Plugin of [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/)

[Demo video](https://user-images.githubusercontent.com/5462205/183577222-52023a99-0b51-4eff-875e-868ef4a387d9.mp4)

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

You can use a custom model like a model for MRZ passport reading using the `CustomModelConfig` prop. You can find the MRZ model in the example.

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

## Detailed Installation Guide

Let's create a new react native project and use the plugin.

1. Create a new project: `npx react-native init MyTestApp`
2. Install required packages: `npm install vision-camera-dynamsoft-label-recognizer react-native-reanimated react-native-vision-camera`. Update relevant files following the [react-native-reanimated installation guide](https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/installation/). You can use jsc instead of hermes
3. Update the `babel.config.js` file
4. Add camera permission for both Android and iOS
5. Update `App.tsx` to use the camera and the plugin
6. For Android, register the plugin in `MainApplication.java` following the [guide](https://mrousavy.com/react-native-vision-camera/docs/guides/frame-processors-plugins-android)
7. Run the project: `npx react-native run-andoid/run-ios`

You can check out the [example](https://github.com/tony-xlh/vision-camera-dynamsoft-label-recognizer/tree/main/example) for more details.

## Blogs on How the Plugin is Made

* [Build a Label Recognition Frame Processor Plugin for React Native Vision Camera (Android)](https://www.dynamsoft.com/codepool/react-native-vision-camera-label-recognition-plugin-android.html)
* [Build a Label Recognition Frame Processor Plugin for React Native Vision Camera (iOS)](https://www.dynamsoft.com/codepool/react-native-vision-camera-label-recognition-plugin-ios.html)
* [Build a React Native MRZ Scanner using Vision Camera](https://www.dynamsoft.com/codepool/react-native-mrz-scanner-vision-camera.html)

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
