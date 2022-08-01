import * as React from 'react';

import { StyleSheet, SafeAreaView, Alert, Modal, Pressable, Text, View, Platform } from 'react-native';
import { recognize, DLRConfig, ScanRegion, EnumPresetTemplate, EnumPresetTemplateName } from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import BarcodeMask from 'react-native-barcode-mask';
import * as REA from 'react-native-reanimated';
import { Dimensions } from 'react-native';
import Clipboard from '@react-native-community/clipboard';


export default function App() {
  const [modalVisible, setModalVisible] = React.useState(false);
  const modalVisibleShared = REA.useSharedValue(false);
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices();
  const device = devices.back;
  const [maskHeight,setMaskHeight] = React.useState(100);
  const [maskWidth,setMaskWidth] = React.useState(300);
  const useWindowWidthShared = REA.useSharedValue(Dimensions.get('window').width);
  const useWindowHeightShared = REA.useSharedValue(Dimensions.get('window').height);
  const [recognitionResults, setRecognitionResults] = React.useState([] as string[]);
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    if (modalVisibleShared.value === false) {
      let config:DLRConfig = {license:""};
      const windowWidth = useWindowWidthShared.value;
      const windowHeight = useWindowHeightShared.value;
      const centerX = windowWidth/2;
      const centerY = windowHeight/2;
      const left = Math.ceil((centerX - maskWidth/2)/windowWidth*100);
      const top = Math.ceil((centerY - maskHeight/2)/windowHeight*100);
      const width = Math.ceil(maskWidth/windowWidth*100);
      const height = Math.ceil(maskHeight/windowHeight*100);
      console.log("frame width:"+frame.width);
      console.log("frame height:"+frame.height);
      let scanRegion:ScanRegion = 
      {
        left: left,
        top: top,
        width: width,
        height: height
      };

      config.license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
      config.scanRegion = scanRegion;
      config.template = EnumPresetTemplate.MRZ;
      config.templateName = EnumPresetTemplateName.MRZ;
      let results:string[] = recognize(frame,config);
      console.log(results);
      if (results.length === 2) {
        REA.runOnJS(setRecognitionResults)(results);
        modalVisibleShared.value = true;
        REA.runOnJS(setModalVisible)(true);
      }
    }
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'authorized');
    })();
    const width = Dimensions.get('window').width;
    const height = Dimensions.get('window').height;
    setMaskWidth(width*0.95)
    setMaskHeight(height*0.4)
    
  }, []);

  const format = React.useMemo(() => {
    const desiredWidth = 1280;
    const desiredHeight = 720;
    if (device) {
      for (let index = 0; index < device.formats.length; index++) {
        const format = device.formats[index];
        if (format) {
          console.log("h: "+format.videoHeight);
          console.log("w: "+format.videoWidth);
          if (format.videoWidth == desiredWidth && format.videoHeight == desiredHeight){
            console.log("select format: "+format);
            return format;
          }
        }
      };
    }
    return undefined;
  }, [device?.formats])


  const getText = () => {
    let text = "";
    recognitionResults.forEach(result => {
      text = text + result + "\n";
    });
    return text.trim();
  }

  return (
    <SafeAreaView style={styles.container}>
      {device != null &&
      hasPermission && (
      <>
        <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        format={format}
        frameProcessor={frameProcessor}
        frameProcessorFps={5}
        >
        </Camera>
        <BarcodeMask width={maskWidth} height={maskHeight} />
      </>)}
      <Modal
        animationType="slide"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => {
          Alert.alert("Modal has been closed.");
          modalVisibleShared.value = !modalVisible;
          setModalVisible(!modalVisible);
        }}
      >
        <View style={styles.centeredView}>
          <View style={styles.modalView}>
            {recognitionResults.map((result, idx) => (
              <Text style={styles.modalText} key={idx}>{result}</Text>
            ))}
            <View style={styles.buttonView}>
                <Pressable
                  style={[styles.button, styles.buttonClose]}
                  onPress={() => {
                    Alert.alert("","Copied");
                    Clipboard.setString(getText());
                  }}
                >
                  <Text style={styles.textStyle}>Copy</Text>
                </Pressable>
                <Pressable
                  style={[styles.button, styles.buttonClose]}
                  onPress={() => {
                    modalVisibleShared.value = !modalVisible;
                    setModalVisible(!modalVisible)
                  }}
                >
                  <Text style={styles.textStyle}>Rescan</Text>
                </Pressable>
            </View>
            
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const monospaceFontFamily = () => {
  if (Platform.OS === "ios") {
    return "Courier New";
  }else{
    return "monospace";
  }
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
  centeredView: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    marginTop: 22
  },
  modalView: {
    margin: 20,
    backgroundColor: "white",
    borderRadius: 20,
    padding: 35,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5
  },
  buttonView:{
    flexDirection:'row',
  },
  button: {
    borderRadius: 20,
    padding: 10,
    margin: 5
  },
  buttonOpen: {
    backgroundColor: "#F194FF",
  },
  buttonClose: {
    backgroundColor: "#2196F3",
  },
  textStyle: {
    color: "white",
    fontWeight: "bold",
    textAlign: "center",
  },
  modalText: {
    marginBottom: 10,
    textAlign: "left",
    fontSize: 12,
    fontFamily: monospaceFontFamily()
  }
});
