import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'trackService.dart';

class TrackItemInspect extends StatelessWidget {

  final TrackService trackService;
  final callBack;

  TrackItemInspect(this.trackService, this.callBack);

  @override
  Widget build(BuildContext context) {
    return Container(
     padding: EdgeInsets.only(top: 8.0, right: 0.0),
     constraints: BoxConstraints.loose(Size(double.infinity, 240.0)),
     color: Colors.blueGrey,
     child: ListView.builder(
       padding: EdgeInsets.only(left: 8.0),
       itemCount: trackService.trackItems.length,
         itemBuilder: (context, index) {
           return Card(
             color: Colors.blueGrey,

             child: InkWell(
               onTap: () {
                 print('tap on card with index $index');
                 callBack(index);
               },
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: <Widget>[
                   Text('${trackService.trackItems[index].name}',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 18.0,
                     color: Colors.white70
                   ),),
                   Padding(
                     padding: EdgeInsets.only(bottom: 6.0),
                     child: Text('${trackService.trackItems[index].info}',
                     style: TextStyle(
                       color: Colors.white70,
                     ),),
                   ),

                 ],
               ),
             ),
           );
         }),
    );
  }
}