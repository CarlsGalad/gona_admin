import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Container(
      color: Colors.grey[300],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, top: 50),
              child: Text(
                widget.newsItem.title,
                style: GoogleFonts.aboreto(
                    color: Colors.black,
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
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.newsItem.content,
              style: GoogleFonts.abel(fontSize: 16.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
