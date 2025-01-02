import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:library_management/widgets/custom_drawer.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'text': 'Hi, How can I assist you?'}
  ];
  bool _isWaitingForResponse = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final userInput = _messageController.text;

      setState(() {
        _messages.add({'sender': 'user', 'text': userInput});
        _messageController.clear();
        _isWaitingForResponse = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/chat'), // Replace with your API URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userInput': userInput}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final botResponse = responseData['response'] ?? 'No response';

          setState(() {
            _messages.add({'sender': 'bot', 'text': botResponse});
            _isWaitingForResponse = false;
          });
        } else {
          _handleError('Error: Unable to connect to the server.');
        }
      } catch (e) {
        _handleError('Error: Something went wrong. Please try again later.');
      }
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _messages.add({'sender': 'bot', 'text': errorMessage});
      _isWaitingForResponse = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Book's Agent",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.blue,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/logo.png',
              height: 20,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(role: 'Admin'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isWaitingForResponse && index == _messages.length) {
                  return const Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        "Typing...",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }

                final message = _messages[index];
                final isBot = message['sender'] == 'bot';
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBot)
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    if (!isBot) const Spacer(),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isBot ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          message['text']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatBotScreen(),
    ));
