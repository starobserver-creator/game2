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

  testWidgets('Scoreboard exposes attempts and delete buttons to semantics', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final manager = TamperProofScoreManager();

    // Seed two scores
    await manager.saveScore(score: 5, totalQuestions: 10, date: DateTime.now().subtract(const Duration(days: 1)));
    await manager.saveScore(score: 8, totalQuestions: 10, date: DateTime.now());

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

    // Semantics entries for attempts
    final attemptFinder = find.byWidgetPredicate((w) {
      if (w is Semantics) {
        final label = w.properties.label ?? '';
        return label.contains('Attempt');
      }
      return false;
    });

    expect(attemptFinder, findsAtLeastNWidgets(1));

    // Delete buttons should be exposed as semantics with label 'Delete score'
    final deleteFinder = find.byWidgetPredicate((w) {
      if (w is Semantics) {
        final label = w.properties.label ?? '';
        return label.contains('Delete score');
      }
      return false;
    });

    expect(deleteFinder, findsNWidgets(2));

    // Check for statistics cards (at least one should be visible)
    final statsFinder = find.byWidgetPredicate((w) {
      if (w is Semantics) {
        final label = w.properties.label ?? '';
        return label.contains('Attempts:') ||
            label.contains('Average score:') ||
            label.contains('Best score:') ||
            label.contains('Worst score:');
      }
      return false;
    });

    expect(statsFinder, findsAtLeastNWidgets(1),
        reason: 'At least one statistics card should be exposed via Semantics');

    // Check for Clear All button semantics
    final clearAllFinder = find.byWidgetPredicate((w) {
      if (w is Semantics) {
        final label = w.properties.label ?? '';
        return label.contains('Clear all scores');
      }
      return false;
    });

    expect(clearAllFinder, findsOneWidget,
        reason: 'Clear All button should have accessible semantics');

    // Check for score list container semantics
    final scoreListFinder = find.byWidgetPredicate((w) {
      if (w is Semantics) {
        final label = w.properties.label ?? '';
        return label.contains('Score history');
      }
      return false;
    });

    expect(scoreListFinder, findsOneWidget,
        reason: 'Score list should be wrapped in Semantics container with history label');
  });
}
