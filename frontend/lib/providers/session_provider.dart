import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class SessionState {
  final bool isLoading;
  final String? sessionCode;
  final String? tableNumber;
  final String? deviceId;

  SessionState({this.isLoading = true, this.sessionCode, this.tableNumber, this.deviceId});

  SessionState copyWith({bool? isLoading, String? sessionCode, String? tableNumber, String? deviceId}) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      sessionCode: sessionCode ?? this.sessionCode,
      tableNumber: tableNumber ?? this.tableNumber,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    _loadSession();
    return SessionState();
  }

  Dio get _dio => ref.read(dioProvider);

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('session_code');
    
    if (code != null) {
      try {
        final response = await _dio.get('sessions/recover', queryParameters: {'session_code': code});
        if (response.statusCode == 200) {
          state = state.copyWith(
            isLoading: false, 
            sessionCode: response.data['session_code'],
            tableNumber: response.data['table_number'].toString()
          );
          return;
        }
      } catch (e) {
        // Fallback silently
      }
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> startSession(String qrToken, String deviceId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.post('sessions/start', data: {
        'qr_token': qrToken,
        'device_id': deviceId,
      });

      if (response.statusCode == 200) {
         final code = response.data['session_code'];
         final prefs = await SharedPreferences.getInstance();
         await prefs.setString('session_code', code);
         
         state = state.copyWith(
           isLoading: false,
           sessionCode: code,
           tableNumber: response.data['table_number'].toString(),
           deviceId: deviceId,
         );
         return true;
      }
    } catch (e) {
      // Error logging can be handled by interceptors
    }
    state = state.copyWith(isLoading: false);
    return false;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});
