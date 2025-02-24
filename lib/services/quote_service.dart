import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String quote;
  final String author;

  Quote({
    required this.quote,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'],
      author: json['author'],
    );
  }
}

class QuoteService {
  Future<Quote> fetchRandomQuote() async {
    try {
      final response =
          await http.get(Uri.parse('https://quotes-api-self.vercel.app/quote'));

      if (response.statusCode == 200) {
        return Quote.fromJson(json.decode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      return Quote(
        quote: "Failed to load quote.",
        author: e.toString(),
      );
    }
  }
}
