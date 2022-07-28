import * as React from 'react';

import { StyleSheet, SafeAreaView } from 'react-native';
import { recognize, DLRConfig, ScanRegion } from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import BarcodeMask from 'react-native-barcode-mask';
import * as REA from 'react-native-reanimated';
import { Dimensions } from 'react-native';



export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices();
  const device = devices.back;
  const [maskHeight,setMaskHeight] = React.useState(100);
  const [maskWidth,setMaskWidth] = React.useState(300);
  const useWindowWidthShared = REA.useSharedValue(Dimensions.get('window').width);
  const useWindowHeightShared = REA.useSharedValue(Dimensions.get('window').height);

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    let config:DLRConfig = {license:""};
    const windowWidth = useWindowWidthShared.value;
    const windowHeight = useWindowHeightShared.value;
    const centerX = windowWidth/2;
    const centerY = windowHeight/2;
    console.log("width: "+windowWidth);
    console.log("height: "+windowHeight);
    console.log("centerX: "+centerX);
    console.log("centerY: "+centerY);
    const left = Math.ceil((centerX - maskWidth/2)/windowWidth*100);
    const top = Math.ceil((centerY - maskHeight/2)/windowHeight*100);
    const width = Math.ceil(maskWidth/windowWidth*100);
    const height = Math.ceil(maskHeight/windowHeight*100);
    
    let scanRegion:ScanRegion = 
    {
      left: left,
      top: top,
      width: width,
      height: height
    };

    config.license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
    config.scanRegion = scanRegion;

    let result = recognize(frame,config);
    console.log(result);
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'authorized');
    })();
    const width = Dimensions.get('window').width;
    const height = Dimensions.get('window').height;
    setMaskWidth(width*0.8)
    setMaskHeight(height*0.15)
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
