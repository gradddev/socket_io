import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io/socket_io.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final uri = 'http://192.168.1.38:8080';
    final socket = await SocketIo.newInstance(uri);
    await socket.on("string", (string) {
      print(string);
    });
    await socket.on("encodedJson", (encodedJson) {
      final decodedJson = json.decode(encodedJson);
      print(decodedJson);
    });
    await socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Socket.IO Plugin example app'),
        ),
        body: new Center(
          child: new Text('Hello, world!'),
        ),
      ),
    );
  }
}
