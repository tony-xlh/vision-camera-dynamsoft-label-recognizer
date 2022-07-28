import type { Frame } from 'react-native-vision-camera'

export enum EnumPresetTemplate {
  MRZ = "{\"CharacterModelArray\":[{\"DirectoryPath\":\"\",\"FilterFilePath\":\"\",\"Name\":\"NumberUppercase\"}],\"LabelRecognizerParameterArray\":[{\"BinarizationModes\":[{\"BlockSizeX\":0,\"BlockSizeY\":0,\"EnableFillBinaryVacancy\":1,\"LibraryFileName\":\"\",\"LibraryParameters\":\"\",\"Mode\":\"BM_LOCAL_BLOCK\",\"ThreshValueCoefficient\":15}],\"CharacterModelName\":\"NumberUppercase\",\"LetterHeightRange\":[5,1000,1],\"LineStringLengthRange\":[44,44],\"MaxLineCharacterSpacing\":130,\"LineStringRegExPattern\":\"(P[OM<][A-Z]{3}([A-Z<]{0,35}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,35}<{0,35}){(39)}){(44)}|([A-Z0-9<]{9}[0-9][A-Z]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[0-9<][0-9]){(44)}\",\"MaxThreadCount\":4,\"Name\":\"locr\",\"TextureDetectionModes\":[{\"Mode\":\"TDM_GENERAL_WIDTH_CONCENTRATION\",\"Sensitivity\":8}],\"ReferenceRegionNameArray\":[\"DRRegion\"]}],\"LineSpecificationArray\":[{\"Name\":\"L0\",\"LineNumber\":\"\",\"BinarizationModes\":[{\"BlockSizeX\":30,\"BlockSizeY\":30,\"Mode\":\"BM_LOCAL_BLOCK\"}]}],\"ReferenceRegionArray\":[{\"Localization\":{\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100],\"MeasuredByPercentage\":1,\"SourceType\":\"LST_MANUAL_SPECIFICATION\"},\"Name\":\"DRRegion\",\"TextAreaNameArray\":[\"DTArea\"]}],\"TextAreaArray\":[{\"LineSpecificationNameArray\":[\"L0\"],\"Name\":\"DTArea\",\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100]}]}"
}

export enum EnumPresetTemplateName {
  MRZ = "locr"
}


export interface ScanRegion{
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface DLRConfig{
  template?: string;
  templateName?: string;
  license?: string;
  scanRegion?: ScanRegion;
}

export function recognize(frame: Frame,config: DLRConfig): [] {
  'worklet'
  // @ts-ignore
  // eslint-disable-next-line no-undef
  return __recognize(frame, config)
}
