import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Uploads photos the parent picks for a child profile or a custom activity
/// card, so a child can see their own bathroom or their own plate instead of a
/// generic pictogram. Doc §3.5 assigns media to Firebase Storage.
class ImageUploadService {
  ImageUploadService(this._storage, this._picker);

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  /// Photos are downscaled before upload: a full-resolution phone photo is
  /// several MB, and these are only ever shown in a card a few hundred pixels
  /// wide. Keeps uploads fast on a home connection and storage costs near zero.
  static const _maxEdge = 800.0;
  static const _quality = 80;

  /// Picks an image and returns its download URL, or null if the parent backed
  /// out of the picker.
  Future<String?> pickAndUpload({
    required String childId,
    required ImageSource source,
    required String folder,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxEdge,
      maxHeight: _maxEdge,
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final ref = _storage.ref(
      // Scoped per child so the security rules can check ownership by path.
      'children/$childId/$folder/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(
      File(picked.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  /// Best-effort cleanup. A missing or already-deleted object is not an error
  /// worth surfacing to a parent.
  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException {
      // Object gone, or never was a Storage URL — nothing to do.
    }
  }
}

/// True when [image] is an uploaded photo rather than one of the bundled assets.
/// Callers use this to decide between [Image.network] and [Image.asset].
bool isUploadedImage(String image) =>
    image.startsWith('http://') || image.startsWith('https://');

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService(FirebaseStorage.instance, ImagePicker());
});
