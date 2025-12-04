import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tamper_proof_score_manager.dart';
import 'end_screen.dart';
import 'keyboard_navigation.dart';
import 'main.dart';

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
  
  // Keyboard navigation
  late AnswerFocusController _answerFocusController;
  int? _keyboardFocusedAnswerIndex;
  late FocusNode _nextButtonFocusNode;
  
  // Frog chat system
  bool showFrog = true;
  String frogMessage = "Hi! I'm Professor Davis Green! 🐸 Ready to learn about sustainability?";
  late AnimationController _frogAnimationController;
  late Animation<double> _frogBounceAnimation;
  late TamperProofScoreManager _scoreManager;

  final List<Question> questions = const [
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
        _keyboardFocusedAnswerIndex = null;
        _answerFocusController.reset();
        _updateFrogMessage();
      }
    });
  }

  void restartQuiz() {
    // Save score to file with checksum validation
    _scoreManager.saveScore(
      score: score,
      totalQuestions: questions.length,
      date: DateTime.now(),
    );

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
    _scoreManager = TamperProofScoreManager();
    _initializeFrogAnimation();
    _showWelcomeMessage();
    
    // Initialize keyboard navigation
    _nextButtonFocusNode = FocusNode();
    _answerFocusController = AnswerFocusController(
      totalOptions: questions[currentQuestionIndex].options.length,
      onFocusChanged: (index) {
        setState(() {
          _keyboardFocusedAnswerIndex = index;
        });
      },
    );
  }

  @override
  void dispose() {
    _frogAnimationController.dispose();
    _nextButtonFocusNode.dispose();
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

  /// Handle keyboard answer selection (1-4 keys)
  void _handleKeyboardAnswer(int index) {
    if (isAnswered || index >= questions[currentQuestionIndex].options.length) {
      return;
    }
    setState(() {
      selectedAnswer = index;
      isAnswered = true;
      if (selectedAnswer == questions[currentQuestionIndex].correctAnswer) {
        score++;
        frogMessage = "Correct! Great job! 🎉";
      } else {
        frogMessage = "Not quite right, but you'll learn! 📚";
      }
    });
  }

  void _handleKeyboardAction() {
    if (!isAnswered) return;
    
    final isQuizCompleted = currentQuestionIndex == questions.length - 1;
    
    if (isQuizCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndScreen(
            score: score,
            totalQuestions: questions.length,
            percentage: (score / questions.length * 100),
          ),
        ),
      );
    } else {
      nextQuestion();
    }
  }

  /// Handle keyboard key events
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

    // Handle WASD and Arrow keys for answer navigation
    if (!isAnswered) {
      // Use the event's logicalKey to check for navigation keys
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        if (_answerFocusController.handleNavigationKey(LogicalKeyboardKey.arrowUp, isAnswered: isAnswered)) {
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        if (_answerFocusController.handleNavigationKey(LogicalKeyboardKey.arrowDown, isAnswered: isAnswered)) {
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        if (_answerFocusController.handleNavigationKey(LogicalKeyboardKey.arrowLeft, isAnswered: isAnswered)) {
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        if (_answerFocusController.handleNavigationKey(LogicalKeyboardKey.arrowRight, isAnswered: isAnswered)) {
          return KeyEventResult.handled;
        }
      }
    }

    // Handle number keys 1-4 for direct answer selection
    if (event.logicalKey == LogicalKeyboardKey.digit1) {
      _handleKeyboardAnswer(0);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
      _handleKeyboardAnswer(1);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
      _handleKeyboardAnswer(2);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
      _handleKeyboardAnswer(3);
      return KeyEventResult.handled;
    }

    // Handle Enter/Space for selecting focused answer or moving to next question
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (!isAnswered && _keyboardFocusedAnswerIndex != null) {
        // Select the focused answer
        _handleKeyboardAnswer(_keyboardFocusedAnswerIndex!);
        return KeyEventResult.handled;
      } else if (isAnswered) {
        // Move to next question or end screen
        _handleKeyboardAction();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyboardKey,
      autofocus: true,
      child: Scaffold(
      appBar: AppBar(
        title: const Semantics(
          label: 'Sustainability Quiz',
          header: true,
          child: Text('🌱 Sustainability Quiz'),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 65,  // Larger touch target
        centerTitle: true,
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
                    const _ProgressIndicator(),
                    const SizedBox(height: 20),
                    
                    // Question counter and score
                    _ScoreHeader(
                      currentQuestion: currentQuestionIndex + 1,
                      totalQuestions: questions.length,
                      score: score,
                    ),
                    const SizedBox(height: 30),
                    
                    // Question - Only rebuild this when question changes
                    _QuestionWidget(
                      key: ValueKey(currentQuestionIndex),
                      question: questions[currentQuestionIndex],
                      questionNumber: currentQuestionIndex + 1,
                      totalQuestions: questions.length,
                    ),
                    const SizedBox(height: 30),
                    
                    // Answer options with images - Only rebuild when question changes
                    Flexible(
                      child: _AnswerButtonsGrid(
                        key: ValueKey(currentQuestionIndex),
                        index: currentQuestionIndex,
                        isAnswered: isAnswered,
                        selectedAnswer: selectedAnswer,
                        onAnswerSelected: selectAnswer,
                        buildAnswerButton: _buildAnswerButton,
                      ),
                    ),
                    
                    // Next/Restart button
                    if (isAnswered)
                      _NextButton(
                        focusNode: _nextButtonFocusNode,
                        isQuizCompleted: isQuizCompleted,
                        onPressed: isQuizCompleted
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EndScreen(
                                      score: score,
                                      totalQuestions: questions.length,
                                      percentage:
                                          (score / questions.length * 100),
                                    ),
                                  ),
                                );
                              }
                            : nextQuestion,
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Animated Frog Overlay
          if (showFrog)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: _FrogBubble(
                message: frogMessage,
                animation: _frogBounceAnimation,
              ),
            ),
        ],
      )
      ),
    );
  }

  Widget _buildAnswerButton(int index, double height) {
    bool isCorrect = index == questions[currentQuestionIndex].correctAnswer;
    bool isSelected = selectedAnswer == index;
    bool isKeyboardFocused = _keyboardFocusedAnswerIndex == index;
    
    Color buttonColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    String accessibilityLabel;
    
    if (isAnswered) {
      if (isCorrect) {
        buttonColor = Colors.green[700]!;  // Better contrast
        borderColor = Colors.green[900]!;
        iconColor = Colors.white;
        textColor = Colors.white;
        accessibilityLabel = "Option ${index + 1}: ${questions[currentQuestionIndex].options[index].text} - Correct answer";
      } else if (isSelected) {
        buttonColor = Colors.red[700]!;  // Better contrast
        borderColor = Colors.red[900]!;
        iconColor = Colors.white;
        textColor = Colors.white;
        accessibilityLabel = "Option ${index + 1}: ${questions[currentQuestionIndex].options[index].text} - Incorrect answer";
      } else {
        buttonColor = Colors.grey[600]!;  // Better contrast
        borderColor = Colors.grey[800]!;
        iconColor = Colors.white;
        textColor = Colors.white;
        accessibilityLabel = "Option ${index + 1}: ${questions[currentQuestionIndex].options[index].text} - Not selected";
      }
    } else {
      buttonColor = Colors.blue[600]!;  // Better contrast
      borderColor = Colors.blue[800]!;
      iconColor = Colors.white;
      textColor = Colors.white;
      accessibilityLabel = "Answer option ${index + 1}: ${questions[currentQuestionIndex].options[index].text}";
    }
    
    return Semantics(
      label: accessibilityLabel,
      button: true,
      enabled: !isAnswered,
      onTap: !isAnswered ? () => selectAnswer(index) : null,
      child: FocusOutlineContainer(
        isFocused: isKeyboardFocused,
        borderRadius: BorderRadius.circular(15),
        child: GestureDetector(
          onTap: !isAnswered ? () => selectAnswer(index) : null,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter || 
                   event.logicalKey == LogicalKeyboardKey.space) && !isAnswered) {
                selectAnswer(index);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            onFocusChange: (hasFocus) {
              // Track Tab focus for Tab navigation support
              if (hasFocus && !isAnswered) {
                setState(() {
                  _keyboardFocusedAnswerIndex = index;
                });
              }
              // Provide visual feedback on focus via snackbar
              if (hasFocus && !isAnswered) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(accessibilityLabel),
                    duration: const Duration(milliseconds: 1500),
                    backgroundColor: Colors.blue[800],
                  ),
                );
              }
            },
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
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
                    semanticLabel: questions[currentQuestionIndex].options[index].text,
                  ),
                  SizedBox(height: height * 0.1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: height * 0.05),
                    child: Text(
                      questions[currentQuestionIndex].options[index].text,
                      style: TextStyle(
                        fontSize: (height * 0.14).clamp(12, 18),  // Larger font for accessibility
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
        ),
      ),
    );
  }
}

/// Question widget - only rebuilds when question changes
class _QuestionWidget extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;

  const _QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Question $questionNumber of $totalQuestions: ${question.questionText}",
      child: Container(
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
            ExcludeSemantics(
              child: Icon(
                Icons.help_outline,
                size: 40,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 16),
            ExcludeSemantics(
              child: Text(
                question.questionText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Answer buttons grid - optimized for rebuild efficiency
class _AnswerButtonsGrid extends StatelessWidget {
  final int index;
  final bool isAnswered;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final Widget Function(int, double) buildAnswerButton;

  const _AnswerButtonsGrid({
    super.key,
    required this.index,
    required this.isAnswered,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.buildAnswerButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        double buttonHeight = (availableHeight - 15) / 2;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildAnswerButton(0, buttonHeight),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildAnswerButton(1, buttonHeight),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: buildAnswerButton(2, buttonHeight),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildAnswerButton(3, buttonHeight),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Next button widget
class _NextButton extends StatefulWidget {
  final bool isQuizCompleted;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const _NextButton({
    required this.isQuizCompleted,
    required this.onPressed,
    this.focusNode,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) &&
        event is KeyDownEvent) {
      widget.onPressed();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: FocusOutlineContainer(
        isFocused: _isFocused,
        borderRadius: BorderRadius.circular(15),
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: Icon(
              widget.isQuizCompleted ? Icons.celebration : Icons.arrow_forward,
              color: Colors.white,
            ),
            label: Text(
              widget.isQuizCompleted ? 'See Results' : 'Next Question',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isQuizCompleted ? Colors.purple[600] : Colors.green[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Frog bubble widget - optimized for mobile
class _FrogBubble extends StatelessWidget {
  final String message;
  final Animation<double> animation;

  const _FrogBubble({
    required this.message,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 600;
            final maxWidth = isMobile ? screenWidth * 0.85 : screenWidth * 0.6;
            final frogSize = isMobile ? 45.0 : 50.0;
            final frogEmoji = isMobile ? 22.0 : 25.0;
            final bubbleFontSize = isMobile ? 11.0 : 12.0;
            final containerPadding = isMobile ? 12.0 : 16.0;
            
            return Semantics(
              label: 'Professor Davis Green says: $message',
              liveRegion: true,
              child: Transform.translate(
                offset: Offset(0, -animation.value),
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    color: Colors.green[50]!.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[300]!, width: 2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(containerPadding),
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: frogSize,
                            height: frogSize,
                            decoration: BoxDecoration(
                              color: Colors.green[200],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green[600]!, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '🐸',
                                style: TextStyle(fontSize: frogEmoji),
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 12,
                                vertical: isMobile ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: bubbleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                                maxLines: isMobile ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<OptionWithImage> options;
  final int correctAnswer;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

class OptionWithImage {
  final String text;
  final IconData icon;

  const OptionWithImage({
    required this.text,
    required this.icon,
  });
}

/// Progress indicator widget
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<double>(
        stream: Stream.value(0.5), // Placeholder - will be updated by parent
        builder: (context, snapshot) {
          return LinearProgressIndicator(
            value: snapshot.data ?? 0.5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
          );
        },
      ),
    );
  }
}

/// Score header widget
class _ScoreHeader extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int score;

  const _ScoreHeader({
    required this.currentQuestion,
    required this.totalQuestions,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          label: 'Currently on question $currentQuestion of $totalQuestions',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Question $currentQuestion/$totalQuestions',
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
        ),
        Semantics(
          label: 'Current score: $score out of $totalQuestions',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: ExcludeSemantics(
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
        ),
      ],
    );
  }
}

