package com.visioncameradynamsoftdocumentnormalizer;

import android.graphics.Point;
import android.util.Log;

import com.dynamsoft.core.Quadrilateral;
import com.dynamsoft.ddn.DetectedQuadResult;
import com.facebook.react.bridge.NativeMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Utils {
    public static Point[] convertPoints(ReadableArray pointsArray){
        Point[] points = new Point[4];
        for (int i = 0; i < pointsArray.size(); i++) {
            ReadableMap pointMap = pointsArray.getMap(i);
            Point point = new Point();
            point.x = pointMap.getInt("x");
            point.y = pointMap.getInt("y");
            points[i] = point;
        }
        return points;
    }

    public static Map<String, Object> convertNativeMap(ReadableNativeMap map){
        Map<String, Object> hashMap = new HashMap<>();
        ReadableMapKeySetIterator iterator = map.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            Log.d("DDN",key);
            ReadableType type = map.getType(key);
            if (type == ReadableType.Map) {
                WritableNativeMap converted = (WritableNativeMap) map.getMap(key);
                hashMap.put(key,convertNativeMap(converted));
            }else if (type == ReadableType.Array) {
                ReadableArray array = map.getArray(key);
                List<Object> arrayConverted = new ArrayList<>();
                for (Object item:array.toArrayList()) {
                    if (item instanceof ReadableNativeMap) {
                        arrayConverted.add(convertNativeMap((WritableNativeMap) item));
                    }else{
                        arrayConverted.add(item);
                    }
                }
                hashMap.put(key,arrayConverted);
            }else if (type == ReadableType.Boolean) {
                hashMap.put(key,map.getBoolean(key));
            }else if (type == ReadableType.Number) {
                hashMap.put(key,map.getInt(key));
            }else if (type == ReadableType.String) {
                hashMap.put(key,map.getString(key));
            }
        }
        return hashMap;
    }

    public static WritableNativeMap getMapFromDetectedQuadResult(DetectedQuadResult result){
        WritableNativeMap map = new WritableNativeMap();
        map.putInt("confidenceAsDocumentBoundary",result.confidenceAsDocumentBoundary);
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
