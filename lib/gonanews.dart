import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

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
                    leading: Image.network(newsItem.imageUrl),
                    title: Text(newsItem.title),
                    subtitle:
                        Text('By ${newsItem.author} • ${newsItem.timePosted}'),
                  );
                },
              ),
            ),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.black26, width: 5),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text('Create News'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsItem {
  final String title;
  final String imageUrl;
  final String author;
  final String timePosted;

  NewsItem({
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.timePosted,
  });
}

final List<NewsItem> mockNews = [
  NewsItem(
    title: 'Breaking News: Flutter 3.0 Released!',
    imageUrl: 'https://via.placeholder.com/150',
    author: 'John Doe',
    timePosted: '2 hours ago',
  ),
  NewsItem(
    title: 'New Study Shows Benefits of AI in Healthcare',
    imageUrl: 'https://via.placeholder.com/150',
    author: 'Jane Smith',
    timePosted: '5 hours ago',
  ),
  NewsItem(
    title: 'Climate Change Summit Recap: What You Need to Know',
    imageUrl: 'https://via.placeholder.com/150',
    author: 'Alice Johnson',
    timePosted: '1 day ago',
  ),
  NewsItem(
    title: 'Tech Giants Unveil New Products at CES 2024',
    imageUrl: 'https://via.placeholder.com/150',
    author: 'Bob Williams',
    timePosted: '3 days ago',
  ),
];
