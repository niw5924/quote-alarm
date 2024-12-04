import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  final String title;
  final String link;
  final String description;
  final String pubDate;

  News({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'].replaceAll(RegExp(r'<[^>]*>'), ''), // HTML 태그 제거
      link: json['originallink'],
      description: json['description'].replaceAll(RegExp(r'<[^>]*>'), ''),
      pubDate: json['pubDate'],
    );
  }
}

class NaverNewsService {
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/news.json';
  static const String _clientId = 'Gwe7ECZ98jQaLqP3bJc0'; // 클라이언트 ID
  static const String _clientSecret = 'N9CjNAqne7'; // 클라이언트 Secret

  Future<List<News>> fetchNews({
    String query = '오늘',
    int display = 10,
    int start = 1,
    String sort = 'date',
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?query=$query&display=$display&start=$start&sort=$sort'),
      headers: {
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((item) => News.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch news');
    }
  }
}
