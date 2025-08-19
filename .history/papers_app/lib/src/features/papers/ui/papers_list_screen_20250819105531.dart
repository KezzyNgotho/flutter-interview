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
                border: OutlineInputBorder(),
              ),
              onChanged:
                  (v) => context.read<PapersProvider>().setSearchQuery(v),
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
                    : ListView.separated(
                      itemCount: provider.filteredPapers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final paper = provider.filteredPapers[index];
                        final title = provider.getPaperTitle(paper);
                        final id =
                            (paper is Map)
                                ? (paper['id']?.toString() ?? '$index')
                                : '$index';
                        return ListTile(
                          title: Text(title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await context
                                .read<PapersProvider>()
                                .loadPaperDetail(id);
                            if (!mounted) return;
                            Navigator.of(context).pushNamed(
                              PaperDetailScreen.routeName,
                              arguments: id,
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
