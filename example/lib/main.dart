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
    const uri = 'http://192.168.1.38:8080';
    final socket = await SocketIO.createNewInstance(uri);
    await socket.on(SocketIOEvent.connecting, () async {
      print('Connecting...');
    });
    await socket.on(SocketIOEvent.connect, () async {
      print('Connected.');

      final id = await socket.id;
      print('Client SocketID: $id');
    });
    await socket.on(SocketIOEvent.connectError, (error) {
      print('Error: $error');
    });
    await socket.on('sayHello', (greeting) {
      print('Hello, ${greeting['Hello']}');
    });
    await socket.connect();
    await socket.emit('sayHello', [
      {'Hello': 'world!'},
    ]);
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
