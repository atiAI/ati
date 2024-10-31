import 'dart:math';

import 'package:ati/data.dart';
import 'package:ati/gemini.dart';
import 'package:flutter/material.dart';

const kMinGorev = 1;
const kMaxGorev = 4;

class TaskCard extends StatefulWidget {
  const TaskCard(this.gorev, this.onComplete, {super.key});

	final Task gorev;
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
								Icon(
									atiIcons[widget.gorev.konu],
									color: Theme.of(context).colorScheme.onPrimary,
								),
								Text(
									widget.gorev.task,
									style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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

showCardDetails(BuildContext context, Task card, Function onComplete){
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

	final Task card;
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
									color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
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
										style: Theme.of(context).dialogTheme.titleTextStyle
									)
								)
							),
							Expanded(
								child: Padding(
									padding: const EdgeInsets.symmetric(
										vertical: 48, horizontal: 32
									),
									child: Center(
										child: Text(
											card.task,
											textAlign: TextAlign.center,
											style: Theme.of(context).dialogTheme.contentTextStyle
										)
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
				Expanded(
					child: ListView.builder(	
						itemBuilder: (context, index) => TaskCard(
							data.tasks[index], 
							() => setState(() {
								data.removeTask(index);
								saveData();
							}
						)
						),
						itemCount: data.tasks.length,
						scrollDirection: Axis.vertical,
					)
				)
			]
		);
  }
}

