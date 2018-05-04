import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SocketIo {
  static final MethodChannel _methodChannel = new MethodChannel(
    _getChannelName(),
  );

  static _getChannelName({String instanceId}) {
    if (instanceId != null) {
      return "semigradsky.com/socket.io/$instanceId";
    }
    return "semigradsky.com/socket.io";
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
        final List<dynamic> arguments = data['arguments'] ?? [];
        if (_listeners.containsKey(eventName)) {
          _listeners[eventName].forEach((listener) {
            Function.apply(listener, arguments);
          });
        }
      },
      onError: (error) {
        print("error: $error");
      },
    );
  }

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

  final String uri;
  final String instanceId;
}
