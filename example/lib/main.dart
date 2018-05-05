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
    const uri = 'http://192.168.1.39:8080';
    final socket = await SocketIo.newInstance(uri);
    await socket.on(SocketIoEvent.connecting, () {
      print('Connecting...');
    });
    await socket.on(SocketIoEvent.connect, () {
      print('Connected.');
    });
    await socket.on(SocketIoEvent.connectError, (error) {
      print('Error: $error');
    });
    await socket.on('sayHello', (greeting) {
      print(greeting);
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
