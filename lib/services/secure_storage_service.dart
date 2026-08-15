import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(key: 'pin_padre', value: pin);
  }

  Future<String?> readPin() async {
    return await _storage.read(key: 'pin_padre');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
