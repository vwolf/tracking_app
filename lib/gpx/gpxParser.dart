/// Parser for *.gpx xml files
///
/// xml schemas
/// <gpx xmlns="http://www.topografix.com/GPX/1/1"
/// xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
/// xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
/// points in <trk><trkseg><trkpt> section (trkseg is optional)
///
/// <gpx xmlns="http://www.topografix.com/GPX/1/1"
/// xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"
/// xmlns:rcxx="http://www.routeconverter.de/xmlschemas/RouteCatalogExtensions/1.0"
/// point in wpt items
///
/// ToDo parse only tour meta data for new tour
///
import 'package:xml/xml.dart' as xml;
import 'package:latlong/latlong.dart';
import '../database/models/trackCoord.dart';


class GpxParser {
  String gpxData;

  GpxParser(this.gpxData);

  GpxFileData gpxFileData = new GpxFileData();

  /// Start parsing
  parseData() {
    print('start parseData');
    var document = xml.parse(gpxData);
    GPXDocumentType documentType = GPXDocumentType.xsi;

    // what xml schema
    var root = document.findElements('gpx');
    root.forEach((xml.XmlElement f) {
      if (f.getAttribute("xmlns:gpxx") != null) {
        documentType = GPXDocumentType.gpxx;
      }
    });

    // first get track name, try <metadata><name>
    String trackName = "";
    Iterable<xml.XmlElement>metadataItems = document.findAllElements('metadata');
    metadataItems.map((xml.XmlElement metadataItem) {
      trackName = getValue(metadataItem.findElements('name'));
          if (trackName == null) {
            trackName = getValue(metadataItem.findElements('desc'));
          }
    }).toList(growable: true);

    // add to tourGpxData
    Iterable<xml.XmlElement>items = document.findAllElements('trk');
    items.map((xml.XmlElement item) {
      // no name tag in metadata try in <trk><name>
      var name = getValue(item.findElements('name'));
      print(name);
      if ( trackName == "") {
        trackName = name;
      }
      gpxFileData.trackSeqName = name;
      // sometimes in <cmt> is a printable version tourname
    }).toList(growable: true);

    // list of gps coordinates
    List<GpxCoords>trkList = List();
    List<LatLng>pointsList = List();
    // get the coordinates for points
    // ToDo check for elevation values
    if (documentType == GPXDocumentType.gpxx) {
      Iterable<xml.XmlElement>wpt = document.findAllElements('wpt');
      trkList = parseGPXX(wpt);
    } else {
      Iterable<xml.XmlElement>trkseg = document.findAllElements('trkseg');
      trkList = parseGPX(trkseg);
    }

    gpxFileData.trackName = trackName != null ? trackName : "?";
    gpxFileData.gpxCoords = trkList;

    return gpxFileData;
  }

  List<GpxCoords> parseGPX(Iterable<xml.XmlElement> trkseg) {
    List<GpxCoords>trkList = List();
    trkseg.map((xml.XmlElement trkpt) {
      Iterable<xml.XmlElement> pts = trkpt.findElements('trkpt');
      pts.forEach((xml.XmlElement f) {
        // <ele> element?
        var ele = getValue(f.findElements('ele'));
        ele = ele == null ? "0.0" : ele;
        trkList.add(GpxCoords(
            double.parse(f.getAttribute('lat')),
            double.parse(f.getAttribute('lon')),
            double.parse(ele)
        ));
      });
    }).toList(growable: true);

    return trkList;
  }

  List<GpxCoords> parseGPXX(Iterable<xml.XmlElement> wpt) {
    List<GpxCoords>wpttrkList = List();
    wpt.forEach((xml.XmlElement f) {
      var ele = getValue(f.findElements('ele'));
      ele = ele == null ? "0.0": ele;
      wpttrkList.add(GpxCoords(
          double.parse(f.getAttribute('lat')),
          double.parse(f.getAttribute('lon')),
          double.parse(ele)
      ));
    });
    return wpttrkList;
  }


  /// extract node text
  String getValue(Iterable<xml.XmlElement> items) {
    var textValue;
    items.map((xml.XmlElement node) {
      textValue = node.text;
    }).toList(growable: true);
    return textValue;
  }
}



/// GpxFileTrack holds the parsed data from a *.gpx file
class GpxFileData {
  String trackName = "";
  String trackSeqName = "";
  LatLng defaultCoord = LatLng(53.00, 13.10);
  List<GpxCoords> gpxCoords = [];
  List<LatLng> gpxLatlng = [];

  /// convert GpxCoords to LatLng
  coordsToLatlng() {
    gpxLatlng = [];
    gpxCoords.forEach((GpxCoords f) {
      gpxLatlng.add(new LatLng(f.lat, f.lon));
    });
  }
}


class GpxCoords {
  double lat;
  double lon;
  double ele;

  GpxCoords(this.lat, this.lon, this.ele);
}

enum GPXDocumentType {
  xsi,
  gpxx
}

class TrackGpxData {

  TrackGpxData();
}