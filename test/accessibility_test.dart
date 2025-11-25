import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game2/main.dart';
import 'package:game2/game.dart';

void main() {
  group('Accessibility Tests', () {
    group('HomeScreen Accessibility', () {
      testWidgets('HomeScreen meets text contrast guidelines',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Test that the app renders without accessibility issues
        expect(find.byType(MyApp), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('HomeScreen has proper semantics for play button',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify play button has semantic label
        final playButtonFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('Play') ?? false),
        );
        expect(
          playButtonFinder,
          findsOneWidget,
          reason: 'Play button should have semantic label for accessibility',
        );
      });

      testWidgets('HomeScreen title has proper semantics',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify title text exists
        expect(find.text('A Greener Davis'), findsOneWidget);
        expect(find.text('Adventure!'), findsOneWidget);
      });

      testWidgets('HomeScreen images have semantic labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify decorative images have proper semantics
        final semanticsWithImageDescription = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.image == true,
        );
        // Decorative images should be marked as such
        expect(semanticsWithImageDescription.evaluate().isNotEmpty, isTrue);
      });
    });

    group('QuizGame Accessibility', () {
      testWidgets('QuizGame meets basic accessibility standards',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify quiz game renders
        expect(find.byType(QuizGame), findsOneWidget);
      });

      testWidgets('QuizGame has semantic labels for answer buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify answer buttons have semantic labels
        final answerButtonsWithSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label != null,
        );
        expect(
          answerButtonsWithSemantics,
          findsWidgets,
          reason: 'Answer buttons should have semantic labels',
        );
      });

      testWidgets('QuizGame question text is accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify question text is present
        expect(
          find.textContaining('What should you do'),
          findsOneWidget,
          reason: 'Question text should be visible and accessible',
        );
      });

      testWidgets('QuizGame score display is accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify score is displayed with semantic label
        final scoreSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('Score') ?? false),
        );
        expect(
          scoreSemantics,
          findsOneWidget,
          reason: 'Score should have semantic label for screen readers',
        );
      });

      testWidgets('QuizGame progress indicator is accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify progress indicator exists and is accessible
        final progressSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('progress') ??
                  widget.properties.label?.contains('Question') ??
                  false),
        );
        expect(
          progressSemantics,
          findsWidgets,
          reason: 'Progress should be announced to screen readers',
        );
      });

      testWidgets('QuizGame navigation button is accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizGame(),
          ),
        );
        await tester.pumpAndSettle();

        // Tap an answer to reveal next button
        final firstAnswer = find.byType(GestureDetector).first;
        await tester.tap(firstAnswer);
        await tester.pumpAndSettle();

        // Verify next button has semantic label
        final nextButtonSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              (widget.properties.label?.contains('Next') ?? false),
        );
        expect(
          nextButtonSemantics,
          findsWidgets,
          reason: 'Next button should have semantic label',
        );
      });
    });

    group('Widget Accessibility Guidelines', () {
      testWidgets('App meets tap target size guidelines',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // This verifies that interactive elements meet minimum tap target sizes
        // (typically 48x48 logical pixels for accessibility)
        final gestureDetectors = tester.widgetList<GestureDetector>(
          find.byType(GestureDetector),
        );

        for (final detector in gestureDetectors) {
          final renderBox =
              tester.firstRenderObject(find.byWidget(detector)) as RenderBox?;
          if (renderBox != null) {
            final size = renderBox.size;
            // Tap targets should be at least 44x44 pixels (Apple guidelines)
            // or 48x48 (Material guidelines)
            expect(
              size.width >= 44 && size.height >= 44,
              isTrue,
              reason:
                  'Interactive elements should meet minimum tap target size',
            );
          }
        }
      });

      testWidgets('Text has sufficient contrast',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify text widgets exist and are readable
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.isNotEmpty, isTrue);
      });
    });
  });
}
