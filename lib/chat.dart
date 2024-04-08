// ignore_for_file: unused_field, unused_import, constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

const String api_keys = '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';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
//initialised the chatgpt
  final chatai = OpenAI.instance.build(
      token: api_keys,
      baseOption: HttpSetup(
          receiveTimeout: const Duration(
        seconds: 5,
      )),
      enableLog: true);

  //first user chat
  final ChatUser _currentuser =
      ChatUser(id: '1', firstName: 'Oyeladun', lastName: 'Olugbenga');

  final ChatUser _aichat = ChatUser(id: '2', firstName: 'Ai', lastName: 'Chat');

  // chat messages on the screen
  final List<ChatMessage> _message = <ChatMessage>[];

  final List<ChatUser> _typinguser = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('CHAT WITH AI'),
      ),
      body: DashChat(
          typingUsers: _typinguser,
          messageOptions: const MessageOptions(
              currentUserContainerColor: Colors.blue,
              containerColor: Colors.green,
              textColor: Colors.white),
          currentUser: _currentuser,
          onSend: (ChatMessage m) {
            getresponse(m);
          },
          messages: _message),
    );
  }

  Future<void> getresponse(ChatMessage m) async {
    // to show or add the test messages to list
    setState(() {
      _message.insert(0, m);
      _typinguser.add(_aichat);
    });
    // messaging history
    List<Messages> messagehistory = _message.reversed.map((m) {
      if (m.user == _currentuser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    //send the message to gpt for response
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: messagehistory,
      maxToken: 200,
    );
    final response = await chatai.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _message.insert(
              0,
              ChatMessage(
                  user: _aichat,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      _typinguser.remove(_aichat);
    });
  }
}
