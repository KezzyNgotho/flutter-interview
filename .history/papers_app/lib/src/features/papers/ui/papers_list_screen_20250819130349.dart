import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../papers/state/papers_provider.dart';
import 'paper_detail_screen.dart';

class PapersListScreen extends StatefulWidget {
  const PapersListScreen({super.key});
  static const routeName = '/papers';

  @override
  State<PapersListScreen> createState() => _PapersListScreenState();
}

class _PapersListScreenState extends State<PapersListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final p = context.read<PapersProvider>();
      await p.loadPapers();
      await p.loadSubjects();
      await p.loadStudiedFromCache();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PapersProvider>();

    // Build dynamic year options from currently loaded papers
    final Set<String> yearSet = {
      for (final item in provider.papers)
        if (item is Map && item['year'] != null) item['year'].toString(),
    };
    final List<String> yearOptions =
        yearSet.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Papers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                provider.isLoading
                    ? null
                    : () => context.read<PapersProvider>().loadPapers(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search papers...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                provider.setSearchQuery(v);
                provider.loadPapers();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: provider.selectedYear,
                    hint: const Text('All years'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All years'),
                      ),
                      ...yearOptions.map(
                        (y) =>
                            DropdownMenuItem<String?>(value: y, child: Text(y)),
                      ),
                    ],
                    onChanged: (val) {
                      context.read<PapersProvider>().setSelectedYear(val);
                      context.read<PapersProvider>().loadPapers();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: provider.selectedSubjectId,
                    hint: const Text('All subjects'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All subjects'),
                      ),
                      ...provider.subjects.map((s) {
                        final id =
                            s is Map ? s['id']?.toString() : s.toString();
                        final name =
                            s is Map
                                ? (s['name']?.toString() ?? id)
                                : s.toString();
                        return DropdownMenuItem<String?>(
                          value: id,
                          child: Text(name),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      context.read<PapersProvider>().setSelectedSubject(val);
                      context.read<PapersProvider>().loadPapers();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child:
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh:
                          () => context.read<PapersProvider>().loadPapers(),
                      child: ListView.separated(
                        itemCount: provider.filteredPapers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (itemContext, index) {
                          final paper = provider.filteredPapers[index];
                          final title = provider.getPaperTitle(paper);
                          final id =
                              (paper is Map)
                                  ? (paper['id']?.toString() ?? '$index')
                                  : '$index';
                          final year =
                              (paper is Map)
                                  ? (paper['year']?.toString() ?? '')
                                  : '';
                          final subject =
                              (paper is Map)
                                  ? (paper['subject']?['name'] ?? '')
                                  : '';
                          final studied = provider.isStudied(id);
                          return ListTile(
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  child: Text(
                                    year.length >= 4 ? year.substring(2) : year,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (studied)
                                  const Positioned(
                                    right: -4,
                                    bottom: -4,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              tooltip:
                                  studied
                                      ? 'Mark as unstudied'
                                      : 'Mark as studied',
                              icon: Icon(
                                studied
                                    ? Icons.bookmark_added
                                    : Icons.bookmark_add_outlined,
                                color:
                                    studied
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                              ),
                              onPressed:
                                  () => context
                                      .read<PapersProvider>()
                                      .toggleStudied(id),
                            ),
                            onTap: () async {
                              await provider.loadPaperDetail(id);
                              if (!mounted) return;
                              Navigator.of(this.context).pushNamed(
                                PaperDetailScreen.routeName,
                                arguments: id,
                              );
                            },
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
