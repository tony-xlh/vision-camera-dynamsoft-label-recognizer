# vision-camera-dynamsoft-label-recognizer


React Native Vision Camera Frame Processor Plugin of [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/)


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

```ts
import * as React from 'react';
import { StyleSheet } from 'react-native';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import { recognize, DLRConfig } from 'vision-camera-dynamsoft-label-recognizer';
import * as REA from 'react-native-reanimated';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices();
  const device = devices.back;
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    const config:DLRConfig = {};
    const results:string[] = recognize(frame,config);
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
          frameProcessorFps={"auto"}
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

## Interfaces

```ts
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
```

You can use a custom model like a model for MRZ passport reading using the `CustomModelConfig` prop.

You need to put the model folder in the `assets` folder for Android or the root for iOS.

## Supported Platforms

* Android
* iOS

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
