import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/services/naver_news_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_item.dart';
import '../utils/html_util.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  NewsScreenState createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  final NaverNewsService _newsService = NaverNewsService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<NewsItem> _newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final news = await _newsService.fetchNews(query: '오늘');
      setState(() {
        _newsList = news;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.3),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          );
        },
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('뉴스를 불러오는데 실패했습니다. $_errorMessage'));
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      padding: const EdgeInsets.all(16),
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        final news = _newsList[index];
        final title = parseHtmlString(news.title);
        final description = parseHtmlString(news.description);

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(description),
            onTap: () => launchUrl(Uri.parse(news.link)),
          ),
        );
      },
    );
  }
}
