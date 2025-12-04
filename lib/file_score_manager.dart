import 'dart:convert';
import 'dart:html' as html;

class FileScoreManager {
  static final FileScoreManager _instance = FileScoreManager._internal();
  
  factory FileScoreManager() {
    return _instance;
  }
  
  FileScoreManager._internal();

  static const String _scoresKey = 'quiz_scores';
  static const String _checksumKey = 'quiz_scores_checksum';

  /// Calculate checksum of content
  String _calculateChecksum(String content) {
    final bytes = utf8.encode(content);
    int checksum = 0;
    for (var byte in bytes) {
      checksum = ((checksum << 5) - checksum) + byte;
      checksum = checksum & checksum; // Convert to 32-bit integer
    }
    return checksum.toString();
  }

  /// Save score to localStorage
  Future<void> saveScore({
    required int score,
    required int totalQuestions,
    required DateTime date,
  }) async {
    try {
      // Read existing scores
      List<Map<String, dynamic>> scores = [];
      final scoresJson = html.window.localStorage[_scoresKey];
      if (scoresJson != null && scoresJson.isNotEmpty) {
        final jsonData = jsonDecode(scoresJson) as List;
        scores = List<Map<String, dynamic>>.from(jsonData);
      }

      // Add new score
      final percentage = (score / totalQuestions * 100);
      scores.add({
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'date': date.toIso8601String(),
      });

      // Write scores to localStorage
      final scoresContent = jsonEncode(scores);
      html.window.localStorage[_scoresKey] = scoresContent;

      // Calculate and save checksum
      final checksum = _calculateChecksum(scoresContent);
      html.window.localStorage[_checksumKey] = checksum;
    } catch (e) {
      throw Exception('Failed to save score: $e');
    }
  }

  /// Get all scores from localStorage with checksum validation
  Future<List<ScoreEntry>> getAllScores() async {
    try {
      final scoresJson = html.window.localStorage[_scoresKey];

      // Check if data exists
      if (scoresJson == null || scoresJson.isEmpty) {
        return [];
      }

      // Verify checksum
      final storedChecksum = html.window.localStorage[_checksumKey];
      if (storedChecksum != null && storedChecksum.isNotEmpty) {
        final calculatedChecksum = _calculateChecksum(scoresJson);

        if (storedChecksum != calculatedChecksum) {
          throw Exception('Score file integrity check failed');
        }
      }

      // Parse scores
      final jsonData = jsonDecode(scoresJson) as List;
      final scores = jsonData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;
        return ScoreEntry(
          id: index,
          score: data['score'] as int,
          totalQuestions: data['totalQuestions'] as int,
          percentage: data['percentage'] as double,
          date: DateTime.parse(data['date'] as String),
        );
      }).toList();

      // Sort by date descending
      scores.sort((a, b) => b.date.compareTo(a.date));
      return scores;
    } catch (e) {
      throw Exception('Failed to load scores: $e');
    }
  }

  /// Delete a specific score
  Future<void> deleteScore(int id) async {
    try {
      final scores = await getAllScores();
      scores.removeAt(id);

      // Rebuild scores list with updated IDs
      final updatedScores = scores
          .map((s) => {
                'score': s.score,
                'totalQuestions': s.totalQuestions,
                'percentage': s.percentage,
                'date': s.date.toIso8601String(),
              })
          .toList();

      final scoresContent = jsonEncode(updatedScores);
      html.window.localStorage[_scoresKey] = scoresContent;

      // Update checksum
      final checksum = _calculateChecksum(scoresContent);
      html.window.localStorage[_checksumKey] = checksum;
    } catch (e) {
      throw Exception('Failed to delete score: $e');
    }
  }

  /// Clear all scores
  Future<void> clearAllScores() async {
    try {
      html.window.localStorage.remove(_scoresKey);
      html.window.localStorage.remove(_checksumKey);
    } catch (e) {
      throw Exception('Failed to clear scores: $e');
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final scores = await getAllScores();

      if (scores.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'bestScore': 0,
          'worstScore': 0,
          'averagePercentage': 0.0,
        };
      }

      final scoreValues = scores.map((s) => s.score).toList();
      final percentages = scores.map((s) => s.percentage).toList();

      return {
        'totalAttempts': scores.length,
        'averageScore': scoreValues.reduce((a, b) => a + b) / scoreValues.length,
        'bestScore': scoreValues.reduce((a, b) => a > b ? a : b),
        'worstScore': scoreValues.reduce((a, b) => a < b ? a : b),
        'averagePercentage': percentages.reduce((a, b) => a + b) / percentages.length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}

class ScoreEntry {
  final int id;
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime date;

  ScoreEntry({
    required this.id,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.date,
  });
}
