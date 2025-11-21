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
      title: 'Flutter Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            //background image
            Positioned.fill(
              child: Image.asset(
                'images/UI/background.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          //Prof Davis
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05, // % from bottom
            left: MediaQuery.of(context).size.width * -0.02,    // 2% from left
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,   // Reduced to 40% to ensure it fits
              height: MediaQuery.of(context).size.height * 0.4,  // Reduced to 40% to ensure it fits
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ProfDavisGreen/davisarm.png'), // Replace with your desired image
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
                'images/Objects/watertower.png',
                 fit: BoxFit.contain,
              ),
            ),
          ),

          //Title and Start Button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'A Greener Davis Adventure!',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizGame()), // Navigate to the game screen
                    );
                  },
                  child: const Text('Start Quiz'),
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