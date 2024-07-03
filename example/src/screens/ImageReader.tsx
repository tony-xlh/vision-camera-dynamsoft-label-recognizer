import React from "react";
import { Alert, Platform, SafeAreaView, StyleSheet, Text, TouchableOpacity } from "react-native";
import {type CameraOptions, type ImageLibraryOptions, launchCamera, launchImageLibrary} from 'react-native-image-picker';
import type { DLRLineResult } from "vision-camera-dynamsoft-label-recognizer";
import * as DLR from "vision-camera-dynamsoft-label-recognizer";

export default function ImageReaderScreen({route}) {
  const [recognitionResults, setRecognitionResults] = React.useState([] as DLRLineResult[]);
  const [recognizing, setRecognizing] = React.useState(false);
  React.useEffect(() => {
    console.log("mounted");
    (async () => {
      const result = await DLR.initLicense("DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
      if (result === false) {
        Alert.alert("Error","License invalid");
      }

      try {
        await DLR.useCustomModel({customModelFolder:"MRZ",customModelFileNames:["MRZ"]});
        await DLR.updateTemplate("{\"CharacterModelArray\":[{\"DirectoryPath\":\"\",\"Name\":\"MRZ\"}],\"LabelRecognizerParameterArray\":[{\"Name\":\"default\",\"ReferenceRegionNameArray\":[\"defaultReferenceRegion\"],\"CharacterModelName\":\"MRZ\",\"LetterHeightRange\":[5,1000,1],\"LineStringLengthRange\":[30,44],\"LineStringRegExPattern\":\"([ACI][A-Z<][A-Z<]{3}[A-Z0-9<]{9}[0-9][A-Z0-9<]{15}){(30)}|([0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z<]{3}[A-Z0-9<]{11}[0-9]){(30)}|([A-Z<]{0,26}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,26}<{0,26}){(30)}|([ACIV][A-Z<][A-Z<]{3}([A-Z<]{0,27}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,27}){(31)}){(36)}|([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{8}){(36)}|([PV][A-Z<][A-Z<]{3}([A-Z<]{0,35}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,35}<{0,35}){(39)}){(44)}|([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[A-Z0-9<]{2}){(44)}\",\"MaxLineCharacterSpacing\":130,\"TextureDetectionModes\":[{\"Mode\":\"TDM_GENERAL_WIDTH_CONCENTRATION\",\"Sensitivity\":8}],\"Timeout\":9999}],\"LineSpecificationArray\":[{\"BinarizationModes\":[{\"BlockSizeX\":30,\"BlockSizeY\":30,\"Mode\":\"BM_LOCAL_BLOCK\",\"MorphOperation\":\"Close\"}],\"LineNumber\":\"\",\"Name\":\"defaultTextArea->L0\"}],\"ReferenceRegionArray\":[{\"Localization\":{\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100],\"MeasuredByPercentage\":1,\"SourceType\":\"LST_MANUAL_SPECIFICATION\"},\"Name\":\"defaultReferenceRegion\",\"TextAreaNameArray\":[\"defaultTextArea\"]}],\"TextAreaArray\":[{\"Name\":\"defaultTextArea\",\"LineSpecificationNameArray\":[\"defaultTextArea->L0\"]}]}");
      } catch (error:any) {
        console.log(error);
        Alert.alert("Error","Failed to load model.");
      }

    })();
  }, []);

  const onPressed = async (target:string) => {
    setRecognitionResults([]);
    setRecognizing(true);

    let response;
    if (target === "camera") {
      let options: CameraOptions = {
        mediaType: 'photo',
        includeBase64: true,
      }
      response = await launchCamera(options);
    }else{
      let options: ImageLibraryOptions = {
        mediaType: 'photo',
        includeBase64: true,
      }
      response = await launchImageLibrary(options);
    }


    if (response.assets) {
      let base64 = response.assets[0]?.base64;
      if (base64) {
        let scanResult = await DLR.decodeBase64(base64);
        let results = scanResult.results;
        let lineResults:DLRLineResult[] = [];

        results.forEach(result => {
          result.lineResults.forEach(lineResult => {
            lineResults.push(lineResult)
          });
        });
        
        console.log(results);
        setRecognitionResults(lineResults);
      }
    }

    setRecognizing(false);
  }

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity
        style={styles.button}
        onPress={() => onPressed("camera")}
      >
        <Text style={styles.buttonText}>From Camera</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.button}
        onPress={() => onPressed("library")}
      >
        <Text style={styles.buttonText}>From Album</Text>
      </TouchableOpacity>
      {recognizing && 
        <Text>Recognizing...</Text>
      }
      {recognitionResults.map((result, idx) => (
        <Text style={styles.modalText} key={idx}>{result.text}</Text>
      ))}
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
    flex:1,
  },
  button: {
    alignItems: "center",
    backgroundColor: "rgb(33, 150, 243)",
    margin: 8,
    padding: 10,
  },
  buttonText:{
    color: "#FFFFFF",
  },
  modalText: {
    marginBottom: 10,
    textAlign: "left",
    fontSize: 12,
    fontFamily: monospaceFontFamily()
  }
});