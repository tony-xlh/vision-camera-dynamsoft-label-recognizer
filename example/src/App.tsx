import * as React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import ScannerScreen from './screens/Scanner';
import HomeScreen from './screens/Home';
import ImageReaderScreen from './screens/ImageReader';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Scanner" component={ScannerScreen} />
        <Stack.Screen name="ImageReader" component={ImageReaderScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
