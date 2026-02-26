import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upm_drrm_irs_mobile/models/news_model.dart';

class NewsProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<News> _newsList = [];
  bool _isLoading = false;
  String? _error;

  List<News> get newsList => _newsList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream of news for real-time updates
  Stream<List<News>> get newsStream {
    return _supabase
        .from('news')
        .stream(primaryKey: ['id'])
        .order('published_at', ascending: false)
        .map((data) => data.map((json) => News.fromJson(json)).toList());
  }

  // Fetch all active news
  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('news')
          .select()
          .eq('is_active', true)
          .order('published_at', ascending: false);

      _newsList = (response as List).map((json) => News.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load news: ${e.toString()}';
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch news by category
  Future<List<News>> fetchNewsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('news')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('published_at', ascending: false);

      return (response as List).map((json) => News.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load news by category: ${e.toString()}');
    }
  }

  // Get filtered news by category (from cached list)
  List<News> getNewsByCategory(String category) {
    if (category == 'All') return _newsList;
    return _newsList.where((news) => news.category == category).toList();
  }

  // Refresh news data
  Future<void> refreshNews() async => fetchNews();

  // Add new news (admin functionality)
  Future<void> addNews(News news) async {
    try {
      await _supabase.from('news').insert(news.toJson());
      await fetchNews();
    } catch (e) {
      throw Exception('Failed to add news: ${e.toString()}');
    }
  }

  // Update news (admin functionality)
  Future<void> updateNews(News news) async {
    try {
      await _supabase.from('news').update(news.toJson()).eq('id', news.id);
      await fetchNews();
    } catch (e) {
      throw Exception('Failed to update news: ${e.toString()}');
    }
  }

  // Delete/deactivate news (admin functionality)
  Future<void> deleteNews(String newsId) async {
    try {
      await _supabase.from('news').update({'is_active': false}).eq('id', newsId);
      await fetchNews();
    } catch (e) {
      throw Exception('Failed to delete news: ${e.toString()}');
    }
  }
}