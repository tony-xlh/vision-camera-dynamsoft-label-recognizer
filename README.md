
# vision-camera-dynamsoft-label-recognizer

React Native Vision Camera Frame Processor Plugin of [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/)

[Demo video](https://user-images.githubusercontent.com/5462205/204175763-ea23321d-8ae1-40ea-b9ce-209bbe6405bb.mp4)

## Versions

For vision-camera v2, use versions 0.x.

For vision-camera v3, use versions >= 1.0.0.

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

3. License initialization ([apply for a trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr)).

   ```ts
   await initLicense("your license");
   ```

## Supported Platforms

* Android
* iOS

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
