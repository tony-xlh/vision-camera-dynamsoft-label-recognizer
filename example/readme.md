This example can recognize text from camera stream or from static images.

It has two use cases:

1. General. Recognize any text it can find.
2. MRZ. Recognize the text of the machine-readable zone found on passports.

Note:

React Native Vision Camera has a bug of setting the camera resolution on Android. You have to apply this pr first: <https://github.com/mrousavy/react-native-vision-camera/pull/833>.

How to run:


1. cd ..
2. npm install
3. cd example
4. npm install
5. npx react-native run-android # or npx react-native run-ios
