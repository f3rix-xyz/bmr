import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dtx/providers/verification_provider.dart';
import 'package:dtx/utils/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/token_storage.dart';

class SSEConnectionManager {
  final String baseUrl;
  final Ref ref;
  EventSource? _eventSource;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _retryCount = 0;

  SSEConnectionManager(this.baseUrl, this.ref);

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print("Establishing SSE connection to: $baseUrl/events");
      _eventSource = EventSource(
        Uri.parse('$baseUrl/events'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _eventSource!.onOpen = () {
        print("SSE connection opened");
        _isConnected = true;
        _retryCount = 0;
      };

      _eventSource!.onMessage = (event) async {
        try {
          print("Received SSE event: ${event.data}");

          // Show notification with sound
          await NotificationService.showNotification(
            'New Verification Alert',
            'A new verification request has been received',
          );

          // Refresh verifications
          ref.read(verificationProvider.notifier).fetchVerifications();
        } catch (e) {
          print("Error processing SSE message: $e");
        }
      };

      _eventSource!.onError = (error) {
        print("SSE connection error: $error");
        _isConnected = false;
        _disconnect();
        _scheduleReconnect();
      };

      await _eventSource!.connect();
    } catch (e) {
      print("Error establishing SSE connection: $e");
      _scheduleReconnect();
    }
  }

  void _disconnect() {
    _eventSource?.close();
    _eventSource = null;
    _isConnected = false;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    final delay = _calculateBackoffDelay();
    print("Scheduling reconnection in ${delay.inSeconds} seconds");

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  Duration _calculateBackoffDelay() {
    final baseDelay = Duration(seconds: 1 * (1 << _retryCount));
    _retryCount = _retryCount < 5 ? _retryCount + 1 : 5;
    return baseDelay;
  }

  void dispose() {
    _disconnect();
    _reconnectTimer?.cancel();
  }
}

class EventSource {
  final Uri uri;
  final Map<String, String> headers;
  final HttpClient _client = HttpClient();
  StreamSubscription? _subscription;
  StringBuffer _buffer = StringBuffer();

  void Function()? onOpen;
  void Function(ServerSentEvent)? onMessage;
  void Function(dynamic)? onError;

  EventSource(this.uri, {this.headers = const {}});

  Future<void> connect() async {
    try {
      final request = await _client.getUrl(uri);
      headers.forEach((key, value) => request.headers.add(key, value));

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('SSE connection failed: ${response.statusCode}');
      }

      onOpen?.call();

      _subscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_handleData, onError: onError, onDone: () {
        close();
        onError?.call('Connection closed by server');
      });
    } catch (e) {
      onError?.call(e);
    }
  }

  void _handleData(String line) {
    if (line.isEmpty) {
      _processCompleteMessage();
      _buffer.clear();
    } else {
      _buffer.writeln(line);
    }
  }

  void _processCompleteMessage() {
    final message = _buffer.toString().trim();
    if (message.isEmpty) return;

    String? event;
    String data = '';

    for (var line in message.split('\n')) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
      }
    }

    if (data.isNotEmpty) {
      onMessage?.call(ServerSentEvent(event ?? 'message', data));
    }
  }

  void close() {
    _subscription?.cancel();
    _client.close(force: true);
    _buffer.clear();
  }
}

class ServerSentEvent {
  final String event;
  final String data;

  ServerSentEvent(this.event, this.data);
}

final sseConnectionProvider = Provider<SSEConnectionManager>((ref) {
  const baseUrl =
      'http://3.110.196.24:8080'; // Use const for better performance
  return SSEConnectionManager(baseUrl, ref);
});
