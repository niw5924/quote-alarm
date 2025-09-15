import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote_item.dart';

class QuoteService {
  final String _quoteKoUrl = dotenv.env['QUOTE_KO_URL']!;
  final String _quoteEnUrl = dotenv.env['QUOTE_EN_URL']!;

  Future<QuoteItem> fetchRandomQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('quoteLanguage') ?? 'ko';
    final bool isKorean = language == 'ko';

    final url = isKorean ? _quoteKoUrl : _quoteEnUrl;

    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1));

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return QuoteItem.fromJson(data, isKorean);
  }
}
