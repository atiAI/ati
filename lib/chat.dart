import 'dart:math';

import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

BoxConstraints getMessageConstraints(BuildContext context) =>
	BoxConstraints(maxWidth: min(700, MediaQuery.of(context).size.width * 0.8));

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({required this.message, super.key});

	final ChatMessage message;

  @override
  Widget build(BuildContext context) {
		Widget bubble;
		switch (message.role) {
			case ChatRole.user:
				if (message.gorevRef != null) {
					bubble = Column(children: [
						const Align(
							alignment: AlignmentDirectional.topEnd,
							child: Padding(
								padding: EdgeInsets.only(right: 32, top: 16),
								child: Text("Görev Yardımı:")
							)
						),
						Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							Flexible(
								flex: 1,
								child: Container()
							),
							Flexible(
								flex: 5,
								child: TaskCard(message.gorevRef!, (){})
							),
						])
					]);
					break;
				}
				bubble = BubbleNormal(
				constraints: getMessageConstraints(context),
				text: message.data ?? "",
				isSender: true,
				color: Theme.of(context).colorScheme.primary,
				textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
				);
				break;
			case ChatRole.bot:
				if (message.data == null) {
					bubble = 
					Shimmer.fromColors(
						baseColor: Theme.of(context).colorScheme.secondary,
						highlightColor: Theme.of(context).colorScheme.tertiary,
						child: BubbleNormal(
							constraints: getMessageConstraints(context),
							isSender: false,
							text: "Ati yazıyor...",
							tail: message.tail ?? false,
							color: Theme.of(context).colorScheme.secondary,
							textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
						),
					);
				}
				else if (message.arama == true) {
					bubble = 
					InkWell(
						onTap: (){
							launchUrl(
								Uri.parse("https://google.com/search?q=${Uri.encodeFull(message.data!)}"),
								mode: LaunchMode.externalNonBrowserApplication
							);
						},
					child: BubbleNormal(
						constraints: getMessageConstraints(context),
						isSender: false,
						text: "Google'da ara: ${message.data}",
						tail: message.tail ?? false,
						color: Theme.of(context).colorScheme.secondary,
						textStyle: TextStyle(
							color: Theme.of(context).colorScheme.onSecondary,
							decorationStyle: TextDecorationStyle.wavy,
						),
					)
					);
				}
				else {
					bubble = BubbleNormal(
						constraints: getMessageConstraints(context),
						isSender: false,
						text: message.data!,
						tail: message.tail ?? false,
						color: Theme.of(context).colorScheme.secondary,
						textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
					);
				}
				break;
		}
		return Padding(
			padding: const EdgeInsets.all(4),
			child: bubble,
		);
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin{

	@override bool get wantKeepAlive => true;
	
	final sbController = TextEditingController();
	final scrollController = ScrollController();

	@override
	void initState() {
		super.initState();
		SchedulerBinding.instance.addPostFrameCallback((_){
			//scrollController.jumpTo(scrollController.position.maxScrollExtent);
			// FIXME: scroll down
		});
	}

  @override
  Widget build(BuildContext context) {
		super.build(context);
    return Padding(
			padding: const EdgeInsets.all(12),
			child: Stack( children: [
				ListenableBuilder(
					listenable: data,
					builder: (context, child) => data.messages.isNotEmpty ?
						Center(
								child: ListView(
									children: [
										...data.messages.map<Widget>(
											(msg) => ChatMessageWidget(message: msg)
										),
										const SizedBox(height: 72)
									]
								)
						):
						Center(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									const Icon(Icons.chat, size: 82,),
									const Text("Sohbete Başla", style: TextStyle(fontSize: 32)),
									Text("Ati'ye bir soru sor.",
										style: TextStyle(
											fontSize: 18,
											color: Theme.of(context)
												.colorScheme.onSurface.withOpacity(0.7)
										)
									),
									const SizedBox(height: 50,)
								]
							)
						),
				),
				Align(
					alignment: AlignmentDirectional.bottomCenter,
					child: SearchBox(
						onSubmitted: (prompt){
							setState(() {
								data.sendMessage(prompt);
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

