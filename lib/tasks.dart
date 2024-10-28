import 'dart:convert';
import 'dart:math';

import 'package:ati/gemini.dart';
import 'package:ati/main.dart';
import 'package:flutter/material.dart';

const kMinGorev = 1;
const kMaxGorev = 4;

List<Gorev> gorevler = [];

void loadTasks(){
	gorevler = (jsonDecode(prefs.getString("tasks") ?? "[]") as List).map<Gorev>((el)=>Gorev.fromJson(el)).toList();
}

void saveTasks(){
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
  const TaskCard(this.gorev, this.onComplete, {super.key});

	final Gorev gorev;
	final Function onComplete;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
			padding: const EdgeInsets.symmetric(
				horizontal: 30, vertical: 14
			),
			child: InkWell(
				onTap: () => showCardDetails(context, widget.gorev, widget.onComplete),
				child: ClipRRect(
					borderRadius: BorderRadius.circular(8),
					child: Container(
						color: Theme.of(context).colorScheme.primary,
						child: Padding(
							padding: const EdgeInsets.only(
								left: 16, right: 16, top: 14, bottom: 22),
							child: Column(children:[
								Icon(atiIcons[widget.gorev.konu]),
								Text(
									widget.gorev.gorev,
									textAlign: TextAlign.center
								),
							])
						)
					)
				)
			)
		);
  }
}

showCardDetails(BuildContext context, Gorev card, Function onComplete){
	showGeneralDialog(
		context: context,
		barrierDismissible: true,
		barrierLabel: "cardBarrier",
		transitionBuilder: (context, a1, a2, widget){
			return Transform.scale(
				scale: a1.value,
				child: widget,
			);
		},
		pageBuilder: 
			(context, anim1, anim2) => TaskCardDialog(card, onComplete)
	);
}

class TaskCardDialog extends StatelessWidget {
  const TaskCardDialog(this.card, this.onComplete, {super.key});

	final Gorev card;
	final Function onComplete;

  @override
  Widget build(BuildContext context) {
    return Dialog(
			backgroundColor: Theme.of(context).colorScheme.primary,
			child: AspectRatio(
				aspectRatio: 5/8,
				child: SizedBox(
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 32),
					child: Stack(
					children: [
						LayoutBuilder(builder: (context, constrains)=>
							Center(
								child:Icon(
									atiIcons[card.konu],
									color: Colors.white10,
									size: min(300, constrains.maxWidth - 50),
								)
							),
						),
						Column(children: [
							Padding(
								padding: const EdgeInsets.all(12),
								child: Center(
									child: Text(
										card.konu,
										style: Theme.of(context).textTheme.titleLarge
									)
								)
							),
							Expanded(
								child: Padding(
									padding: const EdgeInsets.symmetric(
										vertical: 48, horizontal: 32
									),
									child: Center(
										child: Text(card.gorev, textAlign: TextAlign.center,)
									),
								)
							),
							ElevatedButton.icon(
								style: ElevatedButton.styleFrom(
									textStyle: const TextStyle(fontSize: 18),
									backgroundColor: Theme.of(context).colorScheme.secondary,
									foregroundColor: Theme.of(context).colorScheme.onSecondary
								),
								onPressed: (){
									onComplete();
									Navigator.pop(context);
								},
								label: const Padding(
									padding: EdgeInsets.symmetric(vertical: 8),
									child: Text("Tamamlandı")
								),
								icon: const Icon(Icons.done)
							)
						])
					])
				)
				)
			)
		);
  }
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
						itemBuilder: (context, index) => TaskCard(
							gorevler[index], 
							() => setState(() {
								gorevler.removeAt(index);
								saveTasks();
							})
						),
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

