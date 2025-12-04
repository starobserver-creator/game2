import 'package:flutter/material.dart';
import 'dart:math';
import 'main.dart';
import 'keyboard_navigation.dart';
import 'package:flutter/services.dart';

class EndScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final double percentage;

  const EndScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
  });

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<Confetti> _confetti = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Generate confetti pieces
    for (int i = 0; i < 50; i++) {
      _confetti.add(
        Confetti(
          x: _random.nextDouble(),
          y: -0.1,
          vx: (_random.nextDouble() - 0.5) * 2,
          vy: _random.nextDouble() * 3 + 2,
          rotation: _random.nextDouble() * 360,
          color: _getRandomColor(),
          size: _random.nextDouble() * 6 + 4,
        ),
      );
    }

    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Handle keyboard key events
  KeyEventResult _handleKeyboardKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Handle ESC to reset quiz and go home
    if (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyboardKey,
      autofocus: true,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[100]!,
                Colors.blue[50]!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Confetti
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      confetti: _confetti,
                      progress: _confettiController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    // Celebration emoji
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),

                    // Thank you message
                    const Text(
                      'Thanks for Playing!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 16, 0, 134),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Congratulations message
                    Text(
                      'You\'re helping save our planet! 🌍',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Score display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Final Score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.score}',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '/ ${widget.totalQuestions}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getPercentageColor(widget.percentage)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getPercentageColor(widget.percentage),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Motivational message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _getMotivationalMessage(widget.percentage),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KeyboardAccessibleButton(
                          autofocus: true,
                          semanticLabel: 'Home - Return to home screen. Press Left arrow or A to navigate.',
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[600]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green[800]!,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.home, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        KeyboardAccessibleButton(
                          semanticLabel: 'Try Again - Retake the quiz. Press Right arrow or D to navigate.',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[600]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[800]!,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 90) {
      return '🌟 Perfect! You\'re an eco-champion! Keep spreading the sustainability message!';
    } else if (percentage >= 80) {
      return '🌱 Excellent work! You know how to protect our planet!';
    } else if (percentage >= 70) {
      return '👍 Great job! You\'re on your way to becoming a sustainability expert!';
    } else if (percentage >= 60) {
      return '📚 Good effort! Keep learning more about sustainability!';
    } else if (percentage >= 50) {
      return '💪 Nice try! Every attempt helps you learn more!';
    } else {
      return '🚀 Keep practicing! Sustainability is a journey, not a destination!';
    }
  }
}

class Confetti {
  double x;
  double y;
  final double vx;
  final double vy;
  double rotation;
  final Color color;
  final double size;

  Confetti({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.color,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double progress;

  ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in confetti) {
      // Update position
      c.x += c.vx * progress * 100;
      c.y += c.vy * progress * 100;
      c.rotation += progress * 360;

      // Add gravity
      final gravityEffect = 9.8 * progress * progress * 0.5;
      final newY = c.y + gravityEffect;

      // Only draw if within bounds
      if (newY < 1.2) {
        final paint = Paint()..color = c.color;

        final dx = c.x * size.width;
        final dy = newY * size.height;

        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(c.rotation * 3.14159 / 180);
        canvas.drawCircle(Offset.zero, c.size, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
