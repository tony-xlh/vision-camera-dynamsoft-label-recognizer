//
//  VisionCameraDynamsoftLabelRecognizer.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//
import DynamsoftCore
import DynamsoftLicense
import DynamsoftCaptureVisionRouter
import DynamsoftLabelRecognizer

@objc(VisionCameraDynamsoftLabelRecognizer)
class VisionCameraDynamsoftLabelRecognizer: NSObject, LicenseVerificationListener {
    static var router:CaptureVisionRouter = CaptureVisionRouter();
    static var currentModelFolder = "";
    static var currentTemplate = "";
    var licenseResolveBlock:RCTPromiseResolveBlock!;
    var licenseRejectBlock:RCTPromiseRejectBlock!;
    override init(){
        super.init()
        loadTemplate()
    }
    
    func loadTemplate() {
        let template = """
                  {
                      "CaptureVisionTemplates": [
                          {
                              "Name": "Default"
                          },
                          {
                              "Name": "ReadBarcodes_Default",
                              "ImageROIProcessingNameArray": [
                                  "roi_read_barcodes"
                              ],
                              "Timeout": 200,
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeTextLines_Default",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_number_letter"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "DetectDocumentBoundaries_Default",
                              "ImageROIProcessingNameArray": [
                                  "roi_detect_document_boundaries"
                              ]
                          },
                          {
                              "Name": "DetectAndNormalizeDocument_Default",
                              "ImageROIProcessingNameArray": [
                                  "roi_detect_and_normalize_document"
                              ]
                          },
                          {
                              "Name": "NormalizeDocument_Default",
                              "ImageROIProcessingNameArray": [
                                  "roi_normalize_document"
                              ]
                          },
                          {
                              "Name": "ReadBarcodes_SpeedFirst",
                              "ImageROIProcessingNameArray": [
                                  "roi_read_barcodes_speed_first"
                              ],
                              "Timeout": 500
                          },
                          {
                              "Name": "ReadBarcodes_ReadRateFirst",
                              "ImageROIProcessingNameArray": [
                                  "roi_read_barcodes_read_rate"
                              ],
                              "Timeout": 5000
                          },
                          {
                              "Name": "ReadSingleBarcode",
                              "ImageROIProcessingNameArray": [
                                  "roi_read_single_barcode"
                              ],
                              "Timeout": 200,
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeNumbers",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_number"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeLetters",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_letter"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeUppercaseLetters",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_uppercase"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeNumbersAndUppercaseLetters",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_number_uppercase"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "RecognizeNumbersAndLetters",
                              "ImageROIProcessingNameArray": [
                                  "roi_recognize_number_letter"
                              ],
                              "MaxParallelTasks":0
                          },
                          {
                              "Name": "ReadPassportAndId",
                              "OutputOriginalImage": 0,
                              "ImageROIProcessingNameArray": [
                                    "roi_passport_and_id"
                              ],
                              "Timeout": 2000
                          },
                          {
                              "Name": "ReadPassport",
                              "OutputOriginalImage": 0,
                              "ImageROIProcessingNameArray": [
                                    "roi_passport"
                              ],
                              "Timeout": 2000
                          },
                          {
                              "Name": "ReadId",
                              "OutputOriginalImage": 0,
                              "ImageROIProcessingNameArray": [
                                    "roi_id"
                              ],
                              "Timeout": 2000
                          },
                          {
                              "Name" : "ReadDriversLicense",
                              "ImageROIProcessingNameArray" :
                              [
                                  "roi_pdf_417"
                              ],
                              "SemanticProcessingNameArray": [ "sp_pdf_417" ],
                              "Timeout" : 10000
                          },
                          {
                              "Name": "ReadVIN",
                              "ImageROIProcessingNameArray": [
                                  "roi_vin_barcode",
                                  "roi_vin_text"
                              ],
                              "MaxParallelTasks": 4,
                              "SemanticProcessingNameArray": [
                                  "sp_vin_barcode",
                                  "sp_vin_text"
                              ],
                              "Timeout": 10000
                          },
                          {
                              "Name" : "ReadVINBarcode",
                              "ImageROIProcessingNameArray" :
                              [
                                  "roi_vin_barcode"
                              ],
                              "MaxParallelTasks" : 4,
                              "SemanticProcessingNameArray": [ "sp_vin_barcode" ],
                              "Timeout" : 10000
                          },
                          {
                              "Name" : "ReadVINText",
                              "ImageROIProcessingNameArray" :
                              [
                                  "roi_vin_text"
                              ],
                              "MaxParallelTasks" : 4,
                              "SemanticProcessingNameArray": [ "sp_vin_text" ],
                              "Timeout" : 10000
                          }
                      ],
                      "TargetROIDefOptions": [
                          {
                              "Name": "roi_read_barcodes",
                              "TaskSettingNameArray": [
                                  "task_read_barcodes"
                              ]
                          },
                          {
                              "Name": "roi_detect_document_boundaries",
                              "TaskSettingNameArray": [
                                  "task_detect_document_boundaries"
                              ]
                          },
                          {
                              "Name": "roi_detect_and_normalize_document",
                              "TaskSettingNameArray": [
                                  "task_detect_and_normalize_document"
                              ]
                          },
                          {
                              "Name": "roi_normalize_document",
                              "TaskSettingNameArray": [
                                  "task_normalize_document"
                              ]
                          },
                          {
                              "Name": "roi_read_barcodes_speed_first",
                              "TaskSettingNameArray": [
                                  "task_read_barcodes_speed_first"
                              ]
                          },
                          {
                              "Name": "roi_read_barcodes_read_rate",
                              "TaskSettingNameArray": [
                                  "task_read_barcodes_read_rate"
                              ]
                          },
                          {
                              "Name": "roi_read_single_barcode",
                              "TaskSettingNameArray": [
                                  "task_read_single_barcode"
                              ]
                          },
                          {
                              "Name": "roi_recognize_number",
                              "TaskSettingNameArray": [
                                  "task_recognize_number"
                              ]
                          },
                          {
                              "Name": "roi_recognize_letter",
                              "TaskSettingNameArray": [
                                  "task_recognize_letter"
                              ]
                          },
                          {
                              "Name": "roi_recognize_uppercase",
                              "TaskSettingNameArray": [
                                  "task_recognize_uppercase"
                              ]
                          },
                          {
                              "Name": "roi_recognize_number_uppercase",
                              "TaskSettingNameArray": [
                                  "task_recognize_number_uppercase"
                              ]
                          },
                          {
                              "Name": "roi_recognize_number_letter",
                              "TaskSettingNameArray": [
                                  "task_recognize_number_letter"
                              ]
                          },
                          {
                              "Name": "roi_passport_and_id",
                              "TaskSettingNameArray": [
                                    "task_passport_and_id"
                              ]
                          },
                          {
                              "Name": "roi_passport",
                              "TaskSettingNameArray": [
                                    "task_passport"
                              ]
                          },
                          {
                              "Name": "roi_id",
                              "TaskSettingNameArray": [
                                  "task_id"
                              ]
                          },
                          {
                              "Name" : "roi_pdf_417",
                              "TaskSettingNameArray" :
                              [
                                  "task_pdf_417"
                              ]
                          },
                          {
                              "Name" : "roi_vin_barcode",
                              "TaskSettingNameArray" :
                              [
                                  "task_vin_barcode"
                              ]
                          },
                          {
                              "Name" : "roi_vin_text",
                              "TaskSettingNameArray" :
                              [
                                  "task_vin_text"
                              ]
                          }
                      ],
                      "BarcodeFormatSpecificationOptions": [
                          {
                              "Name": "bfs1",
                              "BarcodeFormatIds": [
                                  "BF_PDF417",
                                  "BF_QR_CODE",
                                  "BF_DATAMATRIX",
                                  "BF_AZTEC",
                                  "BF_MICRO_QR",
                                  "BF_MICRO_PDF417",
                                  "BF_DOTCODE"
                              ],
                              "MirrorMode": "MM_BOTH"
                          },
                          {
                              "Name": "bfs2",
                              "BarcodeFormatIds": [
                                  "BF_ALL"
                              ],
                              "MirrorMode": "MM_NORMAL"
                          },
                          {
                              "Name": "bfs1_speed_first",
                              "BaseBarcodeFormatSpecification": "bfs1"
                          },
                          {
                              "Name": "bfs2_speed_first",
                              "BaseBarcodeFormatSpecification": "bfs2"
                          },
                          {
                              "Name": "bfs1_read_rate_first",
                              "BaseBarcodeFormatSpecification": "bfs1"
                          },
                          {
                              "Name": "bfs2_read_rate_first",
                              "BaseBarcodeFormatSpecification": "bfs2"
                          },
                          {
                              "Name": "bfs1_single_barcode",
                              "BaseBarcodeFormatSpecification": "bfs1"
                          },
                          {
                              "Name": "bfs2_single_barcode",
                              "BaseBarcodeFormatSpecification": "bfs2"
                          },
                          {
                              "BarcodeFormatIds" :
                              [
                                  "BF_CODE_39_EXTENDED"
                              ],
                              "BarcodeTextRegExPattern" : "(I{0,1})([0-9A-HJ-NPR-Z]{9}[1-9A-HJ-NPR-TV-Y][0-9A-HJ-NPR-Z]{2}[0-9]{5})",
                              "MirrorMode" : "MM_NORMAL",
                              "ModuleSizeRangeArray" : null,
                              "Name" : "VIN_CODE_39_EXTENDED"
                          },
                          {
                              "BarcodeFormatIds" :
                              [
                                  "BF_DATAMATRIX"
                              ],
                              "BarcodeTextRegExPattern" : "[0-9A-HJ-NPR-Z]{9}[1-9A-HJ-NPR-TV-Y][0-9A-HJ-NPR-Z]{2}[0-9]{5}",
                              "Name" : "VIN_DATAMATRIX"

                          },
                          {
                              "BarcodeFormatIds" :
                              [
                                  "BF_QR_CODE"
                              ],
                              "Name" : "VIN_QR_CODE"
                          }
                      ],
                      "BarcodeReaderTaskSettingOptions": [
                          {
                              "Name": "task_read_barcodes",
                              "ExpectedBarcodesCount" : 1,
                              "BaseBarcodeReaderTaskSettingName": "task_read_single_barcode",
                              "BarcodeFormatSpecificationNameArray": [
                                  "bfs1",
                                  "bfs2"
                              ],
                              "LocalizationModes": [
                                  {
                                      "Mode": "LM_CONNECTED_BLOCKS"
                                  },
                                  {
                                      "Mode": "LM_LINES"
                                  }
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_read_barcodes"
                                  },
                                  {
                                      "Section": "ST_BARCODE_LOCALIZATION",
                                      "ImageParameterName": "ip_read_barcodes"
                                  },
                                  {
                                      "Section": "ST_BARCODE_DECODING",
                                      "ImageParameterName": "ip_read_barcodes"
                                  }
                              ]
                          },
                          {
                              "Name": "task_read_barcodes_speed_first",
                              "ExpectedBarcodesCount" : 0,
                              "BarcodeFormatIds" : [ "BF_DEFAULT" ],
                              "LocalizationModes": [
                                  {
                                      "Mode": "LM_CONNECTED_BLOCKS"
                                  }
                              ],
                              "DeblurModes":[
                                  {
                                      "Mode": "DM_BASED_ON_LOC_BIN"
                                  },
                                  {
                                      "Mode": "DM_THRESHOLD_BINARIZATION"
                                  },
                                  {
                                      "Mode": "DM_DEEP_ANALYSIS"
                                  }
                              ],
                              "BarcodeFormatSpecificationNameArray": [
                                  "bfs1_speed_first",
                                  "bfs2_speed_first"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_read_barcodes_speed_first"
                                  },
                                  {
                                      "Section": "ST_BARCODE_LOCALIZATION",
                                      "ImageParameterName": "ip_read_barcodes_speed_first"
                                  },
                                  {
                                      "Section": "ST_BARCODE_DECODING",
                                      "ImageParameterName": "ip_read_barcodes_speed_first"
                                  }
                              ]
                          },
                          {
                              "Name": "task_read_barcodes_read_rate",
                              "ExpectedBarcodesCount" : 999,
                              "BarcodeFormatIds" : [ "BF_DEFAULT" ],
                              "LocalizationModes": [
                                  {
                                      "Mode" : "LM_CONNECTED_BLOCKS"
                                   },
                                   {
                                      "Mode" : "LM_LINES"
                                   },
                                   {
                                      "Mode" : "LM_STATISTICS"
                                   }
                              ],
                              "DeblurModes":[
                                  {
                                      "Mode": "DM_BASED_ON_LOC_BIN"
                                  },
                                  {
                                      "Mode": "DM_THRESHOLD_BINARIZATION"
                                  },
                                  {
                                      "Mode": "DM_DIRECT_BINARIZATION"
                                  },
                                  {
                                      "Mode": "DM_SMOOTHING"
                                  },
                                  {
                                      "Mode": "DM_DEEP_ANALYSIS"
                                  }
                              ],
                              "BarcodeFormatSpecificationNameArray": [
                                  "bfs1_read_rate_first",
                                  "bfs2_read_rate_first"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_read_barcodes_read_rate"
                                  },
                                  {
                                      "Section": "ST_BARCODE_LOCALIZATION",
                                      "ImageParameterName": "ip_read_barcodes_read_rate"
                                  },
                                  {
                                      "Section": "ST_BARCODE_DECODING",
                                      "ImageParameterName": "ip_read_barcodes_read_rate"
                                  }
                              ]
                          },
                          {
                              "Name": "task_read_single_barcode",
                              "ExpectedBarcodesCount":1,
                              "LocalizationModes": [
                                  {
                                      "Mode": "LM_SCAN_DIRECTLY",
                                      "ScanDirection": 2
                                  },
                                  {
                                      "Mode": "LM_CONNECTED_BLOCKS"
                                  }
                              ],
                              "DeblurModes":[
                                  {
                                      "Mode": "DM_BASED_ON_LOC_BIN"
                                  },
                                  {
                                      "Mode": "DM_THRESHOLD_BINARIZATION"
                                  },
                                  {
                                      "Mode": "DM_DEEP_ANALYSIS"
                                  }
                              ],
                              "BarcodeFormatSpecificationNameArray": [
                                  "bfs1_single_barcode",
                                  "bfs2_single_barcode"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_read_single_barcode"
                                  },
                                  {
                                      "Section": "ST_BARCODE_LOCALIZATION",
                                      "ImageParameterName": "ip_read_single_barcode"
                                  },
                                  {
                                      "Section": "ST_BARCODE_DECODING",
                                      "ImageParameterName": "ip_read_single_barcode"
                                  }
                              ]
                          },
                          {
                              "Name" : "task_pdf_417",
                              "BarcodeColourModes" :
                              [
                                  {
                                      "LightReflection" : 1,
                                      "Mode" : "BICM_DARK_ON_LIGHT"
                                  }
                              ],
                              "BarcodeFormatIds" :
                              [
                                  "BF_PDF417"
                              ],
                              "DeblurModes" : null,
                              "ExpectedBarcodesCount" : 1,
                              "LocalizationModes" :
                              [
                                  {
                                      "Mode" : "LM_CONNECTED_BLOCKS"
                                  },
                                  {
                                      "Mode" : "LM_LINES"
                                  },
                                  {
                                      "Mode" : "LM_STATISTICS"
                                  }
                              ],
                              "SectionImageParameterArray" :
                              [
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_localize_pdf417",
                                      "Section" : "ST_REGION_PREDETECTION"
                                  },
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_localize_pdf417",
                                      "Section" : "ST_BARCODE_LOCALIZATION"
                                  },
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_decode_pdf417",
                                      "Section" : "ST_BARCODE_DECODING"
                                  }
                              ]
                          },
                          {
                              "Name" : "task_vin_barcode",
                              "DeblurModes" : null,
                              "BarcodeColourModes" :
                              [
                                  {
                                      "LightReflection" : 1,
                                      "Mode" : "BICM_DARK_ON_LIGHT"
                                  }
                              ],
                              "BarcodeFormatIds" :
                              [
                                  "BF_CODE_39_EXTENDED",
                                  "BF_QR_CODE",
                                  "BF_DATAMATRIX"
                              ],
                              "BarcodeFormatSpecificationNameArray" :
                              [
                                  "VIN_CODE_39_EXTENDED",
                                  "VIN_QR_CODE",
                                  "VIN_DATAMATRIX"
                              ],
                              "DeformationResistingModes" :
                              [
                                  {
                                      "BinarizationMode" :
                                      {
                                          "BinarizationThreshold" : -1,
                                          "BlockSizeX" : 0,
                                          "BlockSizeY" : 0,
                                          "EnableFillBinaryVacancy" : 0,
                                          "GrayscaleEnhancementModesIndex" : -1,
                                          "Mode" : "BM_LOCAL_BLOCK",
                                          "MorphOperation" : "Close",
                                          "MorphOperationKernelSizeX" : -1,
                                          "MorphOperationKernelSizeY" : -1,
                                          "MorphShape" : "Rectangle",
                                          "ThresholdCompensation" : 10
                                      },
                                      "GrayscaleEnhancementMode" :
                                      {
                                          "Mode" : "GEM_GENERAL",
                                          "Sensitivity" : -1,
                                          "SharpenBlockSizeX" : -1,
                                          "SharpenBlockSizeY" : -1,
                                          "SmoothBlockSizeX" : -1,
                                          "SmoothBlockSizeY" : -1
                                      },
                                      "Level" : 5,
                                      "Mode" : "DRM_SKIP"
                                  }
                              ],
                              "ExpectedBarcodesCount" : 1,
                              "LocalizationModes" :
                              [
                                  {
                                      "Mode" : "LM_CONNECTED_BLOCKS"
                                  },
                                  {
                                      "Mode" : "LM_SCAN_DIRECTLY"
                                  }
                              ],
                              "SectionImageParameterArray" :
                              [
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_localize_vin",
                                      "Section" : "ST_REGION_PREDETECTION"
                                  },
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_localize_vin",
                                      "Section" : "ST_BARCODE_LOCALIZATION"
                                  },
                                  {
                                      "ContinueWhenPartialResultsGenerated" : 1,
                                      "ImageParameterName" : "ip_decode_vin",
                                      "Section" : "ST_BARCODE_DECODING"
                                  }
                              ]
                          }
                      ],
                      "TextLineSpecificationOptions": [
                          {
                              "Name": "tls_number_letter",
                              "CharacterModelName" : "NumberLetter",
                              "OutputResults": 1
                          },
                          {
                              "Name": "tls_number",
                              "CharacterModelName" : "Number",
                              "OutputResults": 1
                          },
                          {
                              "Name": "tls_letter",
                              "CharacterModelName" : "Letter",
                              "OutputResults": 1
                          },
                          {
                              "Name": "tls_uppercase",
                              "CharacterModelName" : "Uppercase",
                              "OutputResults": 1
                          },
                          {
                              "Name": "tls_number_uppercase",
                              "CharacterModelName" : "NumberUppercase",
                              "OutputResults": 1
                          },
                          {
                              "Name": "tls_mrz_passport",
                              "BaseTextLineSpecificationName": "tls_base",
                              "StringLengthRange": [ 44, 44 ],
                              "OutputResults": 1,
                              "ExpectedGroupsCount": 1,
                              "ConcatResults": 1,
                              "ConcatSeparator": "\\n",
                              "SubGroups": [
                                {
                                  "StringRegExPattern": "(P[A-Z<][A-Z<]{3}[A-Z<]{39}){(44)}",
                                  "StringLengthRange": [ 44, 44 ],
                                  "BaseTextLineSpecificationName": "tls_base"
                                },
                                {
                                  "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[0-9<][0-9]){(44)}",
                                  "StringLengthRange": [ 44, 44 ],
                                  "BaseTextLineSpecificationName": "tls_base"
                                }
                              ]
                          },
                          {
                              "Name": "tls_mrz_id_td2",
                              "BaseTextLineSpecificationName": "tls_base",
                              "StringLengthRange": [ 36, 36 ],
                              "OutputResults": 1,
                              "ExpectedGroupsCount": 1,
                              "ConcatResults": 1,
                              "ConcatSeparator": "\\n",
                              "SubGroups": [
                                  {
                                      "StringRegExPattern": "([ACI][A-Z<][A-Z<]{3}[A-Z<]{31}){(36)}",
                                      "StringLengthRange": [ 36, 36 ],
                                      "BaseTextLineSpecificationName": "tls_base"
                                  },
                                  {
                                      "StringRegExPattern": "([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{8}){(36)}",
                                      "StringLengthRange": [ 36, 36 ],
                                      "BaseTextLineSpecificationName": "tls_base"
                                  }
                              ]
                          },
                          {
                              "Name": "tls_mrz_id_td1",
                              "BaseTextLineSpecificationName": "tls_base",
                              "StringLengthRange": [ 30, 30 ],
                              "OutputResults": 1,
                              "ExpectedGroupsCount": 1,
                              "ConcatResults": 1,
                              "ConcatSeparator": "\\n",
                              "SubGroups": [
                                  {
                                      "StringRegExPattern": "([ACI][A-Z<][A-Z<]{3}[A-Z0-9<]{9}[0-9<][A-Z0-9<]{15}){(30)}",
                                      "StringLengthRange": [ 30, 30 ],
                                      "BaseTextLineSpecificationName": "tls_base"
                                  },
                                  {
                                      "StringRegExPattern": "([0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z<]{3}[A-Z0-9<]{11}[0-9]){(30)}",
                                      "StringLengthRange": [ 30, 30 ],
                                      "BaseTextLineSpecificationName": "tls_base"
                                  },
                                  {
                                      "StringRegExPattern": "([A-Z<]{30}){(30)}",
                                      "StringLengthRange": [ 30, 30 ],
                                      "BaseTextLineSpecificationName": "tls_base"
                                  }
                              ]
                          },
                          {
                              "Name": "tls_base",
                              "CharacterModelName": "MRZ",
                              "CharHeightRange": [ 5, 1000, 1 ],
                              "BinarizationModes": [
                                  {
                                      "BlockSizeX": 30,
                                      "BlockSizeY": 30,
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "EnableFillBinaryVacancy": 0,
                                      "ThresholdCompensation": 15
                                  }
                              ],
                              "ConfusableCharactersCorrection": {
                                  "ConfusableCharacters": [
                                      [ "0", "O" ],
                                      [ "1", "I" ],
                                      [ "5", "S" ]
                                  ],
                                  "FontNameArray": [ "OCR_B" ]
                              }
                          },
                          {
                              "Name": "tls_vin_text",
                              "CharacterModelName": "VIN",
                              "StringRegExPattern": "[0-9A-HJ-NPR-Z]{9}[1-9A-HJ-NPR-TV-Y][0-9A-HJ-NPR-Z]{2}[0-9]{5}",
                              "CharHeightRange": [5, 1000, 1],
                              "StringLengthRange": [17, 17]
                          }
                      ],
                      "LabelRecognizerTaskSettingOptions": [
                          {
                              "Name": "task_recognize_number_letter",
                              "TextLineSpecificationNameArray": [
                                  "tls_number_letter"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_number_letter"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_number_letter"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_number_letter"
                                  }
                              ]
                          },
                          {
                              "Name": "task_recognize_number",
                              "TextLineSpecificationNameArray": [
                                  "tls_number"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_textline_number"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_textline_number"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_textline_number"
                                  }
                              ]
                          },
                          {
                              "Name": "task_recognize_letter",
                              "TextLineSpecificationNameArray": [
                                  "tls_letter"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_letter"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_letter"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_letter"
                                  }
                              ]
                          },
                          {
                              "Name": "task_recognize_uppercase",
                              "TextLineSpecificationNameArray": [
                                  "tls_uppercase"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_uppercase"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_uppercase"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_uppercase"
                                  }
                              ]
                          },
                          {
                              "Name": "task_recognize_number_uppercase",
                              "TextLineSpecificationNameArray": [
                                  "tls_number_uppercase"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_number_uppercase"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_number_uppercase"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_number_uppercase"
                                  }
                              ]
                          },
                          {
                              "Name": "task_passport",
                              "ConfusableCharactersPath": "ConfusableChars.data",
                              "TextLineSpecificationNameArray": ["tls_mrz_passport"],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_mrz"
                                  }
                              ]
                          },
                          {
                              "Name": "task_id",
                              "ConfusableCharactersPath": "ConfusableChars.data",
                              "TextLineSpecificationNameArray": ["tls_mrz_id_td1", "tls_mrz_id_td2"],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_mrz"
                                  }
                              ]
                          },
                          {
                              "Name": "task_passport_and_id",
                              "ConfusableCharactersPath": "ConfusableChars.data",
                              "TextLineSpecificationNameArray": ["tls_mrz_passport", "tls_mrz_id_td1", "tls_mrz_id_td2"],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_mrz"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_mrz"
                                  }
                              ]
                          },
                          {
                              "Name": "task_vin_text",
                              "TextLineSpecificationNameArray": [
                                  "tls_vin_text"
                              ],
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_recognize_vin"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_LOCALIZATION",
                                      "ImageParameterName": "ip_recognize_vin"
                                  },
                                  {
                                      "Section": "ST_TEXT_LINE_RECOGNITION",
                                      "ImageParameterName": "ip_recognize_vin"
                                  }
                              ]
                          }
                      ],
                      "DocumentNormalizerTaskSettingOptions": [
                          {
                              "Name": "task_detect_and_normalize_document",
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_detect_and_normalize"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_DETECTION",
                                      "ImageParameterName": "ip_detect_and_normalize"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_NORMALIZATION",
                                      "ImageParameterName": "ip_detect_and_normalize"
                                  }
                              ]
                          },
                          {
                              "Name": "task_detect_document_boundaries",
                              "TerminateSetting": {
                                  "Section": "ST_DOCUMENT_DETECTION"
                              },
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_detect"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_DETECTION",
                                      "ImageParameterName": "ip_detect"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_NORMALIZATION",
                                      "ImageParameterName": "ip_detect"
                                  }
                              ]
                          },
                          {
                              "Name": "task_normalize_document",
                              "StartSection": "ST_DOCUMENT_NORMALIZATION",
                              "SectionImageParameterArray": [
                                  {
                                      "Section": "ST_REGION_PREDETECTION",
                                      "ImageParameterName": "ip_normalize"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_DETECTION",
                                      "ImageParameterName": "ip_normalize"
                                  },
                                  {
                                      "Section": "ST_DOCUMENT_NORMALIZATION",
                                      "ImageParameterName": "ip_normalize"
                                  }
                              ]
                          }
                      ],
                      "ImageParameterOptions": [
                          {
                              "Name": "ip_read_barcodes",
                              "BaseImageParameterName": "ip_read_single_barcode"
                          },
                          {
                              "Name" : "ip_localize_pdf417",
                              "BinarizationModes" :
                              [
                                  {
                                      "Mode" : "BM_LOCAL_BLOCK"
                                  }
                              ],
                              "GrayscaleEnhancementModes" :
                              [
                                  {
                                      "Mode" : "GEM_GENERAL"
                                  }
                              ]
                          },
                          {
                              "Name" : "ip_decode_pdf417",
                              "ScaleDownThreshold" : 99999
                          },
                          {
                              "Name": "ip_read_barcodes_speed_first",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "UNKNOWN",
                                  "Sensitivity": 3
                              },
                              "IfEraseTextZone": 1,
                              "BinarizationModes": [
                                  {
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "BlockSizeX": 0,
                                      "BlockSizeY": 0,
                                      "EnableFillBinaryVacancy": 0
                                  }
                              ]
                          },
                          {
                              "Name": "ip_read_barcodes_read_rate",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "UNKNOWN",
                                  "Sensitivity": 3
                              },
                              "IfEraseTextZone": 1,
                              "GrayscaleTransformationModes" : [
                                  {
                                      "Mode": "GTM_ORIGINAL"
                                  },
                                  {
                                      "Mode": "GTM_INVERTED"
                                  }
                              ],
                              "ScaleDownThreshold" : 100000
                          },
                          {
                              "Name": "ip_read_single_barcode",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "UNKNOWN",
                                  "Sensitivity": 3
                              },
                              "IfEraseTextZone": 1,
                              "BinarizationModes": [
                                  {
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "BlockSizeX": 39,
                                      "BlockSizeY": 39,
                                      "EnableFillBinaryVacancy": 0
                                  }
                              ]
                          },
                          {
                              "Name": "ip_recognize_number_letter",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      20,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_recognize_textline_number",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      20,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_recognize_letter",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      20,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_recognize_uppercase",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      20,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_recognize_number_uppercase",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      20,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_detect_and_normalize",
                              "BinarizationModes": [
                                  {
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "BlockSizeX": 0,
                                      "BlockSizeY": 0,
                                      "EnableFillBinaryVacancy": 0
                                  }
                              ],
                              "TextDetectionMode": {
                                  "Mode": "TTDM_WORD",
                                  "Direction": "HORIZONTAL",
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_detect",
                              "BinarizationModes": [
                                  {
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "BlockSizeX": 0,
                                      "BlockSizeY": 0,
                                      "EnableFillBinaryVacancy": 0
                                  }
                              ],
                              "TextDetectionMode": {
                                  "Mode": "TTDM_WORD",
                                  "Direction": "HORIZONTAL",
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_normalize",
                              "BinarizationModes": [
                                  {
                                      "Mode": "BM_LOCAL_BLOCK",
                                      "BlockSizeX": 0,
                                      "BlockSizeY": 0,
                                      "EnableFillBinaryVacancy": 0
                                  }
                              ],
                              "TextDetectionMode": {
                                  "Mode": "TTDM_WORD",
                                  "Direction": "HORIZONTAL",
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name": "ip_mrz",
                              "TextureDetectionModes": [
                                  {
                                      "Mode": "TDM_GENERAL_WIDTH_CONCENTRATION",
                                      "Sensitivity": 8
                                  }
                              ],
                              "BinarizationModes": [
                                  {
                                      "EnableFillBinaryVacancy": 0,
                                      "ThresholdCompensation": 21,
                                      "Mode": "BM_LOCAL_BLOCK"
                                  }
                              ],
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "CharHeightRange": [ 5, 1000, 1 ],
                                  "Direction": "HORIZONTAL",
                                  "Sensitivity": 7
                              }
                          },
                          {
                              "Name" : "ip_localize_vin",
                              "BinarizationModes" :
                              [
                                  {
                                      "Mode" : "BM_LOCAL_BLOCK",
                                      "MorphOperation" : "Erode"
                                  }
                              ],
                              "GrayscaleEnhancementModes" :
                              [
                                  {
                                      "Mode" : "GEM_GENERAL",
                                      "Sensitivity" : 5,
                                      "SharpenBlockSizeX" : 3,
                                      "SharpenBlockSizeY" : 3,
                                      "SmoothBlockSizeX" : 3,
                                      "SmoothBlockSizeY" : 3
                                  }
                              ],
                              "GrayscaleTransformationModes" :
                              [
                                  {
                                      "Mode" : "GTM_ORIGINAL"
                                  },
                                  {
                                      "Mode" : "GTM_INVERTED"
                                  }
                              ]
                          },
                          {
                              "Name" : "ip_decode_vin",
                              "GrayscaleTransformationModes" :
                              [
                                  {
                                      "Mode" : "GTM_ORIGINAL"
                                  }
                              ],
                              "ScaleDownThreshold" : 99999
                          },
                          {
                              "Name": "ip_recognize_vin",
                              "TextDetectionMode": {
                                  "Mode": "TTDM_LINE",
                                  "Direction": "HORIZONTAL",
                                  "CharHeightRange": [
                                      5,
                                      1000,
                                      1
                                  ],
                                  "Sensitivity": 7
                              },
                              "GrayscaleTransformationModes": [
                                  {
                                      "Mode": "GTM_ORIGINAL"
                                  },
                                  {
                                      "Mode": "GTM_INVERTED"
                                  }
                              ],
                              "BinarizationModes" :
                              [
                                  {
                                      "EnableFillBinaryVacancy" : 1,
                                      "Mode" : "BM_LOCAL_BLOCK"
                                  }
                              ]
                          }
                      ],
                      "CharacterModelOptions": [
                          {
                              "Name" : "Number"
                          },
                          {
                              "Name" : "Letter"
                          },
                          {
                              "Name" : "Uppercase"
                          },
                          {
                              "Name" : "NumberUppercase"
                          },
                          {
                              "Name" : "NumberLetter"
                          },
                          {
                              "Name": "MRZ"
                          },
                          {
                              "Name": "VIN"
                          }
                      ],
                      "SemanticProcessingOptions": [
                          {
                              "Name": "sp_passport_and_id",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                  "roi_passport_and_id"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_passport_and_id"
                              ]
                          },
                          {
                              "Name": "sp_passport",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                  "roi_passport"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_passport"
                              ]
                          },
                          {
                              "Name": "sp_id",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                  "roi_id"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_id"
                              ]
                          },
                          {
                              "Name": "sp_pdf_417",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                          "roi_pdf_417"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_pdf_417"
                              ]
                          },
                          {
                              "Name": "sp_vin_barcode",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                          "roi_vin_barcode"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_vin_barcode"
                              ]
                          },
                          {
                              "Name": "sp_vin_text",
                              "ReferenceObjectFilter": {
                                  "ReferenceTargetROIDefNameArray": [
                                      "roi_vin_text"
                                  ]
                              },
                              "TaskSettingNameArray": [
                                  "parse_vin_text"
                              ]
                          }
                      ],
                      "CodeParserTaskSettingOptions": [
                          {
                              "Name": "parse_passport",
                              "CodeSpecifications": [ "MRTD_TD3_PASSPORT" ]
                          },
                          {
                              "Name": "parse_id",
                              "CodeSpecifications": [ "MRTD_TD1_ID", "MRTD_TD2_ID" ]
                          },
                          {
                              "Name": "parse_passport_and_id",
                              "CodeSpecifications": [ "MRTD_TD3_PASSPORT", "MRTD_TD1_ID", "MRTD_TD2_ID" ]
                          },
                          {
                              "Name": "parse_pdf_417",
                              "CodeSpecifications": ["AAMVA_DL_ID","AAMVA_DL_ID_WITH_MAG_STRIPE","SOUTH_AFRICA_DL"]
                          },
                          {
                              "Name": "parse_vin_barcode",
                              "CodeSpecifications": ["VIN"]
                          },
                          {
                              "Name": "parse_vin_text",
                              "CodeSpecifications": ["VIN"]
                          }
                      ]
                  }
                  """;
        try? VisionCameraDynamsoftLabelRecognizer.router.initSettings(template)
    }
    
    @objc(initLicense:withResolver:withRejecter:)
    func initLicense(license: String, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        print("init license")
        licenseResolveBlock = resolve
        licenseRejectBlock = reject
        LicenseManager.initLicense(license, verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: (any Error)?) {
        var msg:String? = nil
        if(error != nil)
        {
            let err = error as NSError?
            msg = err!.userInfo[NSUnderlyingErrorKey] as? String
            print("Server license verify failed: ", msg ?? "")
        }
        licenseResolveBlock(isSuccess);
    }
    
    @objc(decodeBase64:template:withResolver:withRejecter:)
    func decodeBase64(base64: String,template: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let image = Utils.convertBase64ToImage(base64)
        var scanResult:[String:Any] = [:]
        var returned_results: [Any] = []
        print("orientation")
        print(image?.imageOrientation.rawValue)
        if image != nil {
            let capturedResult = VisionCameraDynamsoftLabelRecognizer.router.captureFromImage(image!, templateName: template)
            let linesResult = capturedResult.recognizedTextLinesResult;
            if linesResult != nil {
                returned_results.append(Utils.wrapLinesResult(result:linesResult!))
            }
        }
        scanResult["results"] = returned_results
        resolve(scanResult)
    }
    
    @objc(initRuntimeSettings:withResolver:withRejecter:)
    func initRuntimeSettings(template: String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        do {
            try VisionCameraDynamsoftLabelRecognizer.router.initSettings(template)
            resolve(true)
        }catch {
            print("Unexpected error: \(error).")
            resolve(false)
        }
    }
}
