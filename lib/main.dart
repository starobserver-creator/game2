import 'package:flutter/material.dart';
import 'game.dart';

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
  late Animation<double> _cloudAnimation;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _cloudAnimation = Tween<double>(begin: 1.2, end: -0.2).animate(_cloudController);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
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
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            //background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/UI/background.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            //First moving cloud
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * _cloudAnimation.value,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Image.asset(
                      'assets/images/Objects/cloud1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            //Second moving cloud offset so they loop smoothly
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: MediaQuery.of(context).size.width * (_cloudAnimation.value + 1.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Image.asset(
                      'assets/images/Objects/cloud2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            //Prof Davis
            Positioned(
              bottom:
                  MediaQuery.of(context).size.height * 0.1, // % from bottom
              left: MediaQuery.of(context).size.width * 0.02, // % from left
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.4, // Reduced to 40% to ensure it fits
                height:
                    MediaQuery.of(context).size.height *
                    0.4, // Reduced to 40% to ensure it fits
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

            //Watertower
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

            //Title and Start Button
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _outlinedTitleLine('A Greener Davis'),
                  const SizedBox(height: 8),
                  _outlinedTitleLine('Adventure!'),
                  const SizedBox(height: 24),

                  GestureDetector(
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