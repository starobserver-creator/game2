import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:game2/scoreboard.dart';
import 'package:game2/tamper_proof_score_manager.dart';

// Minimal 1x1 PNG
final _kTransparentImage = <int>[
  0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,
  0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
  0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
  0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
  0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,
  0x54,0x78,0x9C,0x63,0x60,0x00,0x00,0x00,
  0x02,0x00,0x01,0xE2,0x21,0xBC,0x33,0x00,
  0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
  0x42,0x60,0x82
];

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(Uint8List.fromList(_kTransparentImage).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{}';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scoreboard renders without errors', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const ScoreboardScreen(),
          ),
        ),
      ),
    );

    // Allow a frame for FutureBuilders to resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Check that the scoreboard renders
    expect(find.byType(ScoreboardScreen), findsOneWidget);
  });

  testWidgets('Scoreboard displays clear all button', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: TestAssetBundle(),
            child: const ScoreboardScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Look for the clear all button (may be labeled 'Clear All' or 'Clear all scores')
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final text = widget.data;
        return text == 'Clear All' || text?.contains('Clear') == true;
      }
      return false;
    }), findsWidgets);
  });
}
