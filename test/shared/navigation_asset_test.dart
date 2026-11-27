import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'authentication, header and navbar bundle only lossless WebP artwork',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      for (final (folder, count) in [
        ('navigation', 9),
        ('header', 8),
        ('auth', 27),
      ]) {
        final paths = allAssets.where(
          (path) => path.startsWith('assets/$folder/'),
        );
        expect(paths, hasLength(count));
        for (final path in paths) {
          expect(path, endsWith('.webp'));
          final data = await rootBundle.load(path);
          String tag(int offset) => ascii.decode(
            data.buffer.asUint8List(data.offsetInBytes + offset, 4),
          );
          expect(tag(0), 'RIFF', reason: path);
          expect(tag(8), 'WEBP', reason: path);
          expect(tag(12), 'VP8L', reason: path);
        }
      }
    },
  );
}
