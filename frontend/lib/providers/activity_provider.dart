import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'session_provider.dart';

class ActivityService {
  final Ref _ref;
  ActivityService(this._ref);

  Future<void> record(int menuItemId, String actionType) async {
    final session = _ref.read(sessionProvider);
    if (session.deviceId == null) return;

    try {
      final dio = _ref.read(dioProvider);
      await dio.post('activity', data: {
        'device_id': session.deviceId,
        'menu_item_id': menuItemId,
        'action_type': actionType,
      });
    } catch (e) {
      // Background activity recording, suppress errors
    }
  }
}

final activityProvider = Provider<ActivityService>((ref) {
  return ActivityService(ref);
});
