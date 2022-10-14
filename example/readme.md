This example can recognize text from camera stream or from static images.

It has two use cases:

1. General. Recognize any text it can find.
2. MRZ. Recognize the text of the machine-readable zone found on passports.

Note:

React Native Vision Camera has a bug of setting the camera resolution on Android. You have to apply this pr first: <https://github.com/mrousavy/react-native-vision-camera/pull/833>.

How to run:

1. npm install
2. cd ..
3. npm install
4. cd example
5. npx react-native run-andoid # or npx react-native run-ios
