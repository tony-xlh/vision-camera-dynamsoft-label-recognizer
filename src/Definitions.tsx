export interface ScanResult {
  results: DLRResult[];
  imageBase64?: string;
}

export interface ScanConfig{
  scanRegion?: ScanRegion;
  includeImageBase64?: boolean;
  template?: string;
}

export interface ScanRegion{
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface DLRResult {
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
