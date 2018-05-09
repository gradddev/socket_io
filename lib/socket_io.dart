import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// TODO
class SocketIO {
  /// TODO
  static const channelName = 'semigradsky.com/socket.io';

  /// TODO
  static final MethodChannel _globalMethodChannel =
      new MethodChannel(channelName);

  /// TODO
  static Future<SocketIO> createNewInstance(String uri) async {
    final String instanceId = await _globalMethodChannel.invokeMethod(
      'createNewInstance',
      {'uri': uri},
    );
    return new SocketIO._internal(
      instanceId: instanceId,
      uri: uri,
    );
  }

  /// TODO
  final String uri;

  /// TODO
  final String instanceId;

  /// TODO
  final MethodChannel _methodChannel;

  /// TODO
  SocketIO._internal({
    @required this.uri,
    @required this.instanceId,
  }) : _methodChannel = new MethodChannel("$channelName/$instanceId") {
    print("$channelName/$instanceId");
    _methodChannel.setMethodCallHandler((call) {
      if (call.method == 'handleData') {
        final String event = call.arguments['event'];
        final List<dynamic> arguments = call.arguments['arguments'];
        _handleData(event: event, arguments: arguments);
      }
    });
  }

  /// TODO
  final Map<String, Map<String, Function>> _listeners = {};

  /// Manually opens the socket.
  connect() async {
    await _methodChannel.invokeMethod('connect');
  }

  /// Register a new handler for the given event.
  on(String event, Function listener) async {
    final listenerId = await _methodChannel.invokeMethod('on', {
      'event': event,
    });
    if (!_listeners.containsKey(event)) {
      _listeners[event] = new Map<String, Function>();
    }
    _listeners[event][listenerId] = listener;
  }

  /// TODO
  off(String event, Function listener) async {
    if (!_listeners.containsKey(event)) return;
    String listenerId;
    for (var id in _listeners[event].keys) {
      if (_listeners[event][id] == listener) {
        listenerId = id;
        break;
      }
    }
    if (listenerId == null) return;
    await _methodChannel.invokeMethod('on', {
      'event': event,
      'listenerId': listenerId,
    });
  }

  /// An unique identifier for the socket session.
  ///
  /// Set after the [SocketIOEvent.connect] event is triggered,
  /// and updated after the [SocketIOEvent.reconnect] event.
  Future<String> get id async {
    return await _methodChannel.invokeMethod('id');
  }

  /// TODO
  Future<bool> get isConnected async {
    return await _methodChannel.invokeMethod('isConnected');
  }

  /// Emits an event to the socket identified by the string name.
  emit(String event, List<dynamic> arguments) async {
    await _methodChannel.invokeMethod('emit', {
      'event': event,
      'arguments': arguments,
    });
  }

  /// TODO
  _handleData({
    @required String event,
    List<dynamic> arguments = const [],
  }) {
    arguments = arguments.map((argument) {
      if (argument is String) {
        try {
          final decodedJson = json.decode(argument);
          return decodedJson;
        } catch (_) {}
      }
      return argument;
    }).toList();
    if (_listeners.containsKey(event)) {
      _listeners[event].forEach((_, listener) {
        Function.apply(listener, arguments);
      });
    }
  }
}

/// TODO
class SocketIOEvent {
  /// Fired upon a connection including a successful reconnection.
  static const connect = 'connect';

  /// Fired upon a connection error.
  static const connectError = 'connect_error';

  /// Fired upon a connection timeout.
  static const connectTimeout = 'connect_timeout';

  /// Fired when an error occurs.
  static const error = 'error';

  /// TODO
  static const connecting = 'connecting';

  /// Fired upon a successful reconnection.
  static const reconnect = 'reconnect';

  /// Fired upon a reconnection attempt error.
  static const reconnectError = 'reconnect_error';

  /// TODO
  static const reconnectFailed = 'reconnect_failed';

  /// Fired upon an attempt to reconnect.
  static const reconnectAttempt = 'reconnect_attempt';

  /// Fired upon an attempt to reconnect.
  static const reconnecting = 'reconnecting';

  /// Fired when a ping packet is written out to the server.
  static const ping = 'ping';

  /// Fired when a pong is received from the server.
  static const pong = 'pong';
}
