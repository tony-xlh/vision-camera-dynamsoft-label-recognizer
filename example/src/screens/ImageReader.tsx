import React from "react";
import { SafeAreaView, StyleSheet, Text, TouchableOpacity } from "react-native";
import {CameraOptions, ImageLibraryOptions, launchCamera, launchImageLibrary} from 'react-native-image-picker';
import { decodeBase64, DLRConfig } from "vision-camera-dynamsoft-label-recognizer";

export default function ImageReaderScreen() {

  const onPressed = async (target:string) => {
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
      //console.log(response.assets);
      let base64 = response.assets[0]?.base64;
      if (base64) {
        //console.log(base64);
        let config:DLRConfig = {};
        config.license = "DLS2eyJoYW5kc2hha2VDb2RlIjoiMTAwMjI3NzYzLVRYbE5iMkpwYkdWUWNtOXFYMlJzY2ciLCJvcmdhbml6YXRpb25JRCI6IjEwMDIyNzc2MyJ9";
        config.template = "{\"CharacterModelArray\":[{\"DirectoryPath\":\"\",\"FilterFilePath\":\"\",\"Name\":\"NumberUppercase\"}],\"LabelRecognizerParameterArray\":[{\"BinarizationModes\":[{\"BlockSizeX\":0,\"BlockSizeY\":0,\"EnableFillBinaryVacancy\":1,\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"BM_LOCAL_BLOCK\",\"ThreshValueCoefficient\":15}],\"CharacterModelName\":\"NumberUppercase\",\"LetterHeightRange\":[5,1000,1],\"LineStringLengthRange\":[44,44],\"MaxLineCharacterSpacing\":130,\"LineStringRegExPattern\":\"(P[OM<][A-Z]{3}([A-Z<]{0,35}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,35}<{0,35}){(39)}){(44)}|([A-Z0-9<]{9}[0-9][A-Z]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[0-9<][0-9]){(44)}\",\"MaxThreadCount\":4,\"Name\":\"locr\",\"TextureDetectionModes\":[{\"Mode\":\"TDM_GENERAL_WIDTH_CONCENTRATION\",\"Sensitivity\":8}],\"ReferenceRegionNameArray\":[\"DRRegion\"]}],\"LineSpecificationArray\":[{\"Name\":\"L0\",\"LineNumber\":\"\",\"BinarizationModes\":[{\"BlockSizeX\":30,\"BlockSizeY\":30,\"Mode\":\"BM_LOCAL_BLOCK\"}]}],\"ReferenceRegionArray\":[{\"Localization\":{\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100],\"MeasuredByPercentage\":1,\"SourceType\":\"LST_MANUAL_SPECIFICATION\"},\"Name\":\"DRRegion\",\"TextAreaNameArray\":[\"DTArea\"]}],\"TextAreaArray\":[{\"LineSpecificationNameArray\":[\"L0\"],\"Name\":\"DTArea\",\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100]}]}";
        config.templateName = "locr";
        config.customModelConfig = {customModelFolder:"MRZ",customModelFileNames:["NumberUppercase","NumberUppercase_Assist_1lIJ","NumberUppercase_Assist_8B","NumberUppercase_Assist_8BHR","NumberUppercase_Assist_number","NumberUppercase_Assist_O0DQ","NumberUppercase_Assist_upcase"]};
        let results = await decodeBase64(base64,config)
        console.log(results);
      }
    }
    
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
    </SafeAreaView>
  );
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
});