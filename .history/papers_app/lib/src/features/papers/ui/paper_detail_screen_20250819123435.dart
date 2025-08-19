import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../papers/state/papers_provider.dart';

class PaperDetailScreen extends StatefulWidget {
  const PaperDetailScreen({super.key});
  static const routeName = '/paper-detail';

  @override
  State<PaperDetailScreen> createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  bool _showAnswers = false;
  final Set<String> _expandedQuestionIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PapersProvider>();
    final paper = provider.selectedPaper;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(paper != null ? (paper['title'] ?? 'Paper') : 'Paper'),
        actions: [
          if (paper != null && paper['questions'] is List)
            IconButton(
              tooltip: _showAnswers ? 'Hide answers' : 'Show answers',
              icon: Icon(
                _showAnswers ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _showAnswers = !_showAnswers),
            ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : paper == null
              ? const Center(child: Text('No data'))
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(
                  children: [
                    Text(
                      (paper['title'] ?? paper['name'] ?? 'Paper').toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.calendar_month, size: 16),
                          label: Text('${paper['year'] ?? ''}'),
                          backgroundColor: cs.primaryContainer,
                          labelStyle: TextStyle(color: cs.onPrimaryContainer),
                        ),
                        if (paper['subject']?['name'] != null)
                          Chip(
                            avatar: const Icon(Icons.menu_book, size: 16),
                            label: Text(paper['subject']['name'].toString()),
                            backgroundColor: cs.secondaryContainer,
                            labelStyle:
                                TextStyle(color: cs.onSecondaryContainer),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Questions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (paper['questions'] is List)
                      ...List<Widget>.from(
                        (paper['questions'] as List).asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final q = entry.value as Map? ?? {};
                          final questionText = (q['question'] ?? q['text'] ?? 'Question').toString();
                          final String qId = (q['id']?.toString() ?? '$idx');
                          final List<Map<String, dynamic>> answers =
                              (q['answers'] is List)
                                  ? List<Map<String, dynamic>>.from(q['answers'] as List)
                                  : <Map<String, dynamic>>[];
                          final bool expanded = _showAnswers || _expandedQuestionIds.contains(qId);
                          return Card(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (_expandedQuestionIds.contains(qId)) {
                                    _expandedQuestionIds.remove(qId);
                                  } else {
                                    _expandedQuestionIds.add(qId);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cs.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('$idx', style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            questionText,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: cs.primary),
                                      ],
                                    ),
                                    if (expanded && answers.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      ...answers.map(
                                        (a) => Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceVariant.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                (a['is_correct'] == true)
                                                    ? Icons.check_circle
                                                    : Icons.radio_button_unchecked,
                                                size: 18,
                                                color: (a['is_correct'] == true) ? Colors.green : cs.outline,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(a['text'].toString())),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    else
                      Text(paper.toString()),
                  ],
                ),
              ),
    );
  }
}
