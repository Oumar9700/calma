import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadAvatar(String uid, File file) async {
    final ref = _storage.ref('users/$uid/avatar.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadCoverPhoto(String uid, File file) async {
    final ref = _storage.ref('users/$uid/cover.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteAvatar(String uid) async {
    try {
      await _storage.ref('users/$uid/avatar.jpg').delete();
    } catch (_) {}
  }

  Future<void> deleteCoverPhoto(String uid) async {
    try {
      await _storage.ref('users/$uid/cover.jpg').delete();
    } catch (_) {}
  }
}
