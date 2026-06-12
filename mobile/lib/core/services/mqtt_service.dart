import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mqtt_service.g.dart';

enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

@Riverpod(keepAlive: true)
class MqttService extends _$MqttService {
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final MqttConnectionState _connectionState = MqttConnectionState.disconnected;

  @override
  MqttConnectionState build() {
    ref.onDispose(() {
      _messageController.close();
    });
    return _connectionState;
  }

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect({
    required String brokerUrl,
    required String clientId,
    required String username,
    required String password,
  }) async {
    state = MqttConnectionState.connecting;
    if (kDebugMode) {
      print("MQTT: Connecting to $brokerUrl as $clientId...");
    }

    // Simulate connection lag
    await Future.delayed(const Duration(seconds: 1));

    state = MqttConnectionState.connected;
    if (kDebugMode) {
      print("MQTT: Connected to broker.");
    }

    // Start simulating telemetry feed
    _startMockTelemetryFeed(clientId);
  }

  Future<void> publish(String topic, Map<String, dynamic> message) async {
    if (kDebugMode) {
      print("MQTT Publish: Topic: $topic, Payload: ${jsonEncode(message)}");
    }
  }

  void _startMockTelemetryFeed(String clientId) {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (state != MqttConnectionState.connected) {
        timer.cancel();
        return;
      }

      final payload = {
        'device_id': clientId,
        'timestamp': DateTime.now().toIso8601String(),
        'telemetry': {
          'chamber_1': {'temp': 1.2, 'humidity': 92.4, 'co2': 850},
          'chamber_2': {'temp': 4.3, 'humidity': 90.1, 'co2': 500},
        }
      };

      _messageController.add(payload);
    });
  }

  Future<void> disconnect() async {
    state = MqttConnectionState.disconnected;
  }
}
