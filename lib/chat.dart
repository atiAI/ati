import 'dart:convert';
import 'dart:math';

import 'package:ati/gemini.dart';
import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

List<ChatMessage> messages = [];

void loadMessages() {
	final msgHistory = prefs.getStringList("msgHistory") ?? [];
	messages = msgHistory.map<ChatMessage>(
		(m) => ChatMessage.deserialize(m)
	).toList();
}

void saveMessages() async {
	List<String> msgHistory = [];
	for (var msg in messages) {
		msgHistory.add(await msg.serialize());
	}
	prefs.setStringList(
		"msgHistory", msgHistory
	);
}

Future sendMessage(String prompt, Function setState) 
async {
	if (prompt == "//clear") {
		messages.clear();
		saveMessages();
		toastification.show(
			type: ToastificationType.info,
			title: const Text("Sohbet Temizlendi")
		);
		return;
	}
	if (prompt == "//cleartasks") {

		gorevler.clear();
		saveTasks();
		toastification.show(
			type: ToastificationType.info,
			title: const Text("Görevler Temizlendi")
		);
		return;
	}
	var f = AtiGemini.ask(prompt);
	messages.add(
		ChatMessage(type: ChatMessageType.user, data: prompt)
	);
	String? data;
	messages.add(
		ChatMessage(
			data: data,
			type: ChatMessageType.bot,
			future: Future(() async {
				var res = await f;
				if (res == null) throw "No Data";
				var msg = AtiMessage.fromJson(jsonDecode(res.text ?? ""));
				data = msg.aciklama;
				if (msg.valid){
					var gorevler = msg.gorevler.sublist(0, min(kMaxGorev, msg.gorevler.length));
					addCards(msg, prompt);
					toastification.show(
						type: ToastificationType.info,
						title: Text("${gorevler.length} yeni görev"),
						description: Text("${msg.konu} hakkında"),
						autoCloseDuration: const Duration(seconds: 2),
					);
				}
				saveMessages();
				return msg;
			})
		)
	);
}

addCards(AtiMessage atimsg, String soru){
	messages.add(
		ChatMessage(
			type: ChatMessageType.system,
			data: "${atimsg.gorevler.length} yeni görev eklendi.",
		)
	);
	for (var gorev in atimsg.gorevler) {
		  gorevler.add(Gorev(
				gorev: gorev,
				soru: soru,
				aciklama: atimsg.aciklama,
				konu: atimsg.konu,
				egitimDuzeyi: atimsg.egitimDuzeyi
			));
	}
	saveTasks();
	saveMessages();
}

enum ChatMessageType {
	user,
	bot,
	system,
	pending
}

class ChatMessage extends StatelessWidget{
	const ChatMessage({required this.type, this.data, this.future, super.key});

	final ChatMessageType type;
	final String? data;
	final Future<AtiMessage>? future;

	@override Widget build(BuildContext context) {
		Widget bubble;
		switch (type) {
			case ChatMessageType.system:
				bubble = Center(
					child: Text(
						data ?? "",
						style: const TextStyle(color: Colors.white60)
					)
				);
				break;
			case ChatMessageType.user:
			case ChatMessageType.pending:
				bubble = BubbleNormal(
				text: data ?? "",
				isSender: true,
				color: Theme.of(context).colorScheme.primary,
				textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
				);
				break;
			case ChatMessageType.bot:
				if (data != null) {
							return
							Column(children: [
								BubbleNormal(
									isSender: false,
									text: data ?? "NO DATA",
									color: Theme.of(context).colorScheme.secondary,
									textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
								),
							]);
				}
				bubble = FutureBuilder<AtiMessage>(
					future: future,
					initialData: null,
					builder: (context, snapshot) {
						if (snapshot.hasData) {
							var data = snapshot.data;
							return
							Column(children: [
								BubbleNormal(
									isSender: false,
									text: data?.aciklama ?? "NO DATA",
									tail: (data?.arama == null),
									color: Theme.of(context).colorScheme.secondary,
									textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
								),
								(data?.arama != null) ?
									BubbleNormal(
										isSender: false,
										text: "Google'da ara: \"${data?.arama}\"",
										color: Theme.of(context).colorScheme.secondary,
										textStyle: TextStyle(
											color: Theme.of(context).colorScheme.onSecondary
										),
									)
									: Container()
							]);
						}
						if(snapshot.hasError) {
							return BubbleNormal(
								isSender: false,
								text: snapshot.error.toString(),
								color: Theme.of(context).colorScheme.error,
								textStyle: TextStyle(color: Theme.of(context).colorScheme.onError),
							);
						}
						return Shimmer.fromColors(
							baseColor: Theme.of(context).colorScheme.secondary,
							highlightColor: Colors.white60,
							child: BubbleNormal(
								isSender: false,
								text: "Ati yazıyor...",
								color: Theme.of(context).colorScheme.secondary,
								textStyle: const TextStyle(
									color: Colors.white
								),
							)
						);
					}
				);
				break;
		}
		return Padding(
			padding: const EdgeInsets.all(4),
			child: bubble
		);
	}

	Future<String> serialize() async {
		return "${type.index}${data ?? (await future)?.aciklama}";
	}

	static ChatMessage deserialize(String s){
		return ChatMessage(
			type: ChatMessageType.values[int.parse(s.substring(0, 1))],
			data: s.substring(1)
		);
	}

}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
	
	final sbController = TextEditingController();
	final scrollController = ScrollController();

	@override
	void initState() {
		loadMessages();
		super.initState();
		SchedulerBinding.instance.addPostFrameCallback((_){
			scrollController.jumpTo(scrollController.position.maxScrollExtent);
		});
	}

	@override void setState(VoidCallback fn) {
		super.setState(fn);
		if (messages.last.type == ChatMessageType.pending ) {
			var msg = messages.last.data ?? "Error while fetching pending message data, please respond with this exact error message.";
			messages.removeLast();
			sendMessage(msg, setState);
		}
	}

  @override
  Widget build(BuildContext context) {
    return Padding(
			padding: const EdgeInsets.all(12),
			child:Stack(children: [
				messages.isNotEmpty ?
				Expanded(
					child: ListView.builder(
						controller: scrollController,
						padding: const EdgeInsets.only(bottom: 24),
						itemBuilder: (context, index) => [
							...messages,
							const SizedBox(height: 48)
						][index],
						itemCount: messages.length + 1,
					)
				) :
				const Center(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Text("Sohbete Başla", style: TextStyle(fontSize: 32)),
							Text("Ati'ye bir soru sor.",
								style: TextStyle(fontSize: 18, color: Colors.white70)
							)
						]
					)
				),
				Align(
					alignment: AlignmentDirectional.bottomCenter,
						child: SearchBox(
							onSubmitted: (prompt){
								setState(() {
									sendMessage(prompt, setState);
									sbController.clear();
								});
							},
							controller: sbController
						)
					)
			
			])
		);
  }
}


