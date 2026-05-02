// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}