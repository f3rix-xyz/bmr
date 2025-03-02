
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dtx/providers/verification_provider.dart';
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

      print("Establishing SSE connection to: $baseUrl/api/admin/events");
      _eventSource = EventSource(
        Uri.parse('$baseUrl/api/admin/events'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _eventSource!.onOpen = () {
        print("SSE connection opened");
        _isConnected = true;
        _retryCount = 0;
      };

      _eventSource!.onMessage = (event) {
        if (event.event == 'ping') {
          print("Received verification ping event");
          // Trigger verification list refresh
          ref.read(verificationProvider.notifier).fetchVerifications();
        }
      };

      _eventSource!.onError = (error) {
        print("SSE connection error: $error");
        _isConnected = false;
        _disconnect();
        _scheduleReconnect();
      };

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
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 1 * (1 << _retryCount));
    _retryCount = _retryCount < 5 ? _retryCount + 1 : 5; // Max 32 seconds
    return baseDelay;
  }

  void dispose() {
    _disconnect();
    _reconnectTimer?.cancel();
  }
}

// Simple EventSource implementation for SSE
class EventSource {
  final Uri uri;
  final Map<String, String> headers;
  StreamSubscription? _subscription;
  final _client = HttpClient();

  void Function()? onOpen;
  void Function(ServerSentEvent)? onMessage;
  void Function(dynamic)? onError;

  EventSource(this.uri, {this.headers = const {}});

  Future<void> connect() async {
    try {
      final request = await _client.getUrl(uri);
      
      // Add headers
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });
      
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to connect: ${response.statusCode}');
      }
      
      if (onOpen != null) {
        onOpen!();
      }
      
      _subscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_processLine, onError: onError, onDone: close);
    } catch (e) {
      if (onError != null) {
        onError!(e);
      }
    }
  }

  void _processLine(String line) {
    if (line.isEmpty) return;
    
    if (line.startsWith('data:')) {
      final data = line.substring(5).trim();
      if (onMessage != null) {
        onMessage!(ServerSentEvent('message', data));
      }
    } else if (line.startsWith('event:')) {
      final eventType = line.substring(6).trim();
      if (onMessage != null) {
        onMessage!(ServerSentEvent(eventType, ''));
      }
    }
  }

  void close() {
    _subscription?.cancel();
    _client.close();
  }
}

class ServerSentEvent {
  final String event;
  final String data;

  ServerSentEvent(this.event, this.data);
}

final sseConnectionProvider = Provider<SSEConnectionManager>((ref) {
  final baseUrl = 'http://localhost:8080'; // Replace with your actual base URL
  final manager = SSEConnectionManager(baseUrl, ref);
  return manager;
});
