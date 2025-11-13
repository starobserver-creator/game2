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
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03, // 2% from bottom
            left: MediaQuery.of(context).size.width * -0.02,    // 2% from left
            
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,   // Reduced to 40% to ensure it fits
              height: MediaQuery.of(context).size.height * 0.4,  // Reduced to 40% to ensure it fits
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pfgreen1.png'), // Replace with your desired image
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to the Game!',
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