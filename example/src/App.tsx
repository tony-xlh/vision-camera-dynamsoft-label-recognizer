import * as React from 'react';

import { StyleSheet, SafeAreaView } from 'react-native';
import { recognize, DLRConfig } from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import BarcodeMask from 'react-native-barcode-mask';

import { Dimensions } from 'react-native';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices();
  const device = devices.back;
  const [maskHeight,setMaskHeight] = React.useState(100);
  const [maskWidth,setMaskWidth] = React.useState(300);
  
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
    const windowWidth = Dimensions.get('window').width;
    const windowHeight = Dimensions.get('window').height;
    setMaskWidth(windowWidth*0.8)
    setMaskHeight(windowHeight*0.15)
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
        frameProcessorFps={1}
        >
        </Camera>
        <BarcodeMask width={maskWidth} height={maskHeight} />
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
