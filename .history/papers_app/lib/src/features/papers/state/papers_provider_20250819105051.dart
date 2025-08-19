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
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get papers => _papers;
  List<dynamic> get subjects => _subjects;
  Map<String, dynamic>? get selectedPaper => _selectedPaper;
  String get searchQuery => _searchQuery;

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

  Future<void> loadPapers({String? subjectId, String? year}) async {
    _setLoading(true);
    try {
      _papers = await service.fetchPapers(subjectId: subjectId, year: year);
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
      await _cacheLastViewedPaper(_selectedPaper!);
      _setError(null);
    } catch (e) {
      // Try offline cache
      final cached = await _readCachedLastViewedPaper();
      if (cached != null && (cached['id']?.toString() == paperId)) {
        _selectedPaper = cached;
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
      return (paper['title'] ?? paper['name'] ?? 'Paper ${paper['id'] ?? ''}').toString();
    }
    return paper.toString();
  }

  Future<void> _cacheLastViewedPaper(Map<String, dynamic> paper) async {
    final box = Hive.box('cache');
    await box.put('last_paper', paper);
  }

  Future<Map<String, dynamic>?> _readCachedLastViewedPaper() async {
    final box = Hive.box('cache');
    final data = box.get('last_paper');
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

