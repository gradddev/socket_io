import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SocketIo {
  static final MethodChannel _methodChannel = new MethodChannel(
    _getChannelName(),
  );

  static _getChannelName({String instanceId}) {
    if (instanceId != null) {
      return 'semigradsky.com/socket.io/$instanceId';
    }
    return 'semigradsky.com/socket.io';
  }

  static Future<SocketIo> newInstance(String uri) async {
    final parameters = {'uri': uri};
    final String instanceId = await _methodChannel.invokeMethod(
      'newInstance',
      parameters,
    );
    return new SocketIo._internal(
      uri: uri,
      instanceId: instanceId,
    );
  }

  SocketIo._internal({
    @required this.uri,
    @required this.instanceId,
  }) {
    final eventChannel = new EventChannel(
      _getChannelName(instanceId: instanceId),
    );
    eventChannel.receiveBroadcastStream().listen(
      (data) {
        final String eventName = data['eventName'];
        List<dynamic> arguments = (data['arguments'] ?? []).map((argument) {
          try {
            final decodedJson = json.decode(argument);
            return decodedJson;
          } catch (error) {
            return argument;
          }
        }).toList();
        if (_listeners.containsKey(eventName)) {
          _listeners[eventName].forEach((listener) {
            Function.apply(listener, arguments);
          });
        }
      },
      cancelOnError: true,
    );
  }

  final String uri;
  final String instanceId;
  final Map<String, List<Function>> _listeners = {};

  connect() async {
    await _methodChannel.invokeMethod('connect', {
      'instanceId': instanceId,
    });
  }

  on(String eventName, Function listener) async {
    await _methodChannel.invokeMethod('on', {
      'instanceId': instanceId,
      'eventName': eventName,
    });
    if (!_listeners.containsKey(eventName)) {
      _listeners[eventName] = new List<Function>();
    }
    _listeners[eventName].add(listener);
  }
}

class SocketIoEvent {
  static const connect = 'connect';
  static const connecting = 'connecting';
  static const connectError = 'connect_error';
  static const connectTimeout = 'connect_timeout';
  static const reconnect = 'reconnect';
  static const reconnectError = 'reconnect_error';
  static const reconnectFailed = 'reconnect_failed';
  static const reconnectAttempt = 'reconnect_attempt';
  static const reconnecting = 'reconnecting';
  static const ping = 'ping';
  static const pong = 'pong';
}
