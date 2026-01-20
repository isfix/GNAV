package com.example.pandu_navigation.logic;

import android.util.Xml;

import com.example.pandu_navigation.data.TrailEntity;

import org.json.JSONArray;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class GpxImporter {

    public static List<TrailEntity> parse(String filePath, String mountainId)
            throws IOException, XmlPullParserException {
        List<TrailEntity> trails = new ArrayList<>();
        InputStream in = new FileInputStream(filePath);

        try {
            XmlPullParser parser = Xml.newPullParser();
            parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
            parser.setInput(in, null);
            parser.nextTag();

            readGpx(parser, trails, mountainId);
        } finally {
            in.close();
        }

        return trails;
    }

    private static void readGpx(XmlPullParser parser, List<TrailEntity> trails, String mountainId)
            throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, null, "gpx");
        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            // We ignore top-level metadata for simplicity, strictly matching prompt
            // Requirements
            if (name.equals("trk")) {
                trails.add(readTrk(parser, mountainId));
            } else {
                skip(parser);
            }
        }
    }

    private static TrailEntity readTrk(XmlPullParser parser, String mountainId)
            throws IOException, XmlPullParserException {
        parser.require(XmlPullParser.START_TAG, null, "trk");
        TrailEntity trail = new TrailEntity();
        trail.mountainId = mountainId;
        trail.isOfficial = true; // Default

        String trailName = "Unknown Trail";
        JSONArray allPoints = new JSONArray();

        double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
        double startLat = 0, startLng = 0;
        boolean firstPoint = true;

        while (parser.next() != XmlPullParser.END_TAG) {
            if (parser.getEventType() != XmlPullParser.START_TAG) {
                continue;
            }
            String name = parser.getName();
            if (name.equals("name")) {
                trailName = readText(parser);
            } else if (name.equals("trkseg")) {
                // Read Segment
                while (parser.next() != XmlPullParser.END_TAG) {
                    if (parser.getEventType() != XmlPullParser.START_TAG)
                        continue;
                    if (parser.getName().equals("trkpt")) {
                        double lat = Double.parseDouble(parser.getAttributeValue(null, "lat"));
                        double lon = Double.parseDouble(parser.getAttributeValue(null, "lon"));

                        // Update Bounds
                        if (lat < minLat)
                            minLat = lat;
                        if (lat > maxLat)
                            maxLat = lat;
                        if (lon < minLng)
                            minLng = lon;
                        if (lon > maxLng)
                            maxLng = lon;

                        if (firstPoint) {
                            startLat = lat;
                            startLng = lon;
                            firstPoint = false;
                        }

                        try {
                            JSONObject p = new JSONObject();
                            p.put("lat", lat);
                            p.put("lng", lon);
                            // Read ele if needed, but skipping for brevity/speed unless requested
                            allPoints.put(p);
                        } catch (Exception e) {
                        }

                        // Skip inner tags of trkpt (ele, time, etc)
                        // We are not parsing them fully to save parse time? Actually review critiqued
                        // "parsed every time".
                        // Storing just lat/lng is enough for deviation.
                        skipInner(parser);

                    } else {
                        skip(parser);
                    }
                }
            } else {
                skip(parser);
            }
        }

        trail.id = mountainId + "_" + trailName.replaceAll("\\s+", "_").toLowerCase() + "_"
                + System.currentTimeMillis();
        trail.name = trailName;
        trail.geometryJson = allPoints.toString();
        trail.minLat = minLat;
        trail.maxLat = maxLat;
        trail.minLng = minLng;
        trail.maxLng = maxLng;
        trail.startLat = startLat;
        trail.startLng = startLng;
        // Defaults
        trail.distance = 0;
        trail.elevationGain = 0;
        trail.difficulty = 1;

        return trail;
    }

    // Skip loop for simple tags
    private static void skipInner(XmlPullParser parser) throws XmlPullParserException, IOException {
        if (parser.isEmptyElementTag()) {
            parser.next();
            return;
        }
        int depth = 1;
        while (depth != 0) {
            switch (parser.next()) {
                case XmlPullParser.END_TAG:
                    depth--;
                    break;
                case XmlPullParser.START_TAG:
                    depth++;
                    break;
            }
        }
    }

    private static String readText(XmlPullParser parser) throws IOException, XmlPullParserException {
        String result = "";
        if (parser.next() == XmlPullParser.TEXT) {
            result = parser.getText();
            parser.nextTag();
        }
        return result;
    }

    private static void skip(XmlPullParser parser) throws XmlPullParserException, IOException {
        if (parser.getEventType() != XmlPullParser.START_TAG) {
            throw new IllegalStateException();
        }
        int depth = 1;
        while (depth != 0) {
            switch (parser.next()) {
                case XmlPullParser.END_TAG:
                    depth--;
                    break;
                case XmlPullParser.START_TAG:
                    depth++;
                    break;
            }
        }
    }
}
