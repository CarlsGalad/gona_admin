import 'package:flutter/material.dart';

class CreateNews extends StatelessWidget {
  const CreateNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
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
            Text(
              'Create News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
