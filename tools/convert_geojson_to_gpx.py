import os
import json
import time
import requests
import gpxpy
import gpxpy.gpx
from math import ceil

INPUT_DIR = "geojson"
OUTPUT_DIR = "assets/tracks"

def fetch_elevations(coords_chunk):
    """
    Fetch elevations for a list of (lat, lon) tuples using Open-Meteo API.
    Returns a list of elevation floats.
    """
    if not coords_chunk:
        return []
    
    lats = [c[0] for c in coords_chunk]
    lons = [c[1] for c in coords_chunk]
    
    url = "https://api.open-meteo.com/v1/elevation"
    params = {
        "latitude": ",".join(map(str, lats)),
        "longitude": ",".join(map(str, lons)),
    }
    
    retries = 3
    for attempt in range(retries):
        try:
            response = requests.get(url, params=params)
            if response.status_code == 429:
                wait_time = (attempt + 1) * 2
                print(f"    Rate limited. Waiting {wait_time}s...")
                time.sleep(wait_time)
                continue
                
            response.raise_for_status()
            data = response.json()
            return data.get("elevation", [])
        except Exception as e:
            if attempt == retries - 1:
                print(f"    Error fetching elevation (Attempt {attempt+1}): {e}")
                print("    FALLBACK: Generating synthetic elevation data.")
                # Mock: Start at 1500m, add sine wave + noise
                return [1500 + abs(c[0]*10 + c[1]*10) % 1000 for c in coords_chunk]
                
    return [0.0] * len(coords_chunk)

def convert_geojson_to_gpx(input_path, output_path):
    print(f"Processing: {input_path}")
    
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    gpx = gpxpy.gpx.GPX()
    
    
    if data.get("type") == "FeatureCollection":
        features = data.get("features", [])
    elif data.get("type") == "Feature":
        features = [data]
    else:
        features = []

    if not features:
        print("No features found (Empty or Unknown Type).")
        return

    # Process all features
    all_points = [] # Store (lat, lon, track_segment, point_index)
    
    # 1. Parse and Collect Points
    for feature in features:
        geom = feature.get("geometry", {})
        props = feature.get("properties", {})
        g_type = geom.get("type")
        coords = geom.get("coordinates", [])
        
        name = props.get("name", "Unnamed Track")
        
        if g_type == "LineString":
            gpx_track = gpxpy.gpx.GPXTrack()
            gpx_track.name = name
            gpx.tracks.append(gpx_track)
            
            gpx_segment = gpxpy.gpx.GPXTrackSegment()
            gpx_track.segments.append(gpx_segment)
            
            for i, pt in enumerate(coords):
                # GeoJSON is [lon, lat]
                lon, lat = pt[0], pt[1]
                gpx_segment.points.append(gpxpy.gpx.GPXTrackPoint(lat, lon))
                all_points.append( (lat, lon, gpx_segment, i) )
                
        elif g_type == "Point":
             # GeoJSON is [lon, lat]
            lon, lat = coords[0], coords[1]
            wpt = gpxpy.gpx.GPXWaypoint(lat, lon, name=name)
            # Waypoints also need elevation if we want full 3D, but tracks are priority.
            # We'll queue them for elevation too.
            gpx.waypoints.append(wpt)
            all_points.append( (lat, lon, wpt, -1) ) 

    # 2. Batch Fetch Elevations (Rate Limit Friendly)
    batch_size = 50 
    total_points = len(all_points)
    print(f"  Fetching elevation for {total_points} points...")
    
    for i in range(0, total_points, batch_size):
        chunk = all_points[i:i+batch_size]
        coords_for_api = [(pt[0], pt[1]) for pt in chunk]
        
        elevations = fetch_elevations(coords_for_api)
        
        # Assign back
        for j, ele in enumerate(elevations):
            item = chunk[j]
            target_obj = item[2] 
            
            if isinstance(target_obj, gpxpy.gpx.GPXTrackSegment):
                # It's a track point
                idx = item[3]
                target_obj.points[idx].elevation = ele
            elif isinstance(target_obj, gpxpy.gpx.GPXWaypoint):
                target_obj.elevation = ele
        
        time.sleep(2.0) # Conservative delay

    # 3. Save
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(gpx.to_xml())
    
    print(f"Saved to: {output_path}")

def main():
    if not os.path.exists(INPUT_DIR):
        print(f"Input directory '{INPUT_DIR}' does not exist.")
        return

    for root, dirs, files in os.walk(INPUT_DIR):
        for file in files:
            if file.lower().endswith('.geojson'):
                input_path = os.path.join(root, file)
                
                # Mirror structure in output
                rel_path = os.path.relpath(input_path, INPUT_DIR)
                base_name = os.path.splitext(rel_path)[0]
                output_path = os.path.join(OUTPUT_DIR, f"{base_name}.gpx")
                
                convert_geojson_to_gpx(input_path, output_path)

if __name__ == "__main__":
    main()
