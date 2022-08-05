package com.visioncameradynamsoftlabelrecognizer;

import com.dynamsoft.core.Point;
import com.dynamsoft.core.Quadrilateral;
import com.dynamsoft.dlr.DLRCharacterResult;
import com.dynamsoft.dlr.DLRLineResult;
import com.dynamsoft.dlr.DLRResult;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

public class Utils {
    public static WritableNativeMap getMapFromDLRResult(DLRResult result){
        WritableNativeMap map = new WritableNativeMap();
        map.putString("referenceRegionName",result.refereneceRegionName);
        map.putString("textAreaName",result.textAreaName);
        map.putInt("confidence",result.confidence);
        map.putInt("pageNumber",result.pageNumber);
        WritableNativeArray lineResults = new WritableNativeArray();
        for (DLRLineResult lineResult:result.lineResults) {
            lineResults.pushMap(getMapFromDLRLineResult(lineResult));
        }
        map.putArray("lineResults",lineResults);
        map.putMap("location",getMapFromLocation(result.location));
        return map;
    }

    private static WritableNativeMap getMapFromDLRLineResult(DLRLineResult result){
        WritableNativeMap map = new WritableNativeMap();
        map.putString("lineSpecificationName",result.lineSpecificationName);
        map.putString("text",result.text);
        map.putString("characterModelName",result.characterModelName);
        map.putMap("location",getMapFromLocation(result.location));
        map.putInt("confidence",result.confidence);
        WritableNativeArray characterResults = new WritableNativeArray();
        for (DLRCharacterResult characterResult:result.characterResults) {
            characterResults.pushMap(getMapFromDLRCharacterResult(characterResult));
        }
        map.putArray("characterResults",characterResults);
        return map;
    }

    private static WritableNativeMap getMapFromDLRCharacterResult(DLRCharacterResult result){
        WritableNativeMap map = new WritableNativeMap();
        map.putString("characterH",String.valueOf(result.characterH));
        map.putString("characterM",String.valueOf(result.characterM));
        map.putString("characterL",String.valueOf(result.characterL));
        map.putInt("characterHConfidence",result.characterHConfidence);
        map.putInt("characterMConfidence",result.characterMConfidence);
        map.putInt("characterLConfidence",result.characterLConfidence);
        map.putMap("location",getMapFromLocation(result.location));
        return map;
    }

    private static WritableNativeMap getMapFromLocation(Quadrilateral location){
        WritableNativeMap map = new WritableNativeMap();
        WritableNativeArray points = new WritableNativeArray();
        for (Point point: location.points) {
            WritableNativeMap pointAsMap = new WritableNativeMap();
            pointAsMap.putInt("x",point.x);
            pointAsMap.putInt("y",point.y);
            points.pushMap(pointAsMap);
        }
        map.putArray("points",points);
        return map;
    }
}
