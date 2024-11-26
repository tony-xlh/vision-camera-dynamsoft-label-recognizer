package com.visioncameradynamsoftlabelrecognizer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.util.Base64;

import com.dynamsoft.core.basic_structures.Quadrilateral;
import com.dynamsoft.dlr.CharacterResult;
import com.dynamsoft.dlr.RecognizedTextLinesResult;
import com.dynamsoft.dlr.TextLineResultItem;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.io.ByteArrayOutputStream;

public class Utils {

    public static Bitmap base642Bitmap(String base64) {
        byte[] decode = Base64.decode(base64,Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decode,0,decode.length);
    }

    public static String bitmap2Base64(Bitmap bitmap) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        return Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);
    }

    public static WritableNativeMap getMapFromLinesResult(RecognizedTextLinesResult linesResult){
        WritableNativeMap map = new WritableNativeMap();
        WritableNativeArray lineResults = new WritableNativeArray();
        for (TextLineResultItem lineResult:linesResult.getItems()) {
            lineResults.pushMap(getMapFromDLRLineResult(lineResult));
        }
        map.putArray("lineResults",lineResults);
        return map;
    }

    private static WritableNativeMap getMapFromDLRLineResult(TextLineResultItem result){
        WritableNativeMap map = new WritableNativeMap();
        map.putString("lineSpecificationName",result.getSpecificationName());
        map.putString("text",result.getText());
        map.putMap("location",getMapFromLocation(result.getLocation()));
        map.putInt("confidence",result.getConfidence());
        WritableNativeArray characterResults = new WritableNativeArray();
        for (CharacterResult characterResult:result.getCharacterResults()) {
            characterResults.pushMap(getMapFromDLRCharacterResult(characterResult));
        }
        map.putArray("characterResults",characterResults);
        return map;
    }

    private static WritableNativeMap getMapFromDLRCharacterResult(CharacterResult result){
        WritableNativeMap map = new WritableNativeMap();
        map.putString("characterH",String.valueOf(result.getCharacterH()));
        map.putString("characterM",String.valueOf(result.getCharacterM()));
        map.putString("characterL",String.valueOf(result.getCharacterL()));
        map.putInt("characterHConfidence",result.getCharacterHConfidence());
        map.putInt("characterMConfidence",result.getCharacterMConfidence());
        map.putInt("characterLConfidence",result.getCharacterLConfidence());
        map.putMap("location",getMapFromLocation(result.getLocation()));
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
