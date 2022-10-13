import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? client;
  var pongCount = 0;
  late String _identifier;

  void subscribe(String topic, Function data) async {
    _identifier = '';
    client = MqttServerClient('rmq2.pptik.id', _identifier);
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.secure = false;
    client!.logging(on: true);
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubcribed;

    try {
      await client?.connect('/smkn13bandung:smkn13bandung', 'qwerty');
      subScribeTo(topic);
      data();
    } on NoConnectionException catch (e) {
      print('[MQTT SERVICE] client connection fails');
      client?.disconnect();
    }
  }

  void publish(String topic, String data) async {
    _identifier = '';
    client = MqttServerClient('rmq2.pptik.id', _identifier);
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.secure = false;
    client!.logging(on: true);
    client!.onConnected = onConnected;

    try {
      await client?.connect('/smkn13bandung:smkn13bandung', 'qwerty');
      publishTo(topic, data);
    } on NoConnectionException catch (e) {
      print('[MQTT SERVICE] client connection fails');
    }
  }

  void onConnected() {
    print('[MQTT SERVICE] client connection successful');
  }

  void onSubcribed(String topic) {
    print('[MQTT SERVICE] Subscription confirmed to Topic $topic');
  }

  void onDisconnected() {
    print('[MQTT SERVICE] client disconnected');
    if (client!.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('[MQTT SERVICE] client disconnected because solicited');
    } else {
      print('[MQTT SERVICE] client disconnected');
      exit(-1);
    }
    if (pongCount == 3) {
      print('[MQTT SERVICE] Pong count is correct');
    } else {
      print('[MQTT SERVICE] pong count isi incorrect');
    }
  }

  void subScribeTo(String topic) {
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publishTo(String topic, String data) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(data);
    client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print(data);
  }
}