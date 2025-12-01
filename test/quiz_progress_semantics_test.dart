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

    if (key.endsWith('AssetManifest.json')) {
      return Uint8List.fromList(utf8.encode('{}')).buffer.asByteData();
    }

    if (key.endsWith('FontManifest.json')) {
      return Uint8List.fromList(utf8.encode('[]')).buffer.asByteData();
    }

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

  testWidgets('Quiz screen progress and question semantics are announced', (tester) async {
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Check for progress announcement: "Progress: Question 1 of 13"
    final progressFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final label = widget.properties.label ?? '';
        return label.contains('Progress') && label.contains('Question 1');
      }
      return false;
    });

    expect(progressFinder, findsOneWidget,
        reason: 'Progress semantics should announce "Progress: Question 1 of 13"');

    // Check for question counter: "Question 1 of 13"
    final questionCounterFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final label = widget.properties.label ?? '';
        return label == 'Question 1 of 13';
      }
      return false;
    });

    expect(questionCounterFinder, findsOneWidget,
        reason: 'Question counter semantics should announce "Question 1 of 13"');

    // Check for current score: "Current score: 0 correct"
    final scoreFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final label = widget.properties.label ?? '';
        return label.contains('Current score') && label.contains('0 correct');
      }
      return false;
    });

    expect(scoreFinder, findsOneWidget,
        reason: 'Score semantics should announce "Current score: 0 correct"');

    // Check for question text
    final questionTextFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final label = widget.properties.label ?? '';
        return label.contains('What should you do if you accidentally drop trash');
      }
      return false;
    });

    expect(questionTextFinder, findsOneWidget,
        reason: 'Question text semantics should be announced');

    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('Quiz answer options include total count in hint', (tester) async {
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Check that answer options have hints with "of 4"
    final firstOptionFinder = find.byWidgetPredicate((widget) {
      if (widget is Semantics) {
        final hint = widget.properties.hint ?? '';
        return hint.contains('Answer option 1 of 4');
      }
      return false;
    });

    expect(firstOptionFinder, findsOneWidget,
        reason: 'Answer option hint should include "of 4"');

    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
