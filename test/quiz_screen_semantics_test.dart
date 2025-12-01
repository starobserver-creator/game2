import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game2/game.dart';

class _TestAssetBundle extends CachingAssetBundle {
  static final List<int> _transparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
    0x54, 0x78, 0x9C, 0x63, 0x00, 0x00, 0x00, 0x02,
    0x00, 0x01, 0xE2, 0x21, 0xBC, 0x33, 0x00, 0x00,
    0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      final bytes = Uint8List.fromList(_transparentImage);
      return bytes.buffer.asByteData();
    }

    if (key.endsWith('AssetManifest.json')) return Uint8List.fromList(utf8.encode('{}')).buffer.asByteData();
    if (key.endsWith('FontManifest.json')) return Uint8List.fromList(utf8.encode('[]')).buffer.asByteData();

    if (key.endsWith('AssetManifest.bin') || key.endsWith('AssetManifest.bin.json')) {
      final codec = StandardMessageCodec();
      final ByteData? encoded = codec.encodeMessage(<String, dynamic>{});
      if (encoded != null) return encoded;
      return ByteData(0);
    }

    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('AssetManifest.json')) return '{}';
    if (key.endsWith('FontManifest.json')) return '[]';
    return '';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Quiz answer options expose semantics as buttons', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 2000);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: _TestAssetBundle(),
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 2000)),
        child: const MaterialApp(home: QuizGame()),
      ),
    ));

    // Allow initial frames (animations exist) but don't wait indefinitely
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // First question options
    final options = [
      'Pick it up right away',
      'Leave it for someone else',
      'Push it into the gutter',
      'Ignore it',
    ];

    for (final option in options) {
      final finder = find.bySemanticsLabel(option);
      expect(finder, findsOneWidget, reason: 'Semantics for "$option" should exist');

      // allow focus action in addition to tap
      expect(
        tester.getSemantics(finder),
        matchesSemantics(label: option, hasTapAction: true, isButton: true),
      );
    }

    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
