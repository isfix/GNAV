package com.example.gnav.data.source

import android.content.Context
import com.example.gnav.domain.model.Coord
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.serialization.json.Json
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.InputStream
import javax.inject.Inject

class AssetDataSource @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val json = Json { ignoreUnknownKeys = true }

    fun loadMountainsConfig(): MountainsConfigDto {
        val inputStream = context.assets.open("config/mountains.json")
        val jsonString = inputStream.bufferedReader().use { it.readText() }
        return json.decodeFromString(jsonString)
    }

    fun parseGpx(filename: String): List<Coord> {
        val path = "tracks/$filename"
        val coords = mutableListOf<Coord>()
        try {
            val inputStream = context.assets.open(path)
            val ipf = XmlPullParserFactory.newInstance()
            ipf.isNamespaceAware = false
            val parser = ipf.newPullParser()
            parser.setInput(inputStream, null)

            var eventType = parser.eventType
            var lat = 0.0
            var lon = 0.0
            var ele = 0.0

            while (eventType != XmlPullParser.END_DOCUMENT) {
                if (eventType == XmlPullParser.START_TAG && parser.name == "trkpt") {
                    lat = parser.getAttributeValue(null, "lat")?.toDoubleOrNull() ?: 0.0
                    lon = parser.getAttributeValue(null, "lon")?.toDoubleOrNull() ?: 0.0
                } else if (eventType == XmlPullParser.START_TAG && parser.name == "ele") {
                    parser.next()
                    ele = parser.text?.toDoubleOrNull() ?: 0.0
                } else if (eventType == XmlPullParser.END_TAG && parser.name == "trkpt") {
                    coords.add(Coord(lat, lon, ele))
                }
                eventType = parser.next()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return coords
    }
}
