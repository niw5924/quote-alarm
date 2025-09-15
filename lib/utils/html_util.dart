import 'package:html/parser.dart';

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  return document.body!.text.trim();
}
