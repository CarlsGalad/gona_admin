import 'package:flutter/material.dart';
import 'package:gona_admin/news/createnews.dart';

import 'details.dart';
import 'model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  NewsScreenState createState() => NewsScreenState();
}

class NewsScreenState extends State<NewsScreen> {
  Widget _currentScreen = const CreateNews(); // Default screen is CreateNews

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width -
            180, // Ensure the container takes the full available width
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: mockNews.length,
                itemBuilder: (context, index) {
                  final newsItem = mockNews[index];
                  return ListTile(
                    onTap: () {
                      // When a news item is tapped, update the current screen to NewsDetailScreen
                      setState(() {
                        _currentScreen = NewsDetailScreen(newsItem: newsItem);
                      });
                    },
                    leading: Image.network(newsItem.imageUrl),
                    title: Text(newsItem.title),
                    subtitle:
                        Text('By ${newsItem.author} • ${newsItem.timePosted}'),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: _currentScreen, // Show the current screen widget
            ),
          ],
        ),
      ),
    );
  }
}

final List<NewsItem> mockNews = [
  NewsItem(
      title: 'Breaking News: Flutter 3.0 Released!',
      imageUrl: 'https://via.placeholder.com/150',
      author: 'John Doe',
      timePosted: '2 hours ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'New Study Shows Benefits of AI in Healthcare',
      imageUrl: 'https://via.placeholder.com/150',
      author: 'Jane Smith',
      timePosted: '5 hours ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'Climate Change Summit Recap: What You Need to Know',
      imageUrl: 'https://via.placeholder.com/150',
      author: 'Alice Johnson',
      timePosted: '1 day ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'Tech Giants Unveil New Products at CES 2024',
      imageUrl: 'https://via.placeholder.com/150',
      author: 'Bob Williams',
      timePosted: '3 days ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
];
