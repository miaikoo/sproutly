import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which child profile the parent is currently working with.
///
/// Kept on the device rather than in Firestore: it is a per-device preference,
/// not data about the child. A parent using a tablet in the living room and a
/// phone in the car can be on different profiles without one overwriting the
/// other.
const _activeChildKey = 'active_child_id';

/// Overridden in `main()` once the plugin has loaded, so every read afterwards
/// is synchronous and no screen has to wait on an async preference lookup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider must be overridden in main() before use.',
  );
});

class ActiveChildId extends Notifier<String?> {
  @override
  String? build() => ref.read(sharedPreferencesProvider).getString(_activeChildKey);

  /// Switches profile. Everything reading [currentChildProvider] follows.
  Future<void> select(String childId) async {
    state = childId;
    await ref.read(sharedPreferencesProvider).setString(_activeChildKey, childId);
  }

  /// Forgets the choice — used when the selected profile is deleted, so the app
  /// falls back to the first remaining child instead of showing nothing.
  Future<void> clear() async {
    state = null;
    await ref.read(sharedPreferencesProvider).remove(_activeChildKey);
  }
}

final activeChildIdProvider =
    NotifierProvider<ActiveChildId, String?>(ActiveChildId.new);
