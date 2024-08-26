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
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Marketing',
              style: GoogleFonts.lato(color: Colors.white54),
            ),
            backgroundColor: Colors.grey[900],
            centerTitle: true,
          ),
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ToggleButtons(
                          isSelected: [
                            selectedTopic == 'new_products',
                            selectedTopic == 'promotions',
                            selectedTopic == 'order_updates',
                          ],
                          onPressed: (index) {
                            setState(() {
                              switch (index) {
                                case 0:
                                  selectedTopic = 'new_products';
                                  break;
                                case 1:
                                  selectedTopic = 'promotions';
                                  break;
                                case 2:
                                  selectedTopic = 'order_updates';
                                  break;
                              }

                              // Log activity for selecting a topic
                              if (adminId != null && selectedTopic != null) {
                                AdminService().logActivity(
                                    adminId!,
                                    'Select Topic',
                                    'Selected topic "$selectedTopic"');
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          fillColor: Colors.black.withOpacity(0.5),
                          selectedColor: Colors.white,
                          color: Colors.black,
                          textStyle:
                              GoogleFonts.abel(fontWeight: FontWeight.bold),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('New Products'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Promotions'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Order Updates'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Vendors',
                                    style: GoogleFonts.abel(
                                        fontWeight: FontWeight.bold)),
                                value: 'vendors',
                                groupValue: selectedUserGroup,
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
                                activeColor: Colors.orange.shade200,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Customers',
                                    style: GoogleFonts.abel(
                                        fontWeight: FontWeight.bold)),
                                value: 'customers',
                                groupValue: selectedUserGroup,
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
                                activeColor: Colors.orange.shade200,
                              ),
                            ),
                          ],
                        ),
                        Card(
                          elevation: 3,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: InputBorder.none,
                                  labelStyle: GoogleFonts.abel(fontSize: 14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Card(
                          elevation: 3,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Message',
                                  labelStyle: GoogleFonts.abel(fontSize: 14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Card(
                          elevation: 3,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Email (Optional)',
                                  labelStyle: GoogleFonts.abel(fontSize: 14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Card(
                          elevation: 3,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              controller: _imageUrlsController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Image URLs (Comma separated)',
                                  labelStyle: GoogleFonts.abel(fontSize: 14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 3,
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextField(
                                    controller: _keyController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Data Key',
                                        labelStyle: GoogleFonts.abel()),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Card(
                                elevation: 3,
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: _valueController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Data Value',
                                        labelStyle: GoogleFonts.abel()),
                                  ),
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
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                        Row(
                          children: [
                            MaterialButton(
                              color: Colors.orange.shade200,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
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
                                  style: GoogleFonts.abel(
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 20),
                            MaterialButton(
                              onPressed: _clearFields,
                              child: Text('Clear', style: GoogleFonts.abel()),
                            ),
                          ],
                        ),
                      ],
                    ),
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
