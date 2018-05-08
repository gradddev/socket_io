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

  /// TODO
  connect() async {
    await _methodChannel.invokeMethod('connect');
  }

  /// TODO
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

  /// TODO
  isConnected() async {
    return await _methodChannel.invokeMethod('isConnected');
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
  /// TODO
  static const connect = 'connect';

  /// TODO
  static const connecting = 'connecting';

  /// TODO
  static const connectError = 'connect_error';

  /// TODO
  static const connectTimeout = 'connect_timeout';

  /// TODO
  static const reconnect = 'reconnect';

  /// TODO
  static const reconnectError = 'reconnect_error';

  /// TODO
  static const reconnectFailed = 'reconnect_failed';

  /// TODO
  static const reconnectAttempt = 'reconnect_attempt';

  /// TODO
  static const reconnecting = 'reconnecting';

  /// TODO
  static const ping = 'ping';

  /// TODO
  static const pong = 'pong';
}
