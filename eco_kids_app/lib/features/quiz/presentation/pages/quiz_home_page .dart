// lib/presentation/pages/quiz_home_page.dart

import 'package:flutter/material.dart';
import '../../data/quiz_service.dart';
import '../../data/question_service.dart';
import '../../domain/models/quiz_result.dart';
import 'quiz_play_page.dart';

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final QuizService _quizService = QuizService();
  final QuestionService _questionService = QuestionService();

  List<QuizResult> _history = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await _questionService.initializeDefaultQuestions();
    final allResults = await _quizService.getAllResults();
    setState(() {
      _history = allResults.take(5).toList().reversed.toList();
    });
  }

  Future<void> _startGeneralQuiz() async {
    final quiz = await _quizService.createGeneralQuiz();
    // Navigate to quiz_play_page (route should exist in app). We'll pushNamed for now.
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const QuizPlayPage(),
      settings: RouteSettings(arguments: {'quizId': quiz.id}),
    ));
  }

  Future<void> _showCustomizeSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _CustomizeQuizSheet();
      },
    );

    if (result != null && result['action'] == 'start') {
      // Map UI labels to internal category/subcategory ids
      String? categoryId;
      String? subcategoryId;
      final cat = (result['category'] ?? 'Toutes').toString();
      final sub = (result['subcategory'] ?? 'Toutes').toString();

      if (cat == 'Animaux') categoryId = 'animals';
      else if (cat == 'Plantes') categoryId = 'plants';
      else if (cat == 'Écosystèmes') categoryId = 'ecosystems';

      if (sub != 'Toutes') {
        // map some subcategory names used in QuestionService
        if (sub == 'Mammifères' || sub == 'Tous' || sub == 'mammals') subcategoryId = 'mammals';
        else if (sub == 'Oiseaux' || sub == 'birds') subcategoryId = 'birds';
        else if (sub == 'Arbres') subcategoryId = 'trees';
        else if (sub == 'Fleurs') subcategoryId = 'flowers';
        else if (sub == 'Forêts') subcategoryId = 'forests';
        else if (sub == 'Océans') subcategoryId = 'oceans';
        else subcategoryId = sub.toLowerCase();
      }

      final quiz = await _quizService.createPersonalizedQuiz(
        questionCount: result['count'] ?? 10,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
      );

      if (quiz.totalQuestions == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune question disponible pour les filtres sélectionnés.')));
        return;
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const QuizPlayPage(),
        settings: RouteSettings(arguments: {'quizId': quiz.id}),
      ));
    }
  }

  Widget _buildQuizCard({required IconData icon, required String title, required String description, required String buttonText, required VoidCallback onPressed}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(description),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(buttonText),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(QuizResult r) {
    final date = r.completedAt?.toLocal().toString().split('.').first ?? '-';
    return ListTile(
      title: Text('${r.score}/${r.totalScore} - ${r.percentage.toStringAsFixed(1)}%'),
      subtitle: Text('$date • ${r.userId}'),
      trailing: Text(r.quizId.contains('general') ? 'General' : 'Personalized'),
      onTap: () {
        Navigator.of(context).pushNamed('/quiz_result', arguments: {'resultId': r.id});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisissez votre quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuizCard(
              icon: Icons.public,
              title: 'Quiz Général',
              description: 'Questions variées sur animaux, plantes et écosystèmes',
              buttonText: 'Commencer',
              onPressed: _startGeneralQuiz,
            ),
            const SizedBox(height: 12),
            _buildQuizCard(
              icon: Icons.settings,
              title: 'Quiz Personnalisé',
              description: 'Choisissez votre catégorie et nombre de questions',
              buttonText: 'Personnaliser',
              onPressed: _showCustomizeSheet,
            ),
            const SizedBox(height: 20),
            const Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_history.isEmpty) const Text('Aucun historique'),
            ..._history.map(_buildHistoryItem).toList(),
          ],
        ),
      ),
    );
  }
}

class _CustomizeQuizSheet extends StatefulWidget {
  const _CustomizeQuizSheet({Key? key}) : super(key: key);

  @override
  State<_CustomizeQuizSheet> createState() => _CustomizeQuizSheetState();
}

class _CustomizeQuizSheetState extends State<_CustomizeQuizSheet> {
  String _category = 'Toutes';
  String _subcategory = 'Toutes';
  int _count = 10;

  final Map<String, List<String>> _subcategories = {
    'Toutes': ['Toutes'],
    'Animaux': ['Tous', 'Mammifères', 'Oiseaux'],
    'Plantes': ['Tous', 'Arbres', 'Fleurs'],
    'Écosystèmes': ['Tous', 'Forêts', 'Océans'],
  };

  @override
  Widget build(BuildContext context) {
    final subs = _subcategories[_category] ?? ['Toutes'];
    if (!subs.contains(_subcategory)) _subcategory = subs.first;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personnaliser le quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _subcategories.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Toutes'),
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _subcategory,
              items: subs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _subcategory = v ?? subs.first),
              decoration: const InputDecoration(labelText: 'Sous-catégorie'),
            ),
            const SizedBox(height: 8),
            Text('Nombre de questions: $_count'),
            Slider(
              value: _count.toDouble(),
              min: 5,
              max: 20,
              divisions: 3,
              label: '$_count',
              onChanged: (v) => setState(() => _count = v.toInt()),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({'action': 'start', 'category': _category, 'subcategory': _subcategory, 'count': _count});
                  },
                  child: const Text('Lancer le quiz'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
