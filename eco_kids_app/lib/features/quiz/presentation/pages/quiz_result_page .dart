// lib/presentation/pages/quiz_result_page.dart

import 'package:flutter/material.dart';
import '../../data/quiz_service.dart';
import '../../domain/models/quiz_result.dart';
import '../../domain/models/question.dart';
import 'quiz_play_page.dart';

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({Key? key}) : super(key: key);

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  final QuizService _quizService = QuizService();
  QuizResult? _result;
  List<Question> _questions = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final resultId = args?['resultId']?.toString() ?? '';

    if (resultId.isNotEmpty && _result == null) {
      _loadResult(resultId);
    }
  }

  Future<void> _loadResult(String resultId) async {
    setState(() => _loading = true);

    final r = await _quizService.getResultById(resultId);
    if (r != null) {
      final raw = await _quizService.getQuizQuestions(r.quizId);

      // Remove duplicated questions
      final unique = <String, Question>{};
      for (final q in raw) {
        unique.putIfAbsent(q.id, () => q);
      }

      setState(() {
        _result = r;
        _questions = unique.values.toList();
      });
    }

    setState(() => _loading = false);
  }

  Future<void> _retakeQuiz() async {
    if (_result == null) return;

    final quiz = await _quizService.getQuizById(_result!.quizId);
    if (quiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quiz original introuvable")),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QuizPlayPage(),
        settings: RouteSettings(arguments: {'quizId': quiz.id}),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  String _cleanQuestionText(String text) {
    final r = RegExp(r'^\s*#\d+\s*([.\-:]\s*)?');
    return text.replaceFirst(r, '').trim();
  }

  bool _isSameAnswer(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text("Résultat du Quiz"),
        centerTitle: true,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_result == null
          ? const Center(child: Text("Résultat introuvable"))
          : _buildResultBody(primary)),
    );
  }

  Widget _buildResultBody(Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(primary),
          const SizedBox(height: 16),
          const Text(
            "Détails des questions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._buildQuestionDetails(primary),
        ],
      ),
    );
  }

  /// ------------------- SUMMARY CARD --------------------
  Widget _buildSummaryCard(Color primary) {
    final r = _result!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(.15), Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildPercentageCircle(primary, r),
              const SizedBox(width: 16),
              _buildScoreAndStats(primary, r),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryButtons(primary),
        ],
      ),
    );
  }

  Widget _buildPercentageCircle(Color primary, QuizResult r) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withOpacity(.2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${r.percentage.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${r.correctAnswers}/${r.totalQuestions}",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreAndStats(Color primary, QuizResult r) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: primary),
              const SizedBox(width: 8),
              Text(
                "${r.score}/${r.totalScore}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: r.totalQuestions == 0 ? 0 : (r.correctAnswers / r.totalQuestions),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(primary),
          ),
          const SizedBox(height: 10),
          Text("Temps: ${_formatDuration(r.timeSpent)}", style: const TextStyle(color: Colors.black54)),
          Text("Terminé: ${r.completedAt?.toLocal().toString().split('.').first ?? '-'}",
              style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSummaryButtons(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home),
          label: const Text("Accueil"),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _retakeQuiz,
          icon: const Icon(Icons.replay),
          label: const Text("Refaire"),
          style: ElevatedButton.styleFrom(backgroundColor: primary),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text("Partager"),
        ),
      ],
    );
  }

  /// ------------------- QUESTION DETAILS --------------------
  List<Widget> _buildQuestionDetails(Color primary) {
    final widgets = <Widget>[];

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final userAns = _result!.answers[q.id] ?? '';
      final correct = q.correctAnswer;
      final isCorrect = userAns.isNotEmpty && _isSameAnswer(userAns, correct);

      widgets.add(_buildQuestionCard(i, q, userAns, correct, isCorrect));
    }

    return widgets;
  }

  Widget _buildQuestionCard(
      int index,
      Question q,
      String userAns,
      String correct,
      bool isCorrect,
      ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(12),
        childrenPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green : Colors.red),
        ),
        title: Text(_cleanQuestionText(q.questionText)),
        subtitle: Text("Question ${index + 1}", style: const TextStyle(fontSize: 12)),
        children: [
          if (q.imagePath?.isNotEmpty == true)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                q.imagePath!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          const SizedBox(height: 10),

          ..._buildOptions(q, userAns, correct),

          const SizedBox(height: 8),
          Text("Votre réponse: ${userAns.isEmpty ? '- (non répondu)' : userAns}"),
          if (!isCorrect) Text("Réponse correcte: $correct", style: const TextStyle(fontWeight: FontWeight.bold)),
          if (q.explanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Explication: ${q.explanation}", style: const TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(Question q, String userAns, String correct) {
    return List.generate(q.options.length, (i) {
      final opt = q.options[i];
      final isUser = _isSameAnswer(opt, userAns);
      final isCorrect = _isSameAnswer(opt, correct);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade50 : (isUser ? Colors.red.shade50 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCorrect
                ? Colors.green
                : isUser
                ? Colors.red
                : Colors.grey.shade300,
            width: (isCorrect || isUser) ? 1.6 : 1,
          ),
        ),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: isCorrect ? Colors.green : (isUser ? Colors.red : Colors.grey.shade300),
            child: Text(_optionLetter(i), style: const TextStyle(color: Colors.white)),
          ),
          title: Text(
            opt,
            style: TextStyle(
              fontWeight: isCorrect || isUser ? FontWeight.bold : FontWeight.normal,
              color: isCorrect ? Colors.green.shade900 : (isUser ? Colors.red.shade900 : Colors.black87),
            ),
          ),
          subtitle: isCorrect ? const Text("Bonne réponse", style: TextStyle(color: Colors.green)) : null,
        ),
      );
    });
  }

  String _optionLetter(int index) {
    const letters = ["A", "B", "C", "D", "E", "F"];
    return index < letters.length ? letters[index] : String.fromCharCode(65 + index);
  }
}
