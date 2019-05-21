import 'package:flutter/material.dart';

import '../database/database.dart';
import '../database/models/track.dart';
import 'trackListItem.dart';

import 'trackDetailPage.dart';
import '../readWrite/writeTrackPage.dart';
import 'newTrackPage.dart';

/// ToDo Reset slideable item when navigation to different page
/// ToDo At the moment is uses the item to reset - change?
///
/// All tracks as ListView
class TrackList extends StatefulWidget {

  TrackList();

  @override
  _TrackListState createState() => _TrackListState();
}


class _TrackListState extends State<TrackList> {

  @override
  Widget build(BuildContext context) {
    return _buildFutureList(context);
  }

  List<Track> _tracks = [];

  Future<List<Track>> getTracks() async {
    List tracks = await DBProvider.db.getAllTracks();
    _tracks = tracks;
    return _tracks;
  }


  /// Go to Track details page
  goTrackDetailPage(Track track) {

    setState(() { });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return new TrackDetailPage(track);
      })
    );
  }


  /// Edit tour data
  editTour(BuildContext context, Track track) {
    setState(() {});

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return NewTrackPage.withTour(track);
      })
    );
  }


  /// Go to Save tour to external page
  archiveTour(BuildContext context, Track track) {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) {
          return new WriteTrackPage(track);
        })
    );
  }

  /// Slideable version
  _buildFutureList(context) {
    print("buildFutureList");
    return FutureBuilder(
      future: getTracks(),
      builder: (BuildContext context, AsyncSnapshot<List<Track>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            //padding: null,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                print("FutureBuilder itemCoount: ${snapshot.data.length}");
                return TrackListItem(
                  items: <ActionItems>[
                    ActionItems(
                      icon: IconButton(
                          icon: Icon(Icons.edit,
                          size: 36.0,),
                          onPressed: () {},
                          color: Colors.green,
                      ),
                      onPress: () {
                        editTour(context, snapshot.data[index]);
                      }
                    ),
                    ActionItems(
                      icon: IconButton(
                          icon: Icon(Icons.archive,
                          size: 36.0,),
                          onPressed: () {},
                          color:  Colors.green,
                      ),
                      onPress: () {
                        archiveTour(context, snapshot.data[index]);
                      },
                      backgroundColor: Colors.orange
                    ),
                    ActionItems(
                        icon: IconButton(
                          icon: Icon(Icons.delete,
                            size: 36.0,),
                          onPressed: () {},
                          color:  Colors.red,
                        ),
                        onPress: () {
                          print("delete track");
                          deleteTrack(context, index);
                        },
                        backgroundColor: Colors.white70
                    ),
                  ],
                  child: Container(
                    //color: Colors.white,
                    padding: const EdgeInsets.only(top: 2.0),
                    height: 115,
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          goTrackDetailPage(snapshot.data[index]);
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          leading: Container(
                            padding: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(width: 1.0, color: Colors.black87)
                              )
                            ),
                            //child: Icon(Icons.directions_walk,
                            child: Icon( snapshot.data[index].getOption("type") == "walk" ? Icons.directions_walk : Icons.directions_bike,
                            size: 40.0,
                            ),
                          ),
                            title: Text(
                              snapshot.data[index].name,
                              style: Theme.of(context).textTheme.headline,
                            ),
                            subtitle: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                //Icon(Icons.linear_scale, color: Colors.yellowAccent),
                                Text(snapshot.data[index].location),
                              ],
                            ),
//                          subtitle: Row(
//                            children: <Widget>[
////                              ListView(
////                                scrollDirection: Axis.horizontal,
////                                children: <Widget>[
////                                  Icon(Icons.linear_scale, color: Colors.yellowAccent),
////                                  Text(snapshot.data[index].location),
////                                ],
////                              ),
//                              Icon(Icons.linear_scale, color: Colors.yellowAccent),
//                              ClipRect(
//                                child: Text(snapshot.data[index].location),
//                              ),
//                              // Text(snapshot.data[index].location),
//                            ],
//                          ),
                          trailing: Icon(Icons.keyboard_arrow_right, size: 30.0),
                        )
//                        child: Row(
//                          children: <Widget>[
//                            Icon(
//                              Icons.directions_walk,
//                              size: 40.0,
//                            ),
//                            Text(snapshot.data[index].name,
//                            style: Theme.of(context).textTheme.headline,)
//                          ],
//                        ),
                      ),
                    ),
                   ),
                 // backgroundColor: Colors.blueGrey,
                );
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  /// Delete track in Track table and
  /// coords and item table for track
  deleteTrack(BuildContext context, int index) {
    if (_tracks[index].track != null ) {
      DBProvider.db.deleteTable(_tracks[index].track);
    }
    if (_tracks[index].items != null ) {
      DBProvider.db.deleteTable(_tracks[index].items);
    }
    DBProvider.db.deleteTrack(_tracks[index].id);

    setState(() {});
  }
}