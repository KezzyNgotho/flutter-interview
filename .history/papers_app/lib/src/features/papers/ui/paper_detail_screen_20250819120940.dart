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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PapersProvider>();
    final paper = provider.selectedPaper;
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
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      (paper['title'] ?? paper['name'] ?? 'Paper').toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Year: ${paper['year'] ?? ''}  •  Subject: ${(paper['subject']?['name'] ?? '')}',
                    ),
                    const SizedBox(height: 12),
                    if (paper['questions'] is List)
                      ...List<Widget>.from(
                        (paper['questions'] as List).asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key + 1;
                          final q = entry.value as Map? ?? {};
                          final questionText =
                              (q['question'] ?? q['text'] ?? 'Question')
                                  .toString();
                          final List<Map<String, dynamic>> answers =
                              (q['answers'] is List)
                                  ? List<Map<String, dynamic>>.from(
                                    q['answers'] as List,
                                  )
                                  : <Map<String, dynamic>>[];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$idx. $questionText'),
                                  if (_showAnswers && answers.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ...answers.map(
                                      (a) => Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            (a['is_correct'] == true)
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            size: 16,
                                            color:
                                                (a['is_correct'] == true)
                                                    ? Colors.green
                                                    : Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(a['text'].toString()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
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
