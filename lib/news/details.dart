import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

import 'model.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
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
            child: Text(
              widget.newsItem.title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
          ImageNetwork(
            image: widget.newsItem.imageUrl,
            height: 300,
            width: 500,
          ),
          const SizedBox(height: 16.0),
          Text(
            'By ${widget.newsItem.author} • ${widget.newsItem.timePosted}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            widget.newsItem.content,
            style: const TextStyle(fontSize: 16.0, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
