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
    Future.microtask(() => context.read<PapersProvider>().loadPapers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PapersProvider>();
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
                final provider = context.read<PapersProvider>();
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
                  child: DropdownButtonFormField<String>(
                    value: context.watch<PapersProvider>().selectedYear,
                    hint: const Text('Year'),
                    items: [
                      for (final y in ['2022', '2023', '2024'])
                        DropdownMenuItem(value: y, child: Text(y))
                    ],
                    onChanged: (val) {
                      context.read<PapersProvider>().setSelectedYear(val);
                      context.read<PapersProvider>().loadPapers();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: context.watch<PapersProvider>().selectedSubjectId,
                    hint: const Text('Subject'),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Mathematics')),
                      DropdownMenuItem(value: '2', child: Text('English')),
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
                            final year = (paper is Map)
                                ? (paper['year']?.toString() ?? '')
                                : '';
                            final subject = (paper is Map)
                                ? (paper['subject']?['name'] ?? '')
                                : '';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  year.length >= 4 ? year.substring(2) : year,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                              trailing: const Icon(Icons.chevron_right),
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
