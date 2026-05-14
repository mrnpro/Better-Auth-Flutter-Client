import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'better_auth_local_storage_service.dart';

class FlutterSecureImpl extends BetterAuthLocalStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> create(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String> get(String key) async => await _storage.read(key: key) ?? '';

  @override
  Future<void> update(String key, String value) =>
      _storage.write(key: key, value: value);
}
