import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../papers/data/papers_service.dart';

class PapersProvider extends ChangeNotifier {
  PapersProvider({required this.service});

  final PapersService service;

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _papers = <dynamic>[];
  List<dynamic> _subjects = <dynamic>[];
  Map<String, dynamic>? _selectedPaper;
  bool _selectedPaperFromCache = false;
  final Set<String> _studiedPaperIds = <String>{};
  String _searchQuery = '';
  String? _selectedSubjectId;
  String? _selectedYear;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get papers => _papers;
  List<dynamic> get subjects => _subjects;
  Map<String, dynamic>? get selectedPaper => _selectedPaper;
  bool get selectedPaperFromCache => _selectedPaperFromCache;
  Set<String> get studiedPaperIds => _studiedPaperIds;
  bool isStudied(String paperId) => _studiedPaperIds.contains(paperId);
  String get searchQuery => _searchQuery;
  String? get selectedSubjectId => _selectedSubjectId;
  String? get selectedYear => _selectedYear;

  List<dynamic> get filteredPapers {
    if (_searchQuery.isEmpty) return _papers;
    final query = _searchQuery.toLowerCase();
    return _papers.where((p) {
      final title = _paperTitle(p).toLowerCase();
      return title.contains(query);
    }).toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
    // Optional: could trigger backend search debounce here
  }

  void setSelectedSubject(String? subjectId) {
    _selectedSubjectId = subjectId;
    notifyListeners();
  }

  void setSelectedYear(String? year) {
    _selectedYear = year;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final token = await service.login(email: email, password: password);
      _setError(null);
      return token != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSubjects() async {
    _setLoading(true);
    try {
      _subjects = await service.fetchSubjects();
      _setError(null);
    } catch (e) {
      _setError('Failed to load subjects');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudiedFromCache() async {
    final box = Hive.box('cache');
    final List<dynamic> ids = box.get('studied_ids') as List<dynamic>? ?? <dynamic>[];
    _studiedPaperIds
      ..clear()
      ..addAll(ids.map((e) => e.toString()));
    notifyListeners();
  }

  Future<void> toggleStudied(String paperId) async {
    if (_studiedPaperIds.contains(paperId)) {
      _studiedPaperIds.remove(paperId);
    } else {
      _studiedPaperIds.add(paperId);
    }
    final box = Hive.box('cache');
    await box.put('studied_ids', _studiedPaperIds.toList());
    notifyListeners();
  }

  Future<void> loadPapers({String? subjectId, String? year}) async {
    _setLoading(true);
    try {
      final results = await service.fetchPapers(
        subjectId: subjectId ?? _selectedSubjectId,
        year: year ?? _selectedYear,
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _papers = results;
      _setError(null);
    } catch (e) {
      _setError('Failed to load papers');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPaperDetail(String paperId) async {
    _setLoading(true);
    try {
      _selectedPaper = await service.fetchPaperDetail(paperId);
      await _cachePaperById(paperId, _selectedPaper!);
      _selectedPaperFromCache = false;
      _setError(null);
    } catch (e) {
      // Try offline cache for this paper id
      final cached = await _readPaperFromCache(paperId);
      if (cached != null) {
        _selectedPaper = cached;
        _selectedPaperFromCache = true;
      } else {
        _setError('Failed to load paper');
      }
    } finally {
      _setLoading(false);
    }
  }

  String getPaperTitle(dynamic paper) => _paperTitle(paper);

  String _paperTitle(dynamic paper) {
    if (paper is Map) {
      return (paper['title'] ?? paper['name'] ?? 'Paper ${paper['id'] ?? ''}')
          .toString();
    }
    return paper.toString();
  }

  Future<void> _cachePaperById(String id, Map<String, dynamic> paper) async {
    final box = Hive.box('cache');
    await box.put('paper_$id', paper);
    final List<dynamic> existing =
        box.get('cached_ids') as List<dynamic>? ?? <dynamic>[];
    if (!existing.contains(id)) {
      existing.add(id);
      await box.put('cached_ids', existing);
    }
  }

  Future<Map<String, dynamic>?> _readPaperFromCache(String id) async {
    final box = Hive.box('cache');
    final data = box.get('paper_$id');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
