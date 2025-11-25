import 'package:flutter/material.dart';

class QuizGame extends StatefulWidget {
  const QuizGame({super.key});

  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  int? selectedAnswer;
  
  // Frog chat system
  bool showFrog = true;
  String frogMessage = "Hi! I'm Professor Davis Green! 🐸 Ready to learn about sustainability?";
  late AnimationController _frogAnimationController;
  late Animation<double> _frogBounceAnimation;

  final List<Question> questions = [
    // Stormwater
    Question(
      questionText: "🗑️ What should you do if you accidentally drop trash on the ground?",
      options: [
        OptionWithImage(text: "Pick it up right away", icon: Icons.cleaning_services),
        OptionWithImage(text: "Leave it for someone else", icon: Icons.block),
        OptionWithImage(text: "Push it into the gutter", icon: Icons.water),
        OptionWithImage(text: "Ignore it", icon: Icons.close),
      ],
      correctAnswer: 0,
    ),
    Question(
      questionText: "♻️ After you put something in your outdoor trash bin, what should you do?",
      options: [
        OptionWithImage(text: "Leave the lid open", icon: Icons.open_in_full),
        OptionWithImage(text: "Make sure the trash bin lid closes completely", icon: Icons.done),
        OptionWithImage(text: "Tip it over", icon: Icons.warning),
        OptionWithImage(text: "Leave it for days", icon: Icons.schedule),
      ],
      correctAnswer: 1,
    ),
    // Water Conservation
    Question(
      questionText: "💧 What should you do if you find a leaky faucet?",
      options: [
        OptionWithImage(text: "Ignore it", icon: Icons.close),
        OptionWithImage(text: "Tell someone so it can get repaired", icon: Icons.report),
        OptionWithImage(text: "Let it drip forever", icon: Icons.water_drop),
        OptionWithImage(text: "Cover it with bandage", icon: Icons.medical_services),
      ],
      correctAnswer: 1,
    ),
    Question(
      questionText: "🌱 What is the best time to water your yard?",
      options: [
        OptionWithImage(text: "Midday", icon: Icons.wb_sunny),
        OptionWithImage(text: "Early morning or at night", icon: Icons.nights_stay),
        OptionWithImage(text: "During rain", icon: Icons.cloud_queue),
        OptionWithImage(text: "Never", icon: Icons.block),
      ],
      correctAnswer: 1,
    ),
    // Recycling
    Question(
      questionText: "📦 What should you do with a large empty cardboard box?",
      options: [
        OptionWithImage(text: "Throw it in the trash", icon: Icons.delete),
        OptionWithImage(text: "Burn it", icon: Icons.local_fire_department),
        OptionWithImage(text: "Flatten it and place it next to the recycling cart", icon: Icons.recycling),
        OptionWithImage(text: "Leave it on the street", icon: Icons.block),
      ],
      correctAnswer: 2,
    ),
    Question(
      questionText: "🍎 What should you do with an apple core?",
      options: [
        OptionWithImage(text: "Throw in trash", icon: Icons.delete),
        OptionWithImage(text: "Place it in the organics bin", icon: Icons.compost),
        OptionWithImage(text: "Leave it outside", icon: Icons.forest),
        OptionWithImage(text: "Flush it down toilet", icon: Icons.water),
      ],
      correctAnswer: 1,
    ),
    Question(
      questionText: "🔄 Which statement is true about recycling?",
      options: [
        OptionWithImage(text: "Bag all your recyclables", icon: Icons.shopping_bag),
        OptionWithImage(text: "Don't bag recyclables – place them loose in the cart", icon: Icons.recycling),
        OptionWithImage(text: "Mix recyclables with trash", icon: Icons.merge),
        OptionWithImage(text: "Recycle only sometimes", icon: Icons.schedule),
      ],
      correctAnswer: 1,
    ),
    // IPM (Integrated Pest Management)
    Question(
      questionText: "🐛 Which statement is true?",
      options: [
        OptionWithImage(text: "All insects are bad and harmful", icon: Icons.bug_report),
        OptionWithImage(text: "Not all insects are bad – many are helpful", icon: Icons.pets),
        OptionWithImage(text: "Insects don't matter", icon: Icons.block),
        OptionWithImage(text: "You should kill all insects", icon: Icons.warning),
      ],
      correctAnswer: 1,
    ),
    Question(
      questionText: "🌳 If you have a fruit tree at home, what should you do?",
      options: [
        OptionWithImage(text: "Leave fallen fruit on the ground", icon: Icons.forest),
        OptionWithImage(text: "Pick up fallen fruit to prevent pests", icon: Icons.agriculture),
        OptionWithImage(text: "Pour chemicals on the tree", icon: Icons.warning),
        OptionWithImage(text: "Cut down the tree", icon: Icons.close),
      ],
      correctAnswer: 1,
    ),
    // Pretreatment
    Question(
      questionText: "🍳 What should you do with extra oils and grease after cooking?",
      options: [
        OptionWithImage(text: "Pour down the sink", icon: Icons.water),
        OptionWithImage(text: "Wipe up with paper towels and place in organics bin", icon: Icons.cleaning_services),
        OptionWithImage(text: "Flush down toilet", icon: Icons.water),
        OptionWithImage(text: "Leave on counter", icon: Icons.block),
      ],
      correctAnswer: 1,
    ),
    Question(
      questionText: "🚽 Is it OK to flush wipes down the toilet?",
      options: [
        OptionWithImage(text: "Yes, all wipes are flushable", icon: Icons.done),
        OptionWithImage(text: "No, the toilet is not a trash can. Only flush poo, pee and toilet paper.", icon: Icons.block),
        OptionWithImage(text: "Only flush some wipes", icon: Icons.schedule),
        OptionWithImage(text: "Yes, it doesn't matter", icon: Icons.close),
      ],
      correctAnswer: 1,
    ),
    // Wildlife
    Question(
      questionText: "🦆 Is it ok to feed ducks and geese at a pond?",
      options: [
        OptionWithImage(text: "Yes, they love bread", icon: Icons.restaurant),
        OptionWithImage(text: "Yes, all food is good for them", icon: Icons.done),
        OptionWithImage(text: "No, never feed wild animals, it does more harm than good.", icon: Icons.block),
        OptionWithImage(text: "Only feed sometimes", icon: Icons.schedule),
      ],
      correctAnswer: 2,
    ),
    // Water Quality
    Question(
      questionText: "🥤 What's the better environmental choice?",
      options: [
        OptionWithImage(text: "Buy lots of bottled water", icon: Icons.shopping_cart),
        OptionWithImage(text: "Drink tap water instead of buying bottled water", icon: Icons.water_drop),
        OptionWithImage(text: "Use plastic bottles", icon: Icons.warning),
        OptionWithImage(text: "All water sources are the same", icon: Icons.block),
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
    
    // Show frog feedback after answer is selected
    _updateFrogMessage();
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
  void initState() {
    super.initState();
    _initializeFrogAnimation();
    _showWelcomeMessage();
  }

  @override
  void dispose() {
    _frogAnimationController.dispose();
    super.dispose();
  }

  void _initializeFrogAnimation() {
    _frogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _frogBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _frogAnimationController,
      curve: Curves.easeInOut,
    ));
    _frogAnimationController.repeat(reverse: true);
  }

  void _showWelcomeMessage() {
    setState(() {
      showFrog = true;
      frogMessage = "Hi! I'm Professor Davis Green! 🐸 Ready to learn about sustainability?";
    });
  }

  void _updateFrogMessage() {
    if (!isAnswered) return;
    
    bool isCorrect = selectedAnswer == questions[currentQuestionIndex].correctAnswer;
    List<String> correctMessages = [
      "Great job! 🌟 You're helping save our planet!",
      "Excellent choice! 🌱 Mother Earth thanks you!",
      "Perfect! 🎉 You're a true eco-warrior!",
      "Amazing! 🌿 That's the sustainable way!",
      "Wonderful! 🌍 Every green choice matters!",
    ];
    
    List<String> incorrectMessages = [
      "Oops! 🤔 Let's think more sustainably next time!",
      "Not quite! 🌱 But learning is part of the journey!",
      "Close! 🐸 Remember, small changes make big differences!",
      "Try again! 🌿 Every mistake helps us grow greener!",
      "Keep trying! 🌍 You're learning to protect our planet!",
    ];

    setState(() {
      showFrog = true;
      if (isCorrect) {
        frogMessage = correctMessages[currentQuestionIndex % correctMessages.length];
      } else {
        frogMessage = incorrectMessages[currentQuestionIndex % incorrectMessages.length];
      }
    });

    // Hide frog after 2.5 seconds instead of 3 for faster feedback
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          showFrog = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Sustainability Quiz'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
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
                    Semantics(
                      label: 'Quiz progress: Question ${currentQuestionIndex + 1} of ${questions.length}',
                      value: '${((currentQuestionIndex + 1) / questions.length * 100).round()}%',
                      child: Container(
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
                    ),
                    const SizedBox(height: 20),
                    
                    // Question counter and score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          label: 'Question ${currentQuestionIndex + 1} of ${questions.length}',
                          child: Container(
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
                        ),
                        Semantics(
                          label: 'Score: $score points',
                          child: Container(
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
                          double availableHeight = constraints.maxHeight;
                          double buttonHeight = (availableHeight - 15) / 2;
                          
                          return Column(
                            children: [
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
                      Semantics(
                        button: true,
                        label: isQuizCompleted 
                          ? 'Restart Quiz. Your final score is $score out of ${questions.length}' 
                          : 'Next Question',
                        hint: isQuizCompleted
                          ? 'Double tap to restart the quiz'
                          : 'Double tap to go to the next question',
                        child: Container(
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
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Animated Frog Overlay
          if (showFrog)
            Positioned(
              bottom: 100,
              left: 20,
              child: Semantics(
                liveRegion: true,
                label: 'Professor Davis Green says: $frogMessage',
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _frogBounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_frogBounceAnimation.value),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[300]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Frog Character
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.green[200],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green[600]!, width: 2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🐸',
                                      style: TextStyle(fontSize: 30),
                                      semanticsLabel: 'Professor Davis Green frog mascot',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Speech Bubble
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      frogMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int index, double height) {
    bool isCorrect = index == questions[currentQuestionIndex].correctAnswer;
    bool isSelected = selectedAnswer == index;
    
    Color buttonColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    
    if (isAnswered) {
      if (isCorrect) {
        buttonColor = Colors.green[100]!;
        borderColor = Colors.green[600]!;
        iconColor = Colors.green[700]!;
        textColor = Colors.green[800]!;
      } else if (isSelected) {
        buttonColor = Colors.red[100]!;
        borderColor = Colors.red[600]!;
        iconColor = Colors.red[700]!;
        textColor = Colors.red[800]!;
      } else {
        buttonColor = Colors.grey[200]!;
        borderColor = Colors.grey[400]!;
        iconColor = Colors.grey[600]!;
        textColor = Colors.grey[700]!;
      }
    } else {
      buttonColor = Colors.white;
      borderColor = Colors.blue[300]!;
      iconColor = Colors.blue[600]!;
      textColor = Colors.blue[800]!;
    }

    // Build semantic hint based on state
    String semanticHint;
    if (isAnswered) {
      if (isCorrect) {
        semanticHint = 'Correct answer';
      } else if (isSelected) {
        semanticHint = 'Incorrect answer - you selected this';
      } else {
        semanticHint = 'Option ${index + 1}';
      }
    } else {
      semanticHint = 'Double tap to select this answer';
    }
    
    return Semantics(
      button: true,
      enabled: !isAnswered,
      label: 'Answer option ${index + 1}: ${questions[currentQuestionIndex].options[index].text}',
      hint: semanticHint,
      child: GestureDetector(
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
                size: height * 0.3,
                color: iconColor,
              ),
              SizedBox(height: height * 0.1),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: height * 0.05),
                child: Text(
                  questions[currentQuestionIndex].options[index].text,
                  style: TextStyle(
                    fontSize: (height * 0.12).clamp(10, 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
