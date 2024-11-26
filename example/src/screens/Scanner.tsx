import * as React from 'react';

import { StyleSheet, SafeAreaView, Alert, Modal, Pressable, Text, View, Platform, Dimensions } from 'react-native';
import { recognize, type ScanConfig, type ScanRegion, type DLRCharacherResult, type DLRLineResult, type DLRResult, type ScanResult } from 'vision-camera-dynamsoft-label-recognizer';
import * as DLR from 'vision-camera-dynamsoft-label-recognizer';
import { Camera, runAsync, runAtTargetFps, useCameraDevice, useCameraDevices, useCameraFormat, useFrameProcessor } from 'react-native-vision-camera';
import { Svg, Image, Rect, Circle } from 'react-native-svg';
import { Worklets, useSharedValue } from 'react-native-worklets-core';

const RecognizedCharacter =(props:{"char":DLRCharacherResult}) =>  {
  if (props.char.characterHConfidence>50) {
    return <Text style={[styles.modalText]}>{props.char.characterH}</Text>
  }else{
    return <Text style={[styles.modalText,styles.lowConfidenceText]}>{props.char.characterH}</Text>
  }
}

const scanRegion:ScanRegion = {
  left: 5,
  top: 40,
  width: 90,
  height: 10
}

export default function ScannerScreen({route}) {
  const [imageData,setImageData] = React.useState(undefined as undefined|string);
  const [isActive,setIsActive] = React.useState(true);
  const [modalVisible, setModalVisible] = React.useState(false);
  const modalVisibleShared = useSharedValue(false);
  const mounted = useSharedValue(false);
  const [hasPermission, setHasPermission] = React.useState(false);
  const [frameWidth, setFrameWidth] = React.useState(1280);
  const [frameHeight, setFrameHeight] = React.useState(720);
  const [recognitionResults, setRecognitionResults] = React.useState([] as DLRLineResult[]);
  const device = useCameraDevice("back");
  const format = useCameraFormat(device, [
    { videoResolution: { width: 1920, height: 1080 } },
    { fps: 30 }
  ])
  React.useEffect(() => {
    (async () => {
      console.log("mounted");
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
      let license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="; //one-day public trial
      const result = await DLR.initLicense(license);
      if (result === false) {
        Alert.alert("Error","License invalid");
      }
      mounted.value = true;
    })();
    return ()=>{
      console.log("unmounted");
      mounted.value = false;
      modalVisibleShared.value = false;
      setIsActive(false);
    }
  }, []);

  const convertAndSetRecognitionResults = (records:Record<string,ScanResult>) => {
    let scanResult:ScanResult|undefined = records["0"];
    console.log(records);
    console.log(scanResult);
    if (scanResult) {
      let lineResults = scanResult.results[0]?.lineResults;
      if (lineResults) {
        setRecognitionResults(lineResults);
      }
    }
  }

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
        <Svg style={styles.srcImage} viewBox={getViewBoxForCroppedImage()}>
          <Image
            href={{uri:imageData}}
          />
          {charactersSVG("char",0,0)}
        </Svg>
      );
    }
    return null;
  }

  const charactersSVG = (prefix:string,offsetX:number,offsetY:number) => {
    let characters:React.ReactElement[] = [];
    let idx = 0;
    recognitionResults.forEach(lineResult => {
      lineResult.characterResults.forEach((characterResult,index) => {
        characters.push(<Circle 
          key={prefix+index}
          cx={characterResult.location.points[0]!.x+offsetX} 
          cy={characterResult.location.points[3]!.y+offsetY+4} 
          r="1" stroke="blue" fill="blue"/>);
        idx = idx + 1;
      });
    });

    if (characters.length > 0) {
      return characters;
    }else{
      return null
    }
    
  }

  const getViewBox = () => {
    const frameSize = getFrameSize();
    const viewBox = "0 0 "+frameSize.width+" "+frameSize.height;
    return viewBox;
  }

  const getViewBoxForCroppedImage = () => {
    const frameSize = getFrameSize();
    const viewBox = "0 0 "+(frameSize.width*scanRegion.width/100)+" "+(frameSize.height*scanRegion.height/100);
    return viewBox;
  }

  const updateFrameSize = (width:number, height:number) => {
    if (width != frameWidth && height!= frameHeight) {
      setFrameWidth(width);
      setFrameHeight(height);
    }
  }

  const getOffsetX = () => {
    const frameSize = getFrameSize();
    return scanRegion.left/100*frameSize.width;
  }

  const getOffsetY = () => {
    const frameSize = getFrameSize();
    return scanRegion.top/100*frameSize.height;
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
    if (frameWidth>frameHeight){
      if (Dimensions.get('window').width>Dimensions.get('window').height) {
        value = false;
      }else{
        value = true;
      }
    }else if (frameWidth<frameHeight) {
      if (Dimensions.get('window').width<Dimensions.get('window').height) {
        value = false;
      }else{
        value = true;
      }
    }
    return value;
  }

  const updateFrameSizeJS = Worklets.createRunOnJS(updateFrameSize);
  const setImageDataJS = Worklets.createRunOnJS(setImageData);
  const setRecognitionResultsJS = Worklets.createRunOnJS(setRecognitionResults);
  const setModalVisibleJS = Worklets.createRunOnJS(setModalVisible);
  const convertAndSetRecognitionResultsJS = Worklets.createRunOnJS(convertAndSetRecognitionResults);
  
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    if (modalVisibleShared.value === false && mounted.value) {
      runAsync(frame, () => {
        'worklet'
        updateFrameSizeJS(frame.width, frame.height);

        let config:ScanConfig = {};

        console.log("frame width:"+frame.width);
        console.log("frame height:"+frame.height);
        config.scanRegion = scanRegion;
        config.includeImageBase64 = true;
        let scanResult = recognize(frame,config);
        //convertAndSetRecognitionResultsJS(scanResult);
        let results:DLRResult[] = scanResult.results;
        console.log(results);
        let lineResults:DLRLineResult[] = [];
        for (let index = 0; index < results.length; index++) {
          const result = results[index];
          const lines = result?.lineResults;
          if (lines) {
            lines.forEach(line => {
              console.log(line.text);
              lineResults.push(line);
              line.characterResults.forEach(char => {
                console.log(char.characterH);
              });
            });
          }
        }

        if (modalVisibleShared.value === false) { //check is modal visible again since the recognizing process takes time
          if (lineResults.length>0) {
            if (scanResult.imageBase64) {
              console.log("has image: ");
              setImageDataJS("data:image/jpeg;base64,"+scanResult.imageBase64);
            }

            setRecognitionResultsJS(lineResults);
            modalVisibleShared.value = true;
            setModalVisibleJS(true);
          }
        }  
      })
      
    }
  }, [])


  return (
    <SafeAreaView style={styles.container}>
      {device != null &&
      hasPermission && (
      <>
        <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isActive}
        frameProcessor={frameProcessor}
        format={format}
        pixelFormat='yuv'
        resizeMode='contain'
        >
        </Camera>
        <Svg preserveAspectRatio='xMidYMid slice' style={StyleSheet.absoluteFill} viewBox={getViewBox()}>
          <Rect 
            x={scanRegion.left/100*getFrameSize().width}
            y={scanRegion.top/100*getFrameSize().height}
            width={scanRegion.width/100*getFrameSize().width}
            height={scanRegion.height/100*getFrameSize().height}
            strokeWidth="2"
            stroke="red"
            fillOpacity={0.0}
          />
          {charactersSVG("char-cropped",getOffsetX(),getOffsetY())}
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
          setRecognitionResults([]);
        }}
      >
        <View style={styles.centeredView}>
          <View style={styles.modalView}>
            {renderImage()}
            {recognitionResults.map((result,index) => (
              <Text key={"line-"+index}>
                {result.characterResults.map((char,index) => (
                  <RecognizedCharacter key={"rchar-"+index} char={char}/>
                ))}  
              </Text>
            ))}
            <View style={styles.buttonView}>
                <Pressable
                  style={[styles.button, styles.buttonClose]}
                  onPress={() => {
                    modalVisibleShared.value = !modalVisible;
                    setModalVisible(!modalVisible)
                    setRecognitionResults([]);
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

const getWindowWidth = () => {
  return Dimensions.get("window").width;
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
  srcImage: {
    width: getWindowWidth()*0.7,
    height: 60,
    resizeMode: "contain"
  },
});
