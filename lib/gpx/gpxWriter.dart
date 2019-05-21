import 'package:xml/xml.dart' as xml;
import '../database/models/trackCoord.dart';

/// Write coordinates to *.gpx file (xml)
class GpxWriter {

  GpxWriter();

  var builder = new xml.XmlBuilder();
  var gpx;


  String buildGpx( List<TrackCoord> coordsList ) {
    builder.processing('xml', 'version="1.0" encoding="utf-8"');

    builder.element('gpx', nest: () {
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      builder.attribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
    });

    builder.element('trk', nest: () {
      builder.element('name', nest: () {
        builder.text('Gransee');
      });
      builder.element('desc', nest: () {
        builder.text('Description');
      });
      builder.element('trkseg', nest: () {
        for ( TrackCoord coord in coordsList) {
          addTrkpt(coord);
        }
      });
    });
    xml.XmlNode gpx = builder.build();
    String retxml = gpx.toXmlString(pretty: true, indent: '\t');
    // print(retxml);
    return retxml;
  }


  addTrkpt(TrackCoord coord) {
    builder.element('trkpt', nest: () {
      builder.attribute('lat', coord.latitude);
      builder.attribute('lon', coord.longitude);
      builder.element('ele', nest: () {
        builder.text(coord.altitude == null ? 0.0 : coord.altitude);
      });
    });
  }

}