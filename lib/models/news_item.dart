class NewsItem {
  final String title;
  final String link;
  final String description;
  final String pubDate;

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      link: json['originallink'],
      description: json['description'],
      pubDate: json['pubDate'],
    );
  }
}
