import 'package:flutter/material.dart';

class CreateNews extends StatelessWidget {
  const CreateNews({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Center(
            child: AlertDialog(
              backgroundColor: Colors.black,
              title: const Text('Create News'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Add your logic here to save the news
                    Navigator.of(context).pop();
                  },
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
              borderRadius: BorderRadius.circular(15)),
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
