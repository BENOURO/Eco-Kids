// lib/presentation/pages/quiz_play_page.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../../data/quiz_service.dart';
import '../../domain/models/question.dart';
import 'quiz_result_page.dart';

class QuizPlayPage extends StatefulWidget {
  const QuizPlayPage({Key? key}) : super(key: key);

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  final QuizService _quizService = QuizService();
  List<Question> _questions = [];
  bool _loading = true;
  String _quizId = '';
  final Map<String, List<String>> _shuffledOptions = {};
  final Random _rand = Random();

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, String> _answers = {}; // questionId -> selected answer
  DateTime? _startTime;

  Timer? _ticker; // <-- added: timer to refresh elapsed time display

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupération sûre des arguments de la route (évite un cast direct qui peut planter)
    final dynamic rawArgs = ModalRoute.of(context)?.settings.arguments;
    String quizId = '';
    if (rawArgs is Map<String, dynamic>) {
      quizId = rawArgs['quizId']?.toString() ?? '';
    } else if (rawArgs is Map) {
      // couverture au cas où l'argument est une Map non typée
      quizId = rawArgs['quizId']?.toString() ?? '';
    }
    if (_quizId != quizId) {
      _quizId = quizId;
      // Ne charger que si on a un quizId valide
      if (_quizId.isNotEmpty) _loadQuestions();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (_quizId.isEmpty) return; // protection supplémentaire
    setState(() {
      _loading = true;
    });
    try {
      final q = await _quizService.getQuizQuestions(_quizId);
      setState(() {
        _questions = q;
        _startTime = DateTime.now();
        _currentIndex = 0;
        _answers.clear();
        _shuffledOptions.clear();
        // Prepare shuffled options per question so order is stable during the quiz
        for (final ques in _questions) {
          final opts = List<String>.from(ques.options);
          // Shuffle deterministically using our Random instance
          for (int i = opts.length - 1; i > 0; i--) {
            final j = _rand.nextInt(i + 1);
            final tmp = opts[i];
            opts[i] = opts[j];
            opts[j] = tmp;
          }
          _shuffledOptions[ques.id] = opts;
        }
      });

      // start or restart the ticker to refresh elapsed time every second
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _selectAnswer(String questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  Future<void> _submitQuiz() async {
    // offer confirmation if some unanswered
    final unanswered = _questions.where((q) => !(_answers.containsKey(q.id) && _answers[q.id]!.isNotEmpty)).length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Soumettre le quiz'),
        content: Text(unanswered > 0 ? 'Il reste $unanswered question(s) sans réponse. Souhaitez-vous soumettre ?' : 'Souhaitez-vous soumettre vos réponses ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Soumettre')),
        ],
      ),
    );

    if (confirm != true) return;

    final timeSpent = _startTime == null ? 0 : DateTime.now().difference(_startTime!).inSeconds;
    final result = await _quizService.submitQuiz(quizId: _quizId, answers: _answers, timeSpent: timeSpent);

    // navigate to result page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const QuizResultPage(),
      settings: RouteSettings(arguments: {'resultId': result.id}),
    ));
  }

  void _goTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  String _cleanQuestionText(String text) {
    final r = RegExp(r'^\s*#\d+\s*([.\-:]\s*)?');
    return text.replaceFirst(r, '').trim();
  }

  // Retourne une lettre A/B/C... pour l'index d'option
  String _letterForIndex(int i) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    if (i >= 0 && i < letters.length) return letters[i];
    return String.fromCharCode(65 + i);
  }

  // Formatte une durée en mm:ss ou hh:mm:ss
  String _formattedDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '${d.inMinutes.remainder(60).toString()}:$seconds';
  }

  // Libellé lisible pour l'enum QuestionType
  String _typeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.image_choice:
        return 'Image';
      case QuestionType.text_choice:
        return 'Texte';
      case QuestionType.true_false:
        return 'Vrai/Faux';
    }
  }

  // Improved option tile: animated, shadow, circular letter badge, nicer select indicator
  Widget _buildOptionTile(Question q, String opt, int optIndex) {
    final selected = _answers[q.id] == opt;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final scale = selected ? 1.03 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.diagonal3Values(scale, scale, 1),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? primary.withAlpha(242) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [BoxShadow(color: primary.withAlpha(46), blurRadius: 14, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 3))],
        border: Border.all(color: selected ? primary : Colors.grey.shade200, width: selected ? 1.6 : 1),
      ),
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Option ${_letterForIndex(optIndex)}: ${opt.replaceAll(RegExp(r'\s+'), ' ')}',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectAnswer(q.id, opt),
          splashColor: primary.withAlpha(31),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                // Circular letter badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.white : Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      _letterForIndex(optIndex),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected ? primary : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.check_circle, color: selected ? Colors.white : Colors.transparent, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _elapsedText() {
    if (_startTime == null) return '—';
    final elapsed = DateTime.now().difference(_startTime!);
    return _formattedDuration(elapsed);
  }

  Widget _buildHeaderCard() {
    final total = _questions.isEmpty ? 1 : _questions.length;
    final current = (_currentIndex + 1).clamp(1, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
          child: Row(
            children: [
              // Circular progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: current / total,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  Text('$current/$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_questions.isNotEmpty)
                      Text(_cleanQuestionText(_questions[_currentIndex].questionText), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text('Temps: ${_elapsedText()}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(width: 12),
                        Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        if (_questions.isNotEmpty) Text(_typeLabel(_questions[_currentIndex].type), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: _currentIndex > 0 ? () => _goTo(_currentIndex - 1) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _currentIndex < _questions.length - 1 ? () => _goTo(_currentIndex + 1) : null,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: BackButton(color: Theme.of(context).colorScheme.primary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _questions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _submitQuiz,
              label: const Text('Soumettre'),
              icon: const Icon(Icons.check),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_questions.isEmpty
                ? const Center(child: Text('Aucune question pour ce quiz.'))
                : Column(
                    children: [
                      // Replaced header with improved design
                      _buildHeaderCard(),

                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _questions.length,
                          onPageChanged: (idx) => setState(() => _currentIndex = idx),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final q = _questions[index];
                            final displayOptions = _shuffledOptions[q.id] ?? q.options;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question card with smooth transition
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 350),
                                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                                    child: Card(
                                      key: ValueKey(q.id),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (q.imagePath != null && q.imagePath!.isNotEmpty)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.asset(
                                                  q.imagePath!,
                                                  height: 220,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) => Container(
                                                    height: 200,
                                                    color: Colors.grey.shade200,
                                                    child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400)),
                                                  ),
                                                ),
                                              ),
                                            if (q.imagePath != null && q.imagePath!.isNotEmpty) const SizedBox(height: 12),
                                            Text(_cleanQuestionText(q.questionText), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                            const SizedBox(height: 12),

                                            // Options
                                            Column(
                                              children: List.generate(displayOptions.length, (i) => _buildOptionTile(q, displayOptions[i], i)),
                                            ),

                                            const SizedBox(height: 10),
                                            if (q.explanation.isNotEmpty && _answers.containsKey(q.id) && _answers[q.id]!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text('Explication: ${q.explanation}', style: const TextStyle(color: Colors.grey)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  // Quick navigation dots (animated)
                                  Center(
                                    child: Wrap(
                                      spacing: 8,
                                      children: List.generate(_questions.length, (i) {
                                        final answered = _answers.containsKey(_questions[i].id) && _answers[_questions[i].id]!.isNotEmpty;
                                        final isCurrent = i == _currentIndex;
                                        return GestureDetector(
                                          onTap: () => _goTo(i),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 220),
                                            width: isCurrent ? 18 : 12,
                                            height: isCurrent ? 18 : 12,
                                            decoration: BoxDecoration(
                                              color: isCurrent ? Theme.of(context).colorScheme.primary : (answered ? Colors.green : Colors.grey.shade300),
                                              shape: BoxShape.circle,
                                              boxShadow: isCurrent ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha(61), blurRadius: 8, offset: const Offset(0,4))] : null,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),

                                  const SizedBox(height: 40),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom actions (styled)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentIndex > 0 ? () => _goTo(_currentIndex - 1) : null,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Précédent'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _currentIndex < _questions.length - 1
                                  ? ElevatedButton.icon(
                                      onPressed: () => _goTo(_currentIndex + 1),
                                      icon: const Icon(Icons.arrow_forward),
                                      label: const Text('Suivant'),
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _submitQuiz,
                                      icon: const Icon(Icons.check),
                                      label: const Text('Soumettre'),
                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Theme.of(context).colorScheme.primary),
                                    ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
      ),
    );
  }
}
