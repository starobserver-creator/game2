import 'package:flutter/material.dart';

class QuizGame extends StatefulWidget {
  const QuizGame({super.key});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  int? selectedAnswer;

  final List<Question> questions = [
    Question(
      questionText: "Which of these actions helps reduce your carbon footprint the most?",
      options: [
        OptionWithImage(text: "Driving a car daily", icon: Icons.directions_car),
        OptionWithImage(text: "Using public transport", icon: Icons.train),
        OptionWithImage(text: "Flying frequently", icon: Icons.flight),
        OptionWithImage(text: "Walking everywhere", icon: Icons.directions_walk),
      ],
      correctAnswer: 3,
    ),
    Question(
      questionText: "What is the most sustainable energy source?",
      options: [
        OptionWithImage(text: "Coal power", icon: Icons.factory),
        OptionWithImage(text: "Solar power", icon: Icons.wb_sunny),
        OptionWithImage(text: "Oil power", icon: Icons.oil_barrel),
        OptionWithImage(text: "Nuclear power", icon: Icons.flash_on),
      ],
      correctAnswer: 1,
    ),
    Question(
      questionText: "Which practice helps conserve water?",
      options: [
        OptionWithImage(text: "Long showers", icon: Icons.shower),
        OptionWithImage(text: "Leaving taps running", icon: Icons.water_drop),
        OptionWithImage(text: "Collecting rainwater", icon: Icons.cloud),
        OptionWithImage(text: "Washing car daily", icon: Icons.local_car_wash),
      ],
      correctAnswer: 2,
    ),
    Question(
      questionText: "What should you do with plastic bottles?",
      options: [
        OptionWithImage(text: "Throw in trash", icon: Icons.delete),
        OptionWithImage(text: "Burn them", icon: Icons.local_fire_department),
        OptionWithImage(text: "Recycle them", icon: Icons.recycling),
        OptionWithImage(text: "Bury them", icon: Icons.construction),
      ],
      correctAnswer: 2,
    ),
    Question(
      questionText: "Which food choice is most environmentally friendly?",
      options: [
        OptionWithImage(text: "Beef daily", icon: Icons.restaurant),
        OptionWithImage(text: "Local vegetables", icon: Icons.eco),
        OptionWithImage(text: "Imported fruits", icon: Icons.flight_takeoff),
        OptionWithImage(text: "Processed foods", icon: Icons.fastfood),
      ],
      correctAnswer: 1,
    ),
  ];

  void selectAnswer(int answerIndex) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answerIndex;
      isAnswered = true;
      
      if (answerIndex == questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        isAnswered = false;
        selectedAnswer = null;
      }
    });
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      isAnswered = false;
      selectedAnswer = null;
    });
  }

  bool get isQuizCompleted => currentQuestionIndex >= questions.length - 1 && isAnswered;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Sustainability Quiz'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Question counter and score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.quiz, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Question ${currentQuestionIndex + 1}/${questions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Score: $score',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Question
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 40,
                        color: Colors.green[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        questions[currentQuestionIndex].questionText,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Answer options with images
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available height for buttons
                      double availableHeight = constraints.maxHeight;
                      double buttonHeight = (availableHeight - 15) / 2; // Account for spacing
                      
                      return Column(
                        children: [
                          // First row of buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnswerButton(0, buttonHeight),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildAnswerButton(1, buttonHeight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Second row of buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnswerButton(2, buttonHeight),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildAnswerButton(3, buttonHeight),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Next/Restart button
                if (isAnswered)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      onPressed: isQuizCompleted ? restartQuiz : nextQuestion,
                      icon: Icon(
                        isQuizCompleted ? Icons.refresh : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: Text(
                        isQuizCompleted 
                          ? 'Restart Quiz (Final Score: $score/${questions.length})' 
                          : 'Next Question',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isQuizCompleted ? Colors.orange[600] : Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(int index, double height) {
    bool isCorrect = index == questions[currentQuestionIndex].correctAnswer;
    bool isSelected = selectedAnswer == index;
    
    Color buttonColor;
    Color borderColor;
    if (isAnswered) {
      if (isCorrect) {
        buttonColor = Colors.green[100]!;
        borderColor = Colors.green[600]!;
      } else if (isSelected) {
        buttonColor = Colors.red[100]!;
        borderColor = Colors.red[600]!;
      } else {
        buttonColor = Colors.grey[200]!;
        borderColor = Colors.grey[400]!;
      }
    } else {
      buttonColor = Colors.white;
      borderColor = Colors.blue[300]!;
    }
    
    return GestureDetector(
      onTap: () => selectAnswer(index),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              questions[currentQuestionIndex].options[index].icon,
              size: height * 0.3, // Dynamic icon size based on button height
              color: isAnswered 
                ? (isCorrect ? Colors.green[700] : (isSelected ? Colors.red[700] : Colors.grey[600]))
                : Colors.blue[600],
            ),
            SizedBox(height: height * 0.1), // Dynamic spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.05),
              child: Text(
                questions[currentQuestionIndex].options[index].text,
                style: TextStyle(
                  fontSize: (height * 0.12).clamp(10, 16), // Dynamic font size with limits
                  fontWeight: FontWeight.bold,
                  color: isAnswered 
                    ? (isCorrect ? Colors.green[800] : (isSelected ? Colors.red[800] : Colors.grey[700]))
                    : Colors.blue[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<OptionWithImage> options;
  final int correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

class OptionWithImage {
  final String text;
  final IconData icon;

  OptionWithImage({
    required this.text,
    required this.icon,
  });
}
