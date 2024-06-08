import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final Map<String, String> _dataFields = {};
  String? selectedTopic;
  DocumentSnapshot? _selectedNotification;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a topic')),
      );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully')),
    );
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
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Marketing',
              style: GoogleFonts.roboto(color: Colors.white54),
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
          ),
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        style: GoogleFonts.abel(color: Colors.black),
                        value: selectedTopic,
                        hint: Text(
                          'Select Topic',
                          style: GoogleFonts.abel(fontSize: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedTopic = value;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.deepPurpleAccent,
                        items: [
                          DropdownMenuItem(
                            value: 'new_products',
                            child:
                                Text('New Products', style: GoogleFonts.abel()),
                          ),
                          DropdownMenuItem(
                            value: 'promotions',
                            child: Text(
                              'Promotions',
                              style: GoogleFonts.abel(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'order_updates',
                            child: Text('Order Updates',
                                style: GoogleFonts.abel()),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                            labelText: 'Title', labelStyle: GoogleFonts.abel()),
                      ),
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                            labelText: 'Message',
                            labelStyle: GoogleFonts.abel()),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _keyController,
                              decoration: InputDecoration(
                                  labelText: 'Data Key',
                                  labelStyle: GoogleFonts.abel()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              controller: _valueController,
                              decoration: InputDecoration(
                                  labelText: 'Data Value',
                                  labelStyle: GoogleFonts.abel()),
                            ),
                          ),
                          IconButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                        (callback) => Colors.green)),
                            icon: const Icon(Icons.add),
                            onPressed: _addDataField,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _dataFields.length,
                          itemBuilder: (context, index) {
                            final key = _dataFields.keys.elementAt(index);
                            final value = _dataFields[key];
                            return ListTile(
                              title: Text('$key: $value',
                                  style: GoogleFonts.abel()),
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
                        child: Text('Send Notification',
                            style: GoogleFonts.abel()),
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(
                flex: 1.5.toInt(),
                child: _selectedNotification == null
                    ? _buildNotificationsListView()
                    : _buildNotificationDetailsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!.docs;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              title: Text(notification['title']),
              subtitle: Text(notification['message']),
              onTap: () {
                setState(() {
                  _selectedNotification = notification;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationDetailsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${_selectedNotification!['title']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Message: ${_selectedNotification!['message']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Topic: ${_selectedNotification!['topic']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedNotification = null;
                });
              },
              child: const Text('Back to List'),
            ),
          ],
        ),
      ),
    );
  }
}
