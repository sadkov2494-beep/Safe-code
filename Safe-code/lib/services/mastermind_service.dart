class MastermindResult {
  const MastermindResult({
    required this.totalMatches,
    required this.exactMatches,
  });

  final int totalMatches;
  final int exactMatches;
}

class MastermindService {
  const MastermindService();

  MastermindResult score({required String code, required String guess}) {
    var exactMatches = 0;
    final codeCounts = <String, int>{};
    final guessCounts = <String, int>{};

    for (var index = 0; index < guess.length; index++) {
      final guessDigit = guess[index];
      if (index < code.length && code[index] == guessDigit) {
        exactMatches++;
      }
      guessCounts[guessDigit] = (guessCounts[guessDigit] ?? 0) + 1;
    }

    for (final digit in code.split('')) {
      codeCounts[digit] = (codeCounts[digit] ?? 0) + 1;
    }

    var totalMatches = 0;
    for (final entry in guessCounts.entries) {
      final codeCount = codeCounts[entry.key] ?? 0;
      totalMatches += entry.value < codeCount ? entry.value : codeCount;
    }

    return MastermindResult(
      totalMatches: totalMatches,
      exactMatches: exactMatches,
    );
  }
}
