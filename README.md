# socket_io (alpha)

The Socket.IO plugin for the Flutter.

Only Android currently supported, but I'm working on the iOS version.

## Getting Started

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

## Example

### Client
```dart
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