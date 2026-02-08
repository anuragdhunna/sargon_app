import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorageService {
  final FirebaseStorage _storage;

  ImageStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage and returns the download URL.
  ///
  /// [file] is the image file to upload (XFile from image_picker).
  /// [folder] is the storage folder path (e.g., 'menu_items').
  Future<String> uploadImage(XFile file, String folder) async {
    print('DEBUG: ImageStorageService.uploadImage started for folder: $folder');
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference ref = _storage.ref().child('$folder/$fileName');
      print('DEBUG: Storage reference created: $folder/$fileName');

      if (kIsWeb) {
        print('DEBUG: Platform is Web. Reading bytes...');
        final Uint8List bytes = await file.readAsBytes();
        print('DEBUG: Bytes read: ${bytes.length} bytes. Starting putData...');
        final UploadTask uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
            'DEBUG: Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
          );
        });

        final TaskSnapshot snapshot = await uploadTask;
        print('DEBUG: putData completed. Fetching download URL...');
        final String url = await snapshot.ref.getDownloadURL();
        print('DEBUG: Download URL fetched: $url');
        return url;
      } else {
        print('DEBUG: Platform is Mobile/Desktop. Starting putFile...');
        final UploadTask uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
            'DEBUG: Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
          );
        });

        final TaskSnapshot snapshot = await uploadTask;
        print('DEBUG: putFile completed. Fetching download URL...');
        final String url = await snapshot.ref.getDownloadURL();
        print('DEBUG: Download URL fetched: $url');
        return url;
      }
    } catch (e) {
      print('DEBUG: Error in ImageStorageService.uploadImage: $e');
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Uploads raw bytes (for Web support if needed later)
  Future<String> uploadBytes(Uint8List data, String folder) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference ref = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image bytes: $e');
      }
      throw Exception('Failed to upload image');
    }
  }

  /// Deletes an image from storage given its URL.
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      // Start/End silent failure if image not found or already deleted
    }
  }
}
