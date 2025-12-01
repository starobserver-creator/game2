import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tamper_proof_score_manager.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late TamperProofScoreManager _scoreManager;
  late Future<List<ScoreEntry>> _scoresFuture;
  late Future<Map<String, dynamic>> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _scoreManager = TamperProofScoreManager();
    _scoresFuture = _scoreManager.getAllScores();
    _statisticsFuture = _scoreManager.getStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Quiz Scoreboard'),
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Statistics Section - Compact
                FutureBuilder<Map<String, dynamic>>(
                  future: _statisticsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final stats = snapshot.data!;
                    final totalAttempts = stats['totalAttempts'] as int;

                    if (totalAttempts == 0) {
                      return Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'No quiz attempts yet. Take a quiz to get started!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            enabled: false,
                            label: 'Your Statistics',
                            child: const Text(
                              'Your Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.1,
                            children: [
                              _statCard(
                                'Attempts',
                                '${stats['totalAttempts']}',
                                Colors.blue,
                              ),
                              _statCard(
                                'Avg',
                                '${(stats['averageScore'] as double).toStringAsFixed(1)}',
                                Colors.purple,
                              ),
                              _statCard(
                                'Best',
                                '${stats['bestScore']}',
                                Colors.green,
                              ),
                              _statCard(
                                'Worst',
                                '${stats['worstScore']}',
                                Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            enabled: false,
                            label: 'Average percentage: ${(stats['averagePercentage'] as double).toStringAsFixed(1)} percent',
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Average: ${(stats['averagePercentage'] as double).toStringAsFixed(1)}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Score History Section Header
                Semantics(
                  enabled: false,
                  label: 'Recent Scores',
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Recent Scores',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Score List - Compact
                Expanded(
                  child: FutureBuilder<List<ScoreEntry>>(
                    future: _scoresFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final scores = snapshot.data!;
                      return Semantics(
                        container: true,
                        label: 'Score history: ${scores.length} attempts recorded',
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: scores.length,
                          itemBuilder: (context, index) {
                          final score = scores[index];
                          final percentage = score.percentage.toStringAsFixed(0);
                          final color = score.percentage >= 70
                              ? Colors.green
                              : score.percentage >= 50
                                  ? Colors.orange
                                  : Colors.red;

                          final attemptNumber = scores.length - index;
                          final semanticsLabel = 'Attempt $attemptNumber: ${score.score} out of ${score.totalQuestions}';

                          return Semantics(
                            container: true,
                            label: semanticsLabel,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '#$attemptNumber: ${score.score}/${score.totalQuestions}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$percentage%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Semantics(
                                    button: true,
                                    label: 'Delete score',
                                    hint: 'Delete this score entry.',
                                    child: FocusableActionDetector(
                                      shortcuts: const <ShortcutActivator, Intent>{
                                        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                                        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
                                      },
                                      actions: <Type, Action<Intent>>{
                                        ActivateIntent: CallbackAction<ActivateIntent>(
                                          onInvoke: (intent) {
                                            _deleteScore(score.id);
                                            return null;
                                          },
                                        ),
                                      },
                                      child: GestureDetector(
                                        onTap: () => _deleteScore(score.id),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                    },
                  ),
                ),

                // Clear All Button
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: 'Clear all scores',
                  hint: 'Delete all quiz score records. This action cannot be undone.',
                  child: ElevatedButton.icon(
                    onPressed: _clearAllScores,
                    icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _statCard(String label, String value, Color color) {
    final semanticsLabel = '$label: $value';
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteScore(int id) {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        container: true,
        label: 'Delete score confirmation dialog',
        child: AlertDialog(
          title: const Text('Delete Score?'),
          content: const Text('Are you sure you want to delete this score?'),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel',
              hint: 'Keep this score and close dialog.',
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            Semantics(
              button: true,
              label: 'Delete',
              hint: 'Permanently remove this score.',
              child: TextButton(
                onPressed: () {
                  _scoreManager.deleteScore(id);
                  Navigator.pop(context);
                  setState(() {
                    _scoresFuture = _scoreManager.getAllScores();
                    _statisticsFuture = _scoreManager.getStatistics();
                  });
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllScores() {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        container: true,
        label: 'Clear all scores confirmation dialog',
        child: AlertDialog(
          title: const Text('Clear All Scores?'),
          content: const Text('This will delete all your quiz scores. This cannot be undone.'),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel',
              hint: 'Keep all scores and close dialog.',
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            Semantics(
              button: true,
              label: 'Clear All',
              hint: 'Permanently delete all quiz scores. This cannot be undone.',
              child: TextButton(
                onPressed: () {
                  _scoreManager.clearAllScores();
                  Navigator.pop(context);
                  setState(() {
                    _scoresFuture = _scoreManager.getAllScores();
                    _statisticsFuture = _scoreManager.getStatistics();
                  });
                },
                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}