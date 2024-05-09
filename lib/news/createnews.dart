import 'package:flutter/material.dart';

class CreateNews extends StatelessWidget {
  const CreateNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
