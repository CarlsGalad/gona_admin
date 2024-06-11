import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gona_admin/services/admin_service.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _imageUrlsController = TextEditingController();

  final Map<String, String> _dataFields = {};
  String? selectedTopic;
  String? selectedUserGroup;
  DocumentSnapshot? _selectedNotification;

  String? adminId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    _emailController.dispose();
    _imageUrlsController.dispose();
    super.dispose();
  }

  Future<void> sendNotification(
      String title, String message, Map<String, String> data) async {
    if (selectedTopic == null || selectedUserGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a topic and user group')),
      );
      return;
    }

    // Log activity before sending notification
    if (adminId != null) {
      await AdminService().logActivity(adminId!, 'Send Notification',
          'Sent notification with title "$title" to topic "$selectedTopic" and user group "$selectedUserGroup"');
    }

    // Sending notification to a topic
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'topic': selectedTopic,
      'user_group': selectedUserGroup,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully')),
    );
  }

  Future<void> sendEmailWithImages(String email, String title, String message,
      List<String> imageUrls) async {
    final emailToSend = Email(
      body: '''
      <h1>$title</h1>
      <p>$message</p>
      ${imageUrls.map((url) => '<img src="$url" style="width:100px;height:auto;" />').join()}
      <br>
      <a href="yourapp://home">Open App</a>
      ''',
      subject: title,
      recipients: [email],
      isHTML: true,
    );

    try {
      // Log activity before sending email
      if (adminId != null) {
        await AdminService().logActivity(adminId!, 'Send Email',
            'Sent email with title "$title" to recipient "$email"');
      }

      await FlutterEmailSender.send(emailToSend);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $error')),
      );
    }
  }

  void _addDataField() {
    if (_keyController.text.isNotEmpty && _valueController.text.isNotEmpty) {
      setState(() {
        _dataFields[_keyController.text] = _valueController.text;

        // Log activity for adding a data field
        if (adminId != null) {
          AdminService().logActivity(adminId!, 'Add Data Field',
              'Added data field "${_keyController.text}" with value "${_valueController.text}"');
        }

        _keyController.clear();
        _valueController.clear();
      });
    }
  }

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _messageController.clear();
      _keyController.clear();
      _valueController.clear();
      _dataFields.clear();

      // Log activity for clearing fields
      if (adminId != null) {
        AdminService().logActivity(adminId!, 'Clear Fields',
            'Cleared all input fields and data fields');
      }
    });
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

                            // Log activity for selecting a topic
                            if (adminId != null && value != null) {
                              AdminService().logActivity(adminId!,
                                  'Select Topic', 'Selected topic "$value"');
                            }
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
                      DropdownButton<String>(
                        style: GoogleFonts.abel(color: Colors.black),
                        value: selectedUserGroup,
                        hint: Text(
                          'Select User Group',
                          style: GoogleFonts.abel(fontSize: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedUserGroup = value;

                            // Log activity for selecting a user group
                            if (adminId != null && value != null) {
                              AdminService().logActivity(
                                  adminId!,
                                  'Select User Group',
                                  'Selected user group "$value"');
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.deepPurpleAccent,
                        items: [
                          DropdownMenuItem(
                            value: 'vendors',
                            child: Text('Vendors', style: GoogleFonts.abel()),
                          ),
                          DropdownMenuItem(
                            value: 'customers',
                            child: Text('Customers', style: GoogleFonts.abel()),
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
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            labelText: 'Email (Optional)',
                            labelStyle: GoogleFonts.abel()),
                      ),
                      TextField(
                        controller: _imageUrlsController,
                        decoration: InputDecoration(
                            labelText: 'Image URLs (Comma separated)',
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
                            icon: const Icon(Icons.add),
                            onPressed: _addDataField,
                            color: Colors.black,
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
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              sendNotification(
                                _titleController.text,
                                _messageController.text,
                                _dataFields,
                              );

                              if (_emailController.text.isNotEmpty) {
                                sendEmailWithImages(
                                  _emailController.text,
                                  _titleController.text,
                                  _messageController.text,
                                  _imageUrlsController.text.split(','),
                                );
                              }

                              _clearFields();
                            },
                            child: Text('Send Notification',
                                style: GoogleFonts.abel()),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _clearFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Background color
                            ),
                            child: Text('Clear', style: GoogleFonts.abel()),
                          ),
                        ],
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
            const SizedBox(height: 10),
            Text(
              'User Group: ${_selectedNotification!['user_group']}',
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

Email(
    {required String body,
    required String subject,
    required List<String> recipients,
    required bool isHTML}) {}
