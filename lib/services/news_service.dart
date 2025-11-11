import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsService {
  static const _apiKey = '';
  static const _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final uri = Uri.parse('$_baseUrl/top-headlines?language=en&category=$category&apiKey=$_apiKey');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> articlesJson = body['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
