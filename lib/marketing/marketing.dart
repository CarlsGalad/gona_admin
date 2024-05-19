import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  MarketingScreenState createState() => MarketingScreenState();
}

class MarketingScreenState extends State<MarketingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  Map<String, String> _dataFields = {};
  String? selectedTopic;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> sendNotification(
      String title, String message, Map<String, String> data) async {
    if (selectedTopic == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please select a topic')),
      // );
      return;
    }

    // Sending notification to a topic
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'topic': selectedTopic,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Notification sent successfully')),
    // );
  }

  void _addDataField() {
    if (_keyController.text.isNotEmpty && _valueController.text.isNotEmpty) {
      setState(() {
        _dataFields[_keyController.text] = _valueController.text;
        _keyController.clear();
        _valueController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(66, 85, 80, 80),
      width: MediaQuery.of(context).size.width - 150,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(136, 78, 158, 125),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Send Notifications'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 20.0, right: MediaQuery.of(context).size.width - 400),
                child: DropdownButton<String>(
                  style: const TextStyle(color: Colors.white70),
                  value: selectedTopic,
                  hint: const Text('Select Topic'),
                  onChanged: (value) {
                    setState(() {
                      selectedTopic = value;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  dropdownColor: Colors.deepPurpleAccent,
                  items: const [
                    DropdownMenuItem(
                      value: 'new_products',
                      child: Text('New Products'),
                    ),
                    DropdownMenuItem(
                      value: 'promotions',
                      child: Text('Promotions'),
                    ),
                    DropdownMenuItem(
                      value: 'order_updates',
                      child: Text('Order Updates'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Data Key',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: 'Data Value',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addDataField,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _dataFields.length,
                  itemBuilder: (context, index) {
                    final key = _dataFields.keys.elementAt(index);
                    final value = _dataFields[key];
                    return ListTile(
                      title: Text('$key: $value'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  sendNotification(
                    _titleController.text,
                    _messageController.text,
                    _dataFields,
                  );
                },
                child: const Text('Send Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
