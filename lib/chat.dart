import 'package:ati/main.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';


enum ChatMessageType {
	user,
	bot,
	system
}

class ChatMessage extends StatelessWidget{
	const ChatMessage(this.type, this.data, {super.key});

	final ChatMessageType type;
	final String data;

	@override Widget build(BuildContext context) {
		switch (type) {
			case ChatMessageType.system:
				return Center(
					child: Text(
						data,
						style: const TextStyle(color: Colors.white60)
					)
				);
			case ChatMessageType.user:
			case ChatMessageType.bot:
				return BubbleNormal(
				text: data,
				isSender: type == ChatMessageType.user,
				
				);
		}
	}
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
	
	List<ChatMessage> messages = [];

	final sbController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
			padding: const EdgeInsets.all(12),
			child:Column(children: [
				Expanded(child: ListView.builder(
					itemBuilder: (context, index)=>messages[index], 
					itemCount: messages.length
				)),
				Row(children: [
					SearchBox(onSubmitted: (s){
						setState(() {
							messages.add(ChatMessage(ChatMessageType.bot, s));
							sbController.clear();
					});
					}, controller: sbController)
				])
			])
		);
  }
}


