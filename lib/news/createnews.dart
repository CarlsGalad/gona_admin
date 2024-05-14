import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNews extends StatefulWidget {
  const CreateNews({super.key});

  @override
  CreateNewsState createState() => CreateNewsState();
}

class CreateNewsState extends State<CreateNews> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  PlatformFile? _imageFile;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) return;

      setState(() {
        _imageFile = result.files.first;
      });
    } catch (e) {}
  }

  Future<void> _addNewsToFirestore() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _imageFile == null) {
      return;
    }

    final storage = FirebaseStorage.instance;
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref().child('news_images/$timeStamp.jpg');
    await ref.putData(
      _imageFile!.bytes!,
      SettableMetadata(contentType: 'image/${_imageFile!.extension}'),
    );
    final imageUrl = await ref.getDownloadURL();

    final newsData = {
      'title': _titleController.text,
      'content': _contentController.text,
      'image_url': imageUrl,
      'publisher': 'YourPublisher', // Change this to the actual publisher
      'date_published': Timestamp.now(), // Firestore timestamp
    };

    await FirebaseFirestore.instance.collection('news').add(newsData);

    // Clear the input fields and image after adding news
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: const Text('Create News'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white10,
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 10),
                  if (_imageFile != null)
                    Image.memory(
                      Uint8List.fromList(_imageFile!.bytes!),
                      height: 100,
                      width: 100,
                    ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: _imageFile != null
                          ? Image.memory(
                              Uint8List.fromList(_imageFile!.bytes!),
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.add,
                              size: 50,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: _addNewsToFirestore,
                child: const Text('Save'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
      child: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: 200,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.black26, width: 5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                Text(
                  'Create News',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
