export interface ScanResult {
  results: DLRResult[];
  imageBase64?: string;
}

export interface DLRResult {
  referenceRegionName: string;
  textAreaName: string;
  pageNumber: number;
  location: Quadrilateral;
  lineResults: DLRLineResult[];
}

export interface Quadrilateral{
  points:Point[];
}

export interface Point {
  x:number;
  y:number;
}

export interface DLRLineResult {
  text: string;
  confidence: number;
  characterModelName: string;
  characterResults: DLRCharacherResult[];
  lineSpecificationName: string;
  location: Quadrilateral;
}

export interface DLRCharacherResult {
  characterH: string;
  characterM: string;
  characterL: string;
  characterHConfidence: number;
  characterMConfidence: number;
  characterLConfidence: number;
  location: Quadrilateral;
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
  customModelConfig?: CustomModelConfig;
  includeBase64?: boolean;
}

export interface CustomModelConfig {
  customModelFolder: string;
  customModelFileNames: string[];
}
