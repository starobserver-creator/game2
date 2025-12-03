import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:game2/game.dart';

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

  testWidgets('Quiz screen renders without errors', (tester) async {
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
            child: const QuizGame(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify the quiz screen is present
    expect(find.byType(QuizGame), findsOneWidget);
    expect(find.text('🌱 Sustainability Quiz'), findsWidgets);
  });

  testWidgets('Quiz screen displays questions and options', (tester) async {
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
            child: const QuizGame(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Check for question display
    expect(find.text('Question 1/13'), findsOneWidget);

    // Check for at least some answer options
    expect(find.byType(Container), findsWidgets);
  });
}
