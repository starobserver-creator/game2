import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game2/main.dart';
import 'dart:convert';
import 'package:flutter/semantics.dart';

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
    // Provide a tiny valid PNG for image assets so image decoding succeeds.
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      final bytes = Uint8List.fromList(_transparentImage);
      return bytes.buffer.asByteData();
    }

    // Simple JSON responses for manifest/font files
    if (key.endsWith('AssetManifest.json')) {
      final bytes = Uint8List.fromList(utf8.encode('{}'));
      return bytes.buffer.asByteData();
    }

    if (key.endsWith('AssetManifest.bin') || key.endsWith('AssetManifest.bin.json')) {
      // Encode an empty map using StandardMessageCodec so the engine can decode it
      final codec = StandardMessageCodec();
      final ByteData? encoded = codec.encodeMessage(<String, dynamic>{});
      if (encoded != null) return encoded;
      return ByteData(0);
    }

    if (key.endsWith('FontManifest.json')) {
      final bytes = Uint8List.fromList(utf8.encode('[]'));
      return bytes.buffer.asByteData();
    }

    // Default: empty
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

  testWidgets('Home screen exposes Play Quiz and View Scoreboard semantics',
      (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Increase the test window size to avoid layout overflow in the HomeScreen
    binding.window.physicalSizeTestValue = const Size(1200, 2000);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: _TestAssetBundle(),
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 2000)),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    ));

    // Use a couple of pumps rather than pumpAndSettle because the
    // HomeScreen contains repeating animations (clouds, etc.) which
    // keep the scheduler active and would cause pumpAndSettle to time out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Find the Start quiz semantics node
    final playFinder = find.bySemanticsLabel('Start quiz');
    expect(playFinder, findsOneWidget,
        reason: 'Start quiz semantics node should be present');


      expect(
        tester.getSemantics(playFinder),
        matchesSemantics(
          label: 'Start quiz',
          hasTapAction: true,
          hasFocusAction: true,
          isButton: true,
          isFocusable: true,
        ),
      );

    // For the scoreboard, find a semantics node labeled 'View scoreboard'
    final scoreboardFinder = find.bySemanticsLabel('View scoreboard').first;
    expect(scoreboardFinder, findsOneWidget,
        reason: 'A semantics node labeled "View scoreboard" should exist');

    expect(
      tester.getSemantics(scoreboardFinder),
      matchesSemantics(
        label: 'View scoreboard',
        isButton: true,
      ),
    );

    // Clean up test window overrides
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('Home screen announces screen title to screen readers', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 2000);
    binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: _TestAssetBundle(),
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 2000)),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Find the home screen announcement Semantics
    final homeAnnouncementFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final label = widget.properties.label ?? '';
        return label.contains('Home Screen') && label.contains('A Greener Davis Adventure');
      }
      return false;
    });

    expect(homeAnnouncementFinder, findsOneWidget,
        reason: 'Home screen title announcement should exist');

    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
