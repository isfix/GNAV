import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'native_bridge.dart';

class SessionManager {
  SessionManager();

  String? _currentSessionId;

  Future<void> startSession() async {
    // Generate a unique session ID based on timestamp
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _currentSessionId = sessionId;

    // Start the native service with this ID
    await NativeBridge.startService(sessionId);
  }

  Future<void> stopSession() async {
    await NativeBridge.stopService();
    _currentSessionId = null;
  }

  String? get currentSessionId => _currentSessionId;
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});
