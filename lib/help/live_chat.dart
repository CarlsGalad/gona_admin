import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPlaceholderWidget extends StatefulWidget {
  const ChatPlaceholderWidget({super.key});

  @override
  ChatPlaceholderWidgetState createState() => ChatPlaceholderWidgetState();
}

class ChatPlaceholderWidgetState extends State<ChatPlaceholderWidget> {
  String? selectedChatId;
  String? selectedChatTitle;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _fetchUserNames() async {
    Map<String, String> userNames = {};
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (var user in usersSnapshot.docs) {
      userNames[user.id] = "${user['firstName']} ${user['lastName']}";
    }
    return userNames;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      width: MediaQuery.of(context).size.width - 150,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Live Chat',
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.black87,
        ),
        body: Row(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                color: Colors.black12,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<Map<String, String>>(
                      future: _fetchUserNames(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(child: LinearProgressIndicator());
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('liveChats')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: LinearProgressIndicator());
                            }
                            final chats = snapshot.data!.docs;

                            if (chats.isEmpty) {
                              return const Center(
                                  child: Text(
                                'No chats available',
                                style: TextStyle(color: Colors.white70),
                              ));
                            }
                            return Expanded(
                              child: ListView.builder(
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  final chat = chats[index];
                                  final senderName =
                                      userSnapshot.data![chat['senderId']] ??
                                          'Unknown';
                                  return Container(
                                    color: Colors.black26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Text(chat['title']),
                                        subtitle: Text(senderName),
                                        onTap: () {
                                          setState(() {
                                            selectedChatId = chat.id;
                                            selectedChatTitle = chat['title'];
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(
              thickness: 1,
              width: 2,
              color: Color.fromARGB(255, 26, 25, 25),
            ),
            Flexible(
              flex: 3,
              child: selectedChatId == null
                  ? const Center(
                      child: Text('Please select a chat'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              selectedChatTitle ?? 'Message Title',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('liveChats')
                                    .doc(selectedChatId)
                                    .collection('messages')
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: LinearProgressIndicator());
                                  }
                                  final messages = snapshot.data!.docs;
                                  return ListView.builder(
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      return ChatBubble(
                                        message: message['content'],
                                        isSender:
                                            message['senderId'] == 'live_chat',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      fillColor: Colors.black12,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () async {
                                    if (_messageController.text
                                        .trim()
                                        .isEmpty) {
                                      return;
                                    }
                                    await FirebaseFirestore.instance
                                        .collection('liveChats')
                                        .doc(selectedChatId)
                                        .collection('messages')
                                        .add({
                                      'content': _messageController.text.trim(),
                                      'senderId': 'live_chat',
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    _messageController.clear();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
