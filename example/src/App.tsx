import * as React from 'react';

import { StyleSheet, SafeAreaView } from 'react-native';
import { recognize, DLRConfig } from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';


export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices();
  const device = devices.back;
  
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    let config:DLRConfig = {license:""};
    let result = recognize(frame,config);
    console.log(result);
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'authorized');
    })();
  }, []);

 return (
    <SafeAreaView style={styles.container}>
      {device != null &&
      hasPermission && (
      <>
        <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        frameProcessor={frameProcessor}
        frameProcessorFps={2}
        />
      </>)}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
