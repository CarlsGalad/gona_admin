import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NewsItem {
  final String title;
  final String author;
  final String timePosted;
  final String imageUrl;
  final String content;
  NewsItem({
    required this.title,
    required this.author,
    required this.timePosted,
    required this.imageUrl,
    required this.content,
  });

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    // Convert Timestamp to a formatted date string
    final timestamp = map['date_published'] as Timestamp;
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    final formattedDate = DateFormat.yMMMMd().format(date);

    return NewsItem(
        title: map['title'],
        author: map['publisher'],
        timePosted: formattedDate,
        imageUrl: map['image_url'],
        content: map['content']);
  }
}
