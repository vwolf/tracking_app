import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'track/trackList.dart';
import 'track/newTrackPage.dart';
import 'track/trackingPage.dart';
import 'item/newItemPage.dart';

import 'I10n/messages_all.dart';

void main() => runApp(MyApp());


class DemoLocalizations {
  static Future<DemoLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      //Intl.locale = localeName
      return DemoLocalizations();
    });
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for application'
    );
  }
}


class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) => DemoLocalizations.load(locale);

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final String localeName = Intl.canonicalizedLocale('de');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => DemoLocalizations.of(context).title,
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('de', ''),
      ],
      title: 'Track me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
         buttonColor: Colors.blueAccent,
        ),
      ),
      home: MyHomePage(title: 'Tracks'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  void _newTrack() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return NewTrackPage();
      })
    );
  }

  void _newPoint() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return NewItemPage();
      })
    );
  }


  void _startTracking() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return TrackingPage();
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      appBar: AppBar(
        //title: Text(widget.title),
        title: Text(DemoLocalizations.of(context).title),
      ),

      body: Container(
        //color: Colors.blueGrey,
        child: TrackList(),
      ),

      persistentFooterButtons: <Widget>[
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        FloatingActionButton.extended(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            onPressed: _newPoint,
            icon: Icon(Icons.control_point),
            label: Text('Point'),
            backgroundColor: Colors.blue,
            heroTag: "newPoint",
        ),
        FloatingActionButton.extended(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          onPressed: _newTrack,
          tooltip: 'Increment',
          icon: Icon(Icons.control_point),
          label: Text('Track'),
          backgroundColor: Colors.blue,
          heroTag: "newTrack",
        ),
        FloatingActionButton.extended(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            onPressed: _startTracking,
            icon: Icon(Icons.location_on),
            label: Text('Tracking'),
            backgroundColor: Colors.blue,
            heroTag: "startTracking",
        ),

      ],
      //backgroundColor: Colors.blueGrey,
      //bottomSheet: openPersistentBottomController(context)
    );
  }
}
