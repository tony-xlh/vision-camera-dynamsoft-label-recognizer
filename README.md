
# vision-camera-dynamsoft-label-recognizer

React Native Vision Camera Frame Processor Plugin of [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/)

[Demo video](https://user-images.githubusercontent.com/5462205/204175763-ea23321d-8ae1-40ea-b9ce-209bbe6405bb.mp4)

## Versions

For vision-camera v2, use versions 0.x.

For vision-camera v3, use versions 1.x.

For vision-camera v4, use versions >= 2.0.0.

## SDK Versions Used for Different Platforms

| Product      | Android |    iOS |
| ----------- | ----------- | -----------  |
| Dynamsoft Label Recognizer    | 3.4.20       | 3.4.20     |

## Installation

```sh
yarn add vision-camera-dynamsoft-label-recognizer
cd ios && pod install
```

Add the plugin to your `babel.config.js`:

```js
module.exports = {
   plugins: [['react-native-worklets-core/plugin']],
    // ...
```

> Note: You have to restart metro-bundler for changes in the `babel.config.js` file to take effect.

## Usage

1. Scan text with vision camera.
   
   ```js
   import { recognize } from 'vision-camera-dynamsoft-label-recognizer';
 
   // ...
   const frameProcessor = useFrameProcessor((frame) => {
     'worklet';
     const scanResult = recognize(frame);
   }, []);
   ```
   
2. Scan text from base64-encoded static images.

   ```ts
   const scanResult = await decodeBase64(base64);
   ```

3. License initialization ([apply for a trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform)).

   ```ts
   await initLicense("your license");
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
  scanRegion?: ScanRegion;
  includeImageBase64?: boolean;
  template?: String;
}
```

About the result:

```ts
export interface ScanResult {
  results: DLRResult[];
  imageBase64?: string;
}

export interface DLRResult {
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


## Blog

* [Build a Label Recognition Frame Processor Plugin for React Native Vision Camera - Android](https://www.dynamsoft.com/codepool/react-native-vision-camera-label-recognition-plugin-android.html)
* [Build a Label Recognition Frame Processor Plugin for React Native Vision Camera - iOS](https://www.dynamsoft.com/codepool/react-native-vision-camera-label-recognition-plugin-ios.html)

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
