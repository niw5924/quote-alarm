import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';

class NaverNewsService {
  final String _naverNewsUrl = dotenv.env['NAVER_NEWS_URL']!;
  final String _naverClientId = dotenv.env['NAVER_CLIENT_ID']!;
  final String _naverClientSecret = dotenv.env['NAVER_CLIENT_SECRET']!;

  Future<List<NewsItem>> fetchNews({
    String query = '오늘',
    int display = 10,
    int start = 1,
    String sort = 'date',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_naverNewsUrl?query=$query&display=$display&start=$start&sort=$sort',
      ),
      headers: {
        'X-Naver-Client-Id': _naverClientId,
        'X-Naver-Client-Secret': _naverClientSecret,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch news (status: ${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> items = data['items'];
    return items.map((item) => NewsItem.fromJson(item)).toList();
  }
}
