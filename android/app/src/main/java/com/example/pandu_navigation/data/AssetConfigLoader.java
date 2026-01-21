package com.example.pandu_navigation.data;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

public class AssetConfigLoader {
    private static final String TAG = "PanduConfig";
    private final Context context;
    private final Gson gson;
    private final NavigationDao dao;

    public AssetConfigLoader(Context context, NavigationDao dao) {
        this.context = context;
        this.dao = dao;
        this.gson = new Gson();
    }

    public void loadInitialData() {
        new Thread(() -> {
            if (dao.getTrailCount() > 0) {
                Log.d(TAG, "Database already seeded. Skipping asset load.");
                return;
            }
            seedDatabase();
        }).start();
    }

    private void seedDatabase() {
        try {
            Log.d(TAG, "Seeding database from assets...");
            AssetManager assets = context.getAssets();
            // Flutter assets are typically under "flutter_assets"
            String baseAssetPath = "flutter_assets/";
            String configPath = baseAssetPath + "assets/config/mountains.json";

            InputStream is = assets.open(configPath);
            AppConfig config = gson.fromJson(new InputStreamReader(is), AppConfig.class);
            is.close();

            for (MountainConfig mountain : config.mountains) {
                Log.d(TAG, "Processing mountain: " + mountain.name);

                // 1. Process Tracks
                if (mountain.tracks != null) {
                    for (TrackConfig track : mountain.tracks) {
                        String trackAssetPath = baseAssetPath + track.file;
                        Log.d(TAG, "Parsing track: " + track.name + " from " + trackAssetPath);
                        List<TrailEntity> trails = parseGpxTracks(trackAssetPath, mountain.id, track.name);
                        for (TrailEntity trail : trails) {
                            dao.insertTrail(trail);
                        }
                    }
                }

                // 2. Process POIs
                if (mountain.poi_file != null && !mountain.poi_file.isEmpty()) {
                    String poiAssetPath = baseAssetPath + mountain.poi_file;
                    Log.d(TAG, "Parsing POIs from " + poiAssetPath);
                    List<PoiEntity> pois = parseGpxPois(poiAssetPath, mountain.id);
                    for (PoiEntity poi : pois) {
                        dao.insertPoi(poi);
                    }
                }
                // 3. Insert Mountain
                MountainEntity mEntity = new MountainEntity(
                        mountain.id,
                        mountain.name,
                        mountain.description,
                        mountain.region,
                        mountain.lat,
                        mountain.lng,
                        mountain.altitude,
                        false, // isDownloaded default
                        false, // isOfflineAvailable default
                        null, // localMapPath
                        "{}" // boundaryJson
                );
                dao.insertMountain(mEntity);
            }

        } catch (Exception e) {
            Log.e(TAG, "Error seeding database: ", e);
        }
    }

    private List<TrailEntity> parseGpxTracks(String assetPath, String mountainId, String trackName) {
        List<TrailEntity> trails = new ArrayList<>();
        try {
            InputStream is = context.getAssets().open(assetPath);
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(is);
            doc.getDocumentElement().normalize();

            NodeList trkList = doc.getElementsByTagName("trk");
            for (int i = 0; i < trkList.getLength(); i++) {
                Element trk = (Element) trkList.item(i);
                // Use trackName from JSON if provided, else fallback to GPX name
                String name = trackName != null ? trackName : getTagValue("name", trk);

                NodeList trkpts = trk.getElementsByTagName("trkpt");
                List<List<Double>> coordinates = new ArrayList<>();

                double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

                for (int j = 0; j < trkpts.getLength(); j++) {
                    Element pt = (Element) trkpts.item(j);
                    double lat = Double.parseDouble(pt.getAttribute("lat"));
                    double lon = Double.parseDouble(pt.getAttribute("lon"));
                    double ele = 0;
                    if (pt.getElementsByTagName("ele").getLength() > 0) {
                        try {
                            ele = Double.parseDouble(getTagValue("ele", pt));
                        } catch (NumberFormatException e) {
                            ele = 0;
                        }
                    }

                    List<Double> coord = new ArrayList<>();
                    coord.add(lon);
                    coord.add(lat);
                    coord.add(ele);
                    coordinates.add(coord);

                    if (lat < minLat)
                        minLat = lat;
                    if (lat > maxLat)
                        maxLat = lat;
                    if (lon < minLng)
                        minLng = lon;
                    if (lon > maxLng)
                        maxLng = lon;
                }

                String geometryJson = gson.toJson(coordinates);
                // Create deterministic ID based on mountain + track name
                String id = mountainId + "_" + name.toLowerCase().replaceAll("[^a-z0-9]", "_");

                TrailEntity entity = new TrailEntity(
                        id, mountainId, name, geometryJson,
                        3, 0, 0, minLat, maxLat, minLng, maxLng);
                trails.add(entity);
            }
            is.close();
        } catch (Exception e) {
            Log.e(TAG, "Error parsing Track GPX " + assetPath + ": ", e);
        }
        return trails;
    }

    private List<PoiEntity> parseGpxPois(String assetPath, String mountainId) {
        List<PoiEntity> pois = new ArrayList<>();
        try {
            InputStream is = context.getAssets().open(assetPath);
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(is);
            doc.getDocumentElement().normalize();

            NodeList wptList = doc.getElementsByTagName("wpt");
            for (int i = 0; i < wptList.getLength(); i++) {
                Element wpt = (Element) wptList.item(i);
                double lat = Double.parseDouble(wpt.getAttribute("lat"));
                double lon = Double.parseDouble(wpt.getAttribute("lon"));

                String name = getTagValue("name", wpt);
                String type = getTagValue("type", wpt).toLowerCase(); // Normalize type
                String eleStr = getTagValue("ele", wpt);
                double ele = eleStr.isEmpty() ? 0 : Double.parseDouble(eleStr);

                String id = mountainId + "_poi_" + i + "_" + System.currentTimeMillis(); // Simple unique ID

                PoiEntity entity = new PoiEntity(id, mountainId, name, type, lat, lon, ele);
                pois.add(entity);
            }
            is.close();
        } catch (Exception e) {
            Log.e(TAG, "Error parsing POI GPX " + assetPath + ": ", e);
        }
        return pois;
    }

    private String getTagValue(String tag, Element element) {
        NodeList nl = element.getElementsByTagName(tag);
        if (nl != null && nl.getLength() > 0) {
            NodeList childNodes = nl.item(0).getChildNodes();
            if (childNodes.getLength() > 0) {
                return childNodes.item(0).getNodeValue();
            }
        }
        return "";
    }

    // Config POJOs
    private static class AppConfig {
        List<MountainConfig> mountains;
    }

    private static class MountainConfig {
        String id;
        String name;
        String region;
        String description;
        double lat;
        double lng;
        double altitude;
        List<TrackConfig> tracks;
        String poi_file;
    }

    private static class TrackConfig {
        String name;
        String file;
    }
}
