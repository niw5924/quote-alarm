import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/services/naver_news_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  NewsScreenState createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  final NaverNewsService _newsService = NaverNewsService();
  final HtmlUnescape _unescape = HtmlUnescape(); // HTML 엔티티 변환기
  List<News> _newsList = [];
  bool _isLoading = true;
  String _errorMessage = '';

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
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.3),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          );
        },
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('뉴스를 불러오는데 실패했습니다.'),
              Text(_errorMessage),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        final news = _newsList[index];
        final decodedTitle = _unescape.convert(news.title); // HTML 디코딩
        final decodedDescription =
            _unescape.convert(news.description); // HTML 디코딩

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2.0,
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            title: Text(
              decodedTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(decodedDescription),
            onTap: () => launchUrl(Uri.parse(news.link)),
          ),
        );
      },
    );
  }
}
