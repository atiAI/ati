import 'dart:convert';

import 'package:ati/gemini.dart';
import 'package:ati/main.dart';
import 'package:flutter/material.dart';

const kMinGorev = 1;
const kMaxGorev = 4;

List<Gorev> gorevler = [];

loadTasks(){
	gorevler = (jsonDecode(prefs.getString("tasks") ?? "[]") as List).map<Gorev>((el)=>Gorev.fromJson(el)).toList();
}

saveTasks(){
	prefs.setString("tasks", jsonEncode(gorevler));
}

class Gorev {
	Gorev({
		required this.gorev,
		required this.soru,
		required this.aciklama,
		required this.konu,
		required this.egitimDuzeyi,
	});

	final String gorev;
	final String soru;
	final String aciklama;
	final String konu;
	final String egitimDuzeyi;

	Gorev.fromJson(Map<String, dynamic> json)
		: gorev = json["gorev"] as String,
		  soru = json["soru"] as String,
		  aciklama = json["aciklama"] as String,
		  konu = json["konu"] as String,
		  egitimDuzeyi = json["egitimDuzeyi"] as String;

	Map<String, dynamic> toJson() => {
		"gorev": gorev,
		"soru": soru,
		"aciklama": aciklama,
		"konu": konu,
		"egitimDuzeyi": egitimDuzeyi
	};
}

class TaskCard extends StatefulWidget {
  const TaskCard(this.gorev, {super.key});

	final Gorev gorev;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
			padding: const EdgeInsets.symmetric(
				horizontal: 36, vertical: 14
			),
			child: InkWell(
				onTap: () => showCardDetails(context, widget.gorev),
				child: ClipRRect(
					borderRadius: BorderRadius.circular(8),
					child: Container(
						color: Theme.of(context).colorScheme.primary,
						child: Padding(
							padding: const EdgeInsets.symmetric(
								horizontal: 16, vertical: 14),
							child: Text(
								widget.gorev.gorev
							)
						)
					)
				)
			)
		);
  }
}

showCardDetails(BuildContext context, Gorev card){
	showDialog(
		context: context,
		builder: (ctx) => AlertDialog(
			title: Center(
				child:
					Row(children: [
						Text(card.konu),
						const SizedBox(width: 8),
						Icon(atiIcons[card.konu])
					]
				)
			),
			content: Text(card.gorev),
			actions: [
				ElevatedButton.icon(
					onPressed: (){},
					label: const Text("Tamamla", style: TextStyle(color: Colors.lightBlue),),
					icon: const Icon(Icons.done, color: Colors.lightBlue),
				)
			],
		)
	);
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {

	int currentCard = 0;

  @override
  Widget build(BuildContext context) {
    return
		Row(
			children: [
				/*Center(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: List<Widget>.generate(
							gorevler.length,
							(i) {
								bool active = i == currentCard;
								return Padding(
									padding: const EdgeInsets.all(4),
									child: ClipRRect(
										borderRadius: BorderRadius.circular(5),
										child: AnimatedSize(
										duration: const Duration(milliseconds: 200),
										child: Container(
											width: active ? 10 : 6,
											height: active ? 10 : 6,
											color: active ?
												Colors.white : Colors.white38,
										)
										)
									)
								);
							}
						)
					)
				),*/
				Expanded(
					child: ListView.builder(	
						itemBuilder: (context, index) => TaskCard(gorevler[index]),
						itemCount: gorevler.length,
						scrollDirection: Axis.vertical,
						/*onPageChanged: (p)=>setState((){
							currentCard = p;
						})*/
					)
				)
			]
		);
  }
}

