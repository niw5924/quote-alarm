import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Quote {
  final String quote;
  final String author;

  Quote({
    required this.quote,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json, bool isKorean) {
    return Quote(
      quote: isKorean ? json['message'] : json['quote'],
      author: isKorean ? json['author'] : json['author'],
    );
  }
}

class QuoteService {
  Future<Quote> fetchRandomQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('quoteLanguage') ?? 'ko';
    final bool isKorean = language == 'ko';

    try {
      final url = isKorean
          ? 'https://korean-advice-open-api.vercel.app/api/advice' // 한국어 명언 API
          : 'https://quotes-api-self.vercel.app/quote'; // 영어 명언 API

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Quote.fromJson(jsonData, isKorean);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      return Quote(
        quote: isKorean ? "명언을 불러오는 데 실패했습니다." : "Failed to load quote.",
        author: e.toString(),
      );
    }
  }
}
