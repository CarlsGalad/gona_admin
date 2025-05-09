import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NewsItem {
  final String title;
  final String author;
  final String timePosted;
  final String imageUrl;
  final String content;
  
  final String id;
  final String category;
  final String categoryID;
  final bool isFeature;
  NewsItem({
    required this.title,
    required this.author,
    required this.timePosted,
    required this.imageUrl,
    required this.content,
    
    required this.id,
    required this.category,
    required this.categoryID,
    required this.isFeature,
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
        content: map['content'], 
        id: map['id'],
        category: map['category'],
        categoryID: map['category_id'],
        isFeature: map['is_feature']);
        
       
  }
}
