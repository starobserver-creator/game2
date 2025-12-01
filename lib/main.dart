import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';
import 'scoreboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davis Sustainability Success',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  late AnimationController _cloudController;

  double? _screenWidth;
  double? _screenHeight;
  final Random _rand = Random();
  final List<_Cloud> _clouds = [];

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_updateClouds) // CHANGED: move clouds each tick
      ..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  // CHANGED: create several clouds at random X/Y with varying speeds
  void _initClouds() {
    final width = _screenWidth!;
    final height = _screenHeight!;

    final laneHeights = [
      height * 0.08,
      height * 0.22,
      height * 0.38,
    ];

    const int cloudCount = 8;
    for (int i = 0; i < cloudCount; i++) {
      final x = _rand.nextDouble() * width * 1.5;
      final y = laneHeights[_rand.nextInt(laneHeights.length)];
      final speed = 0.5 + _rand.nextDouble() * 1.0;
      final asset = (i % 2 == 0)
          ? 'assets/images/Objects/cloud1.png'
          : 'assets/images/Objects/cloud2.png';
      _clouds.add(_Cloud(x: x, y: y, speed: speed, asset: asset));
    }
  }

  void _updateClouds() {
    if (_screenWidth == null || _screenHeight == null || _clouds.isEmpty) {
      return;
    }

    final width = _screenWidth!;
    final cloudWidth = width * 0.15;
    final laneHeights = [
      _screenHeight! * 0.10,
      _screenHeight! * 0.17,
      _screenHeight! * 0.24,
    ];

    setState(() {
      for (final c in _clouds) {
        c.x -= c.speed;
        if (c.x < -cloudWidth) {
          c.x = width + _rand.nextDouble() * width;
          c.y = laneHeights[_rand.nextInt(laneHeights.length)];
          c.speed = 0.5 + _rand.nextDouble() * 1.0;
        }
      }
    });
  }

  Widget _buildClouds() {
    if (_screenWidth == null || _screenHeight == null || _clouds.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = _screenWidth!;
    final cloudWidth = width * 0.15;

    return Stack(
      children: _clouds
          .map(
            (c) => Positioned(
              top: c.y,
              left: c.x,
              child: SizedBox(
                width: cloudWidth,
                child: Image.asset(
                  c.asset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _outlinedTitleLine(String text) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 90,
            fontFamily: 'GrilledCheese',
            fontFamilyFallback: const ['Roboto'],
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = Colors.white,
          ),
        ),
        const SizedBox.shrink(),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 90,
            fontFamily: 'GrilledCheese',
            fontFamilyFallback: ['Roboto'],
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 16, 0, 134),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_screenWidth == null || _screenHeight == null) {
      _screenWidth = size.width;
      _screenHeight = size.height;
      _initClouds();
    }

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/UI/background.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),

            _buildClouds(),

            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.02,
              child: Semantics(
                container: true,
                excludeSemantics: true,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/ProfDavisGreen/davisarm.png',
                      ),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 40,
              right: 40,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Image.asset(
                  'assets/images/Objects/watertower.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _outlinedTitleLine('A Greener Davis'),
                  const SizedBox(height: 8),
                  _outlinedTitleLine('Adventure!'),
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'Play Quiz',
                    button: true,
                    hint: 'Starts the sustainability quiz',
                    child: FocusableActionDetector(
                      shortcuts: const <ShortcutActivator, Intent>{
                        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
                      },
                      actions: <Type, Action<Intent>>{
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (intent) {
                            setState(() => _isPressed = true);
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted) {
                                setState(() => _isPressed = false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QuizGame(),
                                  ),
                                );
                              }
                            });
                            return null;
                          },
                        ),
                      },
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() => _isPressed = true);
                        },
                        onTapUp: (_) {
                          setState(() => _isPressed = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizGame(),
                            ),
                          );
                        },
                        onTapCancel: () {
                          setState(() => _isPressed = false);
                        },
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Image.asset(
                            _isPressed
                                ? 'assets/images/UI/bplay2.png'
                                : 'assets/images/UI/bplay1.png',
                            fit: BoxFit.contain,
                            semanticLabel: 'Play button image',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    container: true,
                    label: 'View Scoreboard',
                    button: true,
                    hint: 'Opens the scoreboard screen',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScoreboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      label: const Text(
                        'View Scoreboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cloud {
  double x;
  double y;
  double speed;
  final String asset;

  _Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.asset,
  });
}