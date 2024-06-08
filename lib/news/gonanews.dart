// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/news/createnews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

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
        color: Colors.black,
        width: MediaQuery.of(context).size.width -
            160, // Ensure the container takes the full available width
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('news').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LinearProgressIndicator());
                  }

                  final newsDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: newsDocs.length,
                    itemBuilder: (context, index) {
                      final newsItem = NewsItem.fromMap(
                          newsDocs[index].data() as Map<String, dynamic>);

                      final String imageUrl = newsItem.imageUrl;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration:
                              const BoxDecoration(color: Colors.blueGrey),
                          child: ListTile(
                            onTap: () {
                              // When a news item is tapped, update the current screen to NewsDetailScreen
                              setState(() {
                                _currentScreen =
                                    NewsDetailScreen(newsItem: newsItem);
                              });
                            },
                            minTileHeight: 80,
                            leading: SizedBox(
                              height: 200,
                              width: 100,
                              child: ImageNetwork(
                                image: imageUrl,
                                height: 200,
                                width: 100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            title: Text(newsItem.title,
                                style: GoogleFonts.aboreto(fontSize: 18)),
                            subtitle: Text(
                              'By ${newsItem.author} • ${newsItem.timePosted}',
                              style: GoogleFonts.abel(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.blueGrey,
                                      title: const Text("Delete News"),
                                      content: const Text(
                                          "Are you sure you want to delete this news?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Delete the news item from Firestore
                                            FirebaseFirestore.instance
                                                .collection('news')
                                                .doc(newsDocs[index].id)
                                                .delete();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Delete",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
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
