import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum PickSource { gallery, camera }

/// Centralized utility for file picking using both [file_picker] and [image_picker] packages.
/// Standardizes selection logic and limit enforcement across the app.
class FilePickerUtility {
  /// Picks one or more files based on the provided configuration.
  ///
  /// [source]: The source to pick from (gallery or camera).
  /// [allowMultiple]: Whether to allow selecting multiple files (only for gallery).
  /// [type]: The type of files to pick (e.g., [FileType.image], [FileType.any]).
  /// [allowedExtensions]: Optional list of extensions for filtering.
  /// [limit]: Optional maximum number of files to return.
  /// [onLimitExceeded]: Callback triggered if the selection exceeds [limit].
  static Future<List<File>?> pick({
    PickSource source = PickSource.gallery,
    bool allowMultiple = false,
    FileType type = FileType.any,
    List<String>? allowedExtensions = const ['jpg', 'jpeg', 'png'],
    int? limit,
    VoidCallback? onLimitExceeded,
  }) async {
    try {
      List<File> files = [];

      if (source == PickSource.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (photo == null) return null;
        files.add(File(photo.path));
      } else {
        final result = await FilePicker.pickFiles(
          allowMultiple: allowMultiple,
          type: allowedExtensions != null && allowedExtensions.isNotEmpty
              ? FileType.custom
              : type,
          allowedExtensions: allowedExtensions,
        );

        if (result == null || result.files.isEmpty) {
          return null;
        }

        files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }

      // Filter by extensions if provided (extra safety check)
      if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        files = files.where((file) {
          final ext = file.path.split('.').last.toLowerCase();
          return allowedExtensions.contains(ext);
        }).toList();

        if (files.isEmpty) return null;
      }

      if (limit != null && files.length > limit) {
        onLimitExceeded?.call();
        // Return only the first [limit] files
        return files.take(limit).toList();
      }

      return files;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return null;
    }
  }
}
