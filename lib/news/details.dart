import 'package:flutter/material.dart';

import 'model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 50),
            child: Text(newsItem.title),
          ),
          Image.network(
            newsItem.imageUrl,
            height: 300,
            width: 500,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16.0),
          Text(
            'By ${newsItem.author} • ${newsItem.timePosted}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            newsItem.content,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
