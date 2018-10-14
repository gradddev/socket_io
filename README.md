# socket_io

The Socket.IO plugin for the Flutter.

[Donate](https://www.paypal.me/semigradsky)

## Getting Started

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

## Example

### Client
#### Code
```dart
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
```
#### Log
```
I/flutter: Connecting...
I/flutter: Connected.
I/flutter: Client SocketID: ska0utZ3GlmA8cC6AAAA
I/flutter: Hello, world!
```

### Node.js Socket.IO Server:
#### Code
```javascript
const app = require('express')();
const server = require('http').Server(app);
const io = require('socket.io')(server);

io.on('connection', (socket) => {
  console.log(`Client SocketID: ${socket.id}.`);
  socket.emit('sayHello', {Hello: 'world!'});
  socket.on('sayHello', (greeting) => {
    console.log(`Hello, ${greeting['Hello']}`);
  });
});

server.listen(8080);
```
#### Log
```
Client SocketID: ska0utZ3GlmA8cC6AAAA.
Hello, world!
```
