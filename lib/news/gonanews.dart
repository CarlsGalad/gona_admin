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
  bool _creatingNews = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: MediaQuery.of(context).size.width -
            160, // Ensure the container takes the full available width
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: mockNews.length,
                itemBuilder: (context, index) {
                  final newsItem = mockNews[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.blueGrey),
                      child: ListTile(
                        onTap: () {
                          // When a news item is tapped, update the current screen to NewsDetailScreen
                          setState(() {
                            _currentScreen =
                                NewsDetailScreen(newsItem: newsItem);
                          });
                        },
                        leading: Image.network(newsItem.imageUrl),
                        title: Text(newsItem.title),
                        subtitle: Text(
                            'By ${newsItem.author} • ${newsItem.timePosted}'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 2,
              child: _creatingNews
                  ? const CreateNews()
                  : _currentScreen, // Show the current screen widget
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
      imageUrl: 'https://picsum.photos/250?image=9',
      author: 'John Doe',
      timePosted: '2 hours ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'New Study Shows Benefits of AI in Healthcare',
      imageUrl: 'https://picsum.photos/250?image=9',
      author: 'Jane Smith',
      timePosted: '5 hours ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'Climate Change Summit Recap: What You Need to Know',
      imageUrl: 'https://picsum.photos/seed/picsum/200/300',
      author: 'Alice Johnson',
      timePosted: '1 day ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
  NewsItem(
      title: 'Tech Giants Unveil New Products at CES 2024',
      imageUrl:
          'https://images.unsplash.com/photo-1715271040278-9c6fcd6e669b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0fHx8ZW58MHx8fHx8',
      author: 'Bob Williams',
      timePosted: '3 days ago',
      content:
          'an example implementation of a news detail screen widget. This widget will display the details of a news item, including the title, image, author, time posted, and the full content of the news article.'),
];
