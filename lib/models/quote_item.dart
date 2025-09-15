class QuoteItem {
  final String quote;
  final String author;

  QuoteItem({
    required this.quote,
    required this.author,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json, bool isKorean) {
    return QuoteItem(
      quote: isKorean ? json['message'] : json['quote'],
      author: isKorean ? json['author'] : json['author'],
    );
  }
}
