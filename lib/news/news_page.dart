import 'package:flutter/material.dart';
import 'package:flutter_alarm_app_2/services/naver_news_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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
            baseColor: const Color(0xFF7F7F7F).withValues(alpha: 0.2),
            highlightColor: const Color(0xFFD9D9D9).withValues(alpha: 0.2),
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
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () => _openNewsLink(news.link),
            child: ListTile(
              title: Text(
                decodedTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(decodedDescription),
            ),
          ),
        );
      },
    );
  }

  void _openNewsLink(String url) async {
    final uri = Uri.parse(url); // String을 Uri로 변환

    await launchUrl(uri);

    // if (await canLaunchUrl(uri)) { // canLaunchUrl이 무조건 false를 반환함. 이상함. 오늘은 true를 반환함.
    //   await launchUrl(uri);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }
}
