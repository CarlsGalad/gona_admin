import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPlaceholderWidget extends StatefulWidget {
  const ChatPlaceholderWidget({super.key});

  @override
  ChatPlaceholderWidgetState createState() => ChatPlaceholderWidgetState();
}

class ChatPlaceholderWidgetState extends State<ChatPlaceholderWidget> {
  String? selectedChatId;
  String? selectedChatTitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: 600, // Ensure the container takes the full available width
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                color: Colors.black12,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('liveChats')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                              return ListTile(
                                title: Text(chat['title']),
                                subtitle: Text(chat['senderName']),
                                onTap: () {
                                  setState(() {
                                    selectedChatId = chat.id;
                                    selectedChatTitle = chat['title'];
                                  });
                                },
                              );
                            },
                          ),
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
                            Text(selectedChatTitle ?? 'Message Title'),
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
                                        child: CircularProgressIndicator());
                                  }
                                  final messages = snapshot.data!.docs;
                                  return ListView.builder(
                                    reverse: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      return ChatBubble(
                                        message: message['content'],
                                        isSender: message['senderId'] ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
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
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      fillColor: Colors.black12,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    onSubmitted: (value) async {
                                      if (value.trim().isEmpty) {
                                        return;
                                      }
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      await FirebaseFirestore.instance
                                          .collection('liveChats')
                                          .doc(selectedChatId)
                                          .collection('messages')
                                          .add({
                                        'content': value,
                                        'senderId': user!.uid,
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                      });
                                      // Clear the text field
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () {},
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

class ChatMessageBubble extends StatelessWidget {
  final String message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
