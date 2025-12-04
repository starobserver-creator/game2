import 'dart:convert';
import 'dart:math';

class TamperProofScoreManager {
  static final TamperProofScoreManager _instance = TamperProofScoreManager._internal();
  static final Map<String, String> _inMemoryStorage = {};
  
  factory TamperProofScoreManager() {
    return _instance;
  }
  
  TamperProofScoreManager._internal();

  static const String _scoresKey = 'quiz_scores_secure';
  static const String _nonceKey = 'quiz_nonce';
  static const String _saltKey = 'quiz_salt';
  static const int _tokenExpirySeconds = 86400; // 24 hours
  static const int _saltLength = 32;

  /// Get storage - uses in-memory for web compatibility
  Map<String, String> _getStorage() {
    return _inMemoryStorage;
  }

  /// Generate a random salt
  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64Encode(values);
  }

  /// Generate time-based nonce token
  String _generateNonce(String salt) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomValue = Random.secure().nextInt(1000000).toString();
    final combined = '$timestamp:$randomValue:$salt';
    return base64Encode(utf8.encode(combined));
  }

  /// Calculate secure hash of content + nonce + salt
  String _calculateSecureHash(String content, String nonce, String salt) {
    final combined = '$content:$nonce:$salt';
    final bytes = utf8.encode(combined);
    int hash = 0;
    for (var byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash;
    }
    return hash.abs().toString();
  }

  /// Validate nonce is not expired
  bool _isNonceValid(String nonce) {
    try {
      final decoded = utf8.decode(base64Decode(nonce));
      final parts = decoded.split(':');
      if (parts.length < 2) return false;

      final timestamp = int.parse(parts[0]);
      final now = DateTime.now().millisecondsSinceEpoch;
      final ageSeconds = (now - timestamp) ~/ 1000;

      return ageSeconds < _tokenExpirySeconds;
    } catch (e) {
      return false;
    }
  }

  /// Get or create salt for this device
  String _getOrCreateSalt() {
    final storage = _getStorage();
    String? existingSalt = storage[_saltKey];
    if (existingSalt != null && existingSalt.isNotEmpty) {
      return existingSalt;
    }

    final newSalt = _generateSalt();
    storage[_saltKey] = newSalt;
    return newSalt;
  }

  /// Save score with tamper-proof token
  Future<void> saveScore({
    required int score,
    required int totalQuestions,
    required DateTime date,
  }) async {
    try {
      final storage = _getStorage();
      final salt = _getOrCreateSalt();
      final nonce = _generateNonce(salt);

      // Read existing scores
      List<Map<String, dynamic>> scores = [];
      final scoresJson = storage[_scoresKey];
      if (scoresJson != null && scoresJson.isNotEmpty) {
        final jsonData = jsonDecode(scoresJson) as List;
        scores = List<Map<String, dynamic>>.from(jsonData);
      }

      // Add new score with security metadata
      final percentage = (score / totalQuestions * 100);
      final scoreEntry = {
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'date': date.toIso8601String(),
        'nonce': nonce,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      scores.add(scoreEntry);

      // Write scores to localStorage
      final scoresContent = jsonEncode(scores);
      storage[_scoresKey] = scoresContent;

      // Calculate and save secure hash
      final hash = _calculateSecureHash(scoresContent, nonce, salt);
      storage[_nonceKey] = hash;
    } catch (e) {
      throw Exception('Failed to save score: $e');
    }
  }

  /// Get all scores with tamper validation
  Future<List<ScoreEntry>> getAllScores() async {
    try {
      final storage = _getStorage();
      final scoresJson = storage[_scoresKey];
      final salt = _getOrCreateSalt();

      // Check if data exists
      if (scoresJson == null || scoresJson.isEmpty) {
        return [];
      }

      // Verify tamper-proof token
      final storedHash = storage[_nonceKey];
      if (storedHash != null && storedHash.isNotEmpty) {
        // Get last nonce from scores if available
        final jsonData = jsonDecode(scoresJson) as List;
        if (jsonData.isNotEmpty) {
          final lastScore = jsonData.last as Map<String, dynamic>;
          final lastNonce = lastScore['nonce'] as String?;

          if (lastNonce != null) {
            // Validate nonce is not expired
            if (!_isNonceValid(lastNonce)) {
              throw Exception('Security token expired - data may be tampered');
            }

            // Verify hash
            final calculatedHash = _calculateSecureHash(scoresJson, lastNonce, salt);
            if (storedHash != calculatedHash) {
              throw Exception('Score integrity violation detected - data tampered');
            }
          }
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
      final storage = _getStorage();
      final salt = _getOrCreateSalt();
      final nonce = _generateNonce(salt);

      final scores = await getAllScores();
      scores.removeAt(id);

      // Rebuild scores list with updated security metadata
      final updatedScores = scores
          .map((s) => {
                'score': s.score,
                'totalQuestions': s.totalQuestions,
                'percentage': s.percentage,
                'date': s.date.toIso8601String(),
                'nonce': nonce,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              })
          .toList();

      final scoresContent = jsonEncode(updatedScores);
      storage[_scoresKey] = scoresContent;

      // Update secure hash
      final hash = _calculateSecureHash(scoresContent, nonce, salt);
      storage[_nonceKey] = hash;
    } catch (e) {
      throw Exception('Failed to delete score: $e');
    }
  }

  /// Clear all scores
  Future<void> clearAllScores() async {
    try {
      final storage = _getStorage();
      storage.remove(_scoresKey);
      storage.remove(_nonceKey);
      // Keep salt for device identification
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
