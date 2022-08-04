import React from "react";
import { SafeAreaView, StyleSheet, Text, TouchableOpacity } from "react-native";
import SelectDropdown from 'react-native-select-dropdown'

const usecases = ["MRZ", "General"]

export default function HomeScreen({route, navigation}) {
  const [selectedUseCase,setSelectedUseCase] = React.useState(0);
  const onPressed = (target:string) => {
    navigation.navigate(
      {
        name: target
      }
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={{margin:8}}>Use Case:</Text>
      <SelectDropdown
        data={usecases}
        defaultValueByIndex={0}
        buttonStyle={{backgroundColor:"transparent"}}
        buttonTextStyle={{textAlign:"left",fontSize:15}}
        defaultButtonText={'Select use case'}
        onSelect={(selectedItem, index) => {
          setSelectedUseCase(index);
        }}
        buttonTextAfterSelection={(selectedItem, index) => {
          // text represented after item is selected
          // if data array is an array of objects then return selectedItem.property to render after item is selected
          return selectedItem
        }}
        rowTextForSelection={(item, index) => {
          // text represented for each item in dropdown
          // if data array is an array of objects then return item.property to represent item in dropdown
          return item
        }}
      />
      <TouchableOpacity
        style={styles.button}
        onPress={() => onPressed("Scanner")}
      >
        <Text style={styles.buttonText}>Live Scan</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.button}
        onPress={() => onPressed("ImageReader")}
      >
        <Text style={styles.buttonText}>Static Images</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex:1,
  },
  info: {
    margin: 8,
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
