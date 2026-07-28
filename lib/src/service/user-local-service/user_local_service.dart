import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:better_auth_client/better_auth_client.dart';

abstract class UserLocalService {
  Stream<User?> get userChanges;
  Future<void> setUser(User user);
  Future<User?> getUser();
  Future<void> deleteUser();
  Future<String> getAccessToken();
  Future<String> getRefreshToken();
}

class UserLocalServiceImpl extends UserLocalService {
  final BetterAuthLocalStorage localStorageService;
  final String _userKey = 'user-key';
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  UserLocalServiceImpl({required this.localStorageService}) {
    // Emit initial null value to indicate no user is loaded yet
    _userController.add(null);
  }
  @override
  Future<void> deleteUser() async {
    try {
      await localStorageService.delete(_userKey);
      _userController.add(null);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getAccessToken() async {
    try {
      final currentUser = await getUser();
      return currentUser?.token ?? '';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getRefreshToken() async {
    try {
      final currentUser = await getUser();
      return currentUser?.token ?? '';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getUser() async {
    try {
      final userJson = await localStorageService.get(_userKey);
      final user = User.fromJson(jsonDecode(userJson));
      _userController.add(user);
      return user;
    } catch (e) {
      _userController.add(null);
      return null;
    }
  }

  @override
  Future<void> setUser(User user) async {
    try {
      await deleteUser();
      final userJson = user.toJson();
      dev.log('📝 UserLocalService: Adding user to stream: ${user.email}');
      _userController.add(user);
      await localStorageService.create(_userKey, jsonEncode(userJson));
      dev.log('✅ UserLocalService: User saved successfully');
    } catch (e) {
      dev.log('❌ UserLocalService: Error saving user: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> get userChanges => _userController.stream;
}
