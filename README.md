# socket_io (alpha)

The Socket.IO plugin for the Flutter.

Only Android currently supported, but I'm working on the iOS version.

## Getting Started

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

## Example

### Client
#### Code
```dart
const uri = 'http://192.168.1.38:8080';
final socket = await SocketIO.createNewInstance(uri);
await socket.on(SocketIOEvent.connecting, () async {
  final isConnected = await socket.isConnected();
  print('Is connected? ${isConnected ? 'Yes.' : 'No.'}');
  print('Connecting...');
});
await socket.on(SocketIOEvent.connect, () async {
  print('Connected.');
  final isConnected = await socket.isConnected();
  print('Is connected? ${isConnected ? 'Yes.' : 'No.'}');
});
await socket.on(SocketIOEvent.connectError, (error) {
  print('Error: $error');
});
await socket.on('sayHello', (greeting) {
  print('Hello, ${greeting['Hello']}');
});
await socket.connect();
```
#### Log
```
I/flutter: Is connected? No.
           Connecting...
I/flutter: Connected.
I/flutter: Is connected? Yes.
I/flutter: Hello, world!
```

### Node.js Socket.IO Server:
```javascript
const app = require('express')();
const server = require('http').Server(app);
const io = require('socket.io')(server);

io.on('connection', (socket) => {
  socket.emit('sayHello', {Hello: 'world!'});
});

server.listen(8080, () => console.log('Listening on port 8080'));
```