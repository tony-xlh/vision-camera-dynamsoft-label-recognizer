import * as React from 'react';

import { StyleSheet, SafeAreaView, Alert, Modal, Pressable, Text, View, Platform, Image, Dimensions } from 'react-native';
import { recognize, ScanConfig, ScanRegion, DLRCharacherResult, DLRLineResult, DLRResult } from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import * as REA from 'react-native-reanimated';
import { Svg, Rect } from 'react-native-svg';
import Clipboard from '@react-native-community/clipboard';


const RecognizedCharacter =(props:{"char":DLRCharacherResult}) =>  {
  if (props.char.characterHConfidence>50) {
    return <Text style={[styles.modalText]}>{props.char.characterH}</Text>
  }else{
    return <Text style={[styles.modalText,styles.lowConfidenceText]}>{props.char.characterH}</Text>
  }
}

const scanRegion:ScanRegion = {
  left: 10,
  top: 40,
  width: 80,
  height: 10
}

export default function ScannerScreen({route}) {
  const useCase = route.params.useCase;
  const [imageData,setImageData] = React.useState(undefined as undefined|string);
  const [isActive,setIsActive] = React.useState(true);
  const [modalVisible, setModalVisible] = React.useState(false);
  const modalVisibleShared = REA.useSharedValue(false);
  const [hasPermission, setHasPermission] = React.useState(false);
  const [frameWidth, setFrameWidth] = React.useState(1280);
  const [frameHeight, setFrameHeight] = React.useState(720);

  const devices = useCameraDevices();
  const device = devices.back;

  const [recognitionResults, setRecognitionResults] = React.useState([] as DLRLineResult[]);
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    if (modalVisibleShared.value === false) {

      REA.runOnJS(updateFrameSize)(frame.width, frame.height);

      let config:ScanConfig = {license:""};

      console.log("frame width:"+frame.width);
      console.log("frame height:"+frame.height);


      //config.license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==";
      config.license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMTAxMDc0MDY2LVRYbE5iMkpwYkdWUWNtOXFYMlJzY2ciLCJvcmdhbml6YXRpb25JRCI6IjEwMTA3NDA2NiJ9";
      config.scanRegion = scanRegion;
      config.includeImageBase64 = true;
      if (useCase === 0) { //mrz use case
        config.template = "{\"CharacterModelArray\":[{\"DirectoryPath\":\"\",\"FilterFilePath\":\"\",\"Name\":\"NumberUppercase\"}],\"LabelRecognizerParameterArray\":[{\"BinarizationModes\":[{\"BlockSizeX\":0,\"BlockSizeY\":0,\"EnableFillBinaryVacancy\":1,\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"BM_LOCAL_BLOCK\",\"ThreshValueCoefficient\":15}],\"CharacterModelName\":\"NumberUppercase\",\"LetterHeightRange\":[5,1000,1],\"LineStringLengthRange\":[44,44],\"MaxLineCharacterSpacing\":130,\"LineStringRegExPattern\":\"(P[OM<][A-Z]{3}([A-Z<]{0,35}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,35}<{0,35}){(39)}){(44)}|([A-Z0-9<]{9}[0-9][A-Z]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[0-9<][0-9]){(44)}\",\"MaxThreadCount\":4,\"Name\":\"locr\",\"TextureDetectionModes\":[{\"Mode\":\"TDM_GENERAL_WIDTH_CONCENTRATION\",\"Sensitivity\":8}],\"ReferenceRegionNameArray\":[\"DRRegion\"]}],\"LineSpecificationArray\":[{\"Name\":\"L0\",\"LineNumber\":\"\",\"BinarizationModes\":[{\"BlockSizeX\":30,\"BlockSizeY\":30,\"Mode\":\"BM_LOCAL_BLOCK\"}]}],\"ReferenceRegionArray\":[{\"Localization\":{\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100],\"MeasuredByPercentage\":1,\"SourceType\":\"LST_MANUAL_SPECIFICATION\"},\"Name\":\"DRRegion\",\"TextAreaNameArray\":[\"DTArea\"]}],\"TextAreaArray\":[{\"LineSpecificationNameArray\":[\"L0\"],\"Name\":\"DTArea\",\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100]}]}";
        config.templateName = "locr";
        config.customModelConfig = {customModelFolder:"MRZ",customModelFileNames:["NumberUppercase","NumberUppercase_Assist_1lIJ","NumberUppercase_Assist_8B","NumberUppercase_Assist_8BHR","NumberUppercase_Assist_number","NumberUppercase_Assist_O0DQ","NumberUppercase_Assist_upcase"]};
      }
      let scanResult = recognize(frame,config);

      let results:DLRResult[] = scanResult.results;
      let lineResults:DLRLineResult[] = [];
      for (let index = 0; index < results.length; index++) {
        const result = results[index];
        const lines = result?.lineResults;
        if (lines) {
          lines.forEach(line => {
            lineResults.push(line);
          });
        }
      }

      console.log(results);
      if (modalVisibleShared.value === false) { //check is modal visible again since the recognizing process takes time
        if (lineResults.length === 2 || (useCase != 0 && lineResults.length>0)) {
          if (scanResult.imageBase64) {
            console.log("has image: ");
            REA.runOnJS(setImageData)("data:image/jpeg;base64,"+scanResult.imageBase64);
          }
          REA.runOnJS(setRecognitionResults)(lineResults);
          modalVisibleShared.value = true;
          REA.runOnJS(setModalVisible)(true);
        }  
      }
    }
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'authorized');
    })();
    return ()=>{
      console.log("unmounted");
      setIsActive(false);
    }
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
      text = text + result.text + "\n";
    });
    return text.trim();
  }

  const renderImage = () =>{
    if (imageData) {
      return (
        <Image
          style={styles.logo}
          source={{
            uri: imageData,
          }}
        />
      )
    }
    return undefined
  }

  const getViewBox = () => {
    const frameSize = getFrameSize();
    const viewBox = "0 0 "+frameSize.width+" "+frameSize.height;
    return viewBox;
  }

  const updateFrameSize = (width:number, height:number) => {
    if (width != frameWidth && height!= frameHeight) {
      setFrameWidth(width);
      setFrameHeight(height);
    }
  }

  const getFrameSize = ():{width:number,height:number} => {
    let width:number, height:number;
    if (HasRotation()){
      width = frameHeight;
      height = frameWidth;
    }else {
      width = frameWidth;
      height = frameHeight;
    }
    return {width:width,height:height};
  }

  const HasRotation = () => {
    let value = false
    if (Platform.OS === 'android') {
      if (!(frameWidth>frameHeight && Dimensions.get('window').width>Dimensions.get('window').height)){
        value = true;
      }
    }
    return value;
  }

  return (
    <SafeAreaView style={styles.container}>
      {device != null &&
      hasPermission && (
      <>
        <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isActive}
        format={format}
        frameProcessor={frameProcessor}
        frameProcessorFps={1}
        >
        </Camera>
        <Svg style={StyleSheet.absoluteFill} viewBox={getViewBox()}>
          <Rect 
            x={scanRegion.left/100*getFrameSize().width}
            y={scanRegion.top/100*getFrameSize().height}
            width={scanRegion.width/100*getFrameSize().width}
            height={scanRegion.height/100*getFrameSize().height}
            strokeWidth="2"
            stroke="red"
          />
        </Svg>
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
            {renderImage()}
            {recognitionResults.map((result, idx) => (
              <Text key={"line-"+idx}>
                {result.characterResults.map((char, idx) => (
                  <RecognizedCharacter key={"char-"+idx} char={char}/>
                ))}  
              </Text>
              
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
  },
  lowConfidenceText:{
    color:"red",
  },
  logo: {
    width: 150,
    height: 60,
    resizeMode: "stretch"
  },
});
