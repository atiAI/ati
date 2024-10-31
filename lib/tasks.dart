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

class TaskCardDialog extends StatefulWidget {
  const TaskCardDialog(this.card, this.onComplete, {super.key});

	final Task card;
	final Function onComplete;

  State<TaskCardDialog> createState() => _TaskCardDialogState();
}

class _TaskCardDialogState extends State<TaskCardDialog> with SingleTickerProviderStateMixin {

	late AnimationController _controller;
	late Animation<double> _flipAnimation;
	bool isFront = true;

	@override initState() {
		super.initState();

		_controller = AnimationController(
			duration: const Duration(milliseconds: 500),
			vsync: this
		);

		_flipAnimation = 
			Tween(begin: 0.0, end: pi)
			.animate(_controller)
			..addListener((){setState((){});});

	}

	@override
	Widget build(BuildContext context) {
		return 
			AnimatedBuilder(
				animation: _flipAnimation,
				builder: (context, child) {
					final isFrontVisible = _flipAnimation.value < pi/2;
					return Transform(
						transform: Matrix4.rotationY(_flipAnimation.value),
						alignment: Alignment.center,
						child: isFrontVisible ?
							buildFront(context) :
							Transform.flip(
								flipX: true,
								child: buildBack(context),
							),
					);
				}
			);
	}

  Widget buildFront(BuildContext context) {
    return Dialog(
			backgroundColor: Theme.of(context).colorScheme.primary,
			child: AspectRatio(
				aspectRatio: 5/8,
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 32),
					child: Stack(
					children: [
						LayoutBuilder(builder: (context, constrains)=>
							Center(
								child:Icon(
									atiIcons[widget.card.konu],
									color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
									size: min(300, constrains.maxWidth - 50),
								)
							),
						),
						Column(children: [
							Stack(children: [
								Align(
									alignment: AlignmentDirectional.topEnd,
									child: Padding(
										padding: const EdgeInsets.only(right: 20, top: 4),
										child: IconButton(
											color: Theme.of(context).colorScheme.onPrimary,
											onPressed: (){
												isFront = false;
												_controller.forward();
											},
											icon: const Icon(Icons.question_mark)
										),
									)
								),
								Padding(
									padding: const EdgeInsets.all(12),
									child: Center(
										child: Text(
											widget.card.konu,
											style: Theme.of(context).dialogTheme.titleTextStyle
										)
									)
								),
							]),
							Expanded(
								child: Padding(
									padding: const EdgeInsets.symmetric(
										vertical: 48, horizontal: 32
									),
									child: Center(
										child: SelectableText(
											widget.card.task,
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
									widget.onComplete();
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
		);
	}
  
  Widget buildBack(BuildContext context) {
    return Dialog(
			backgroundColor: Theme.of(context).colorScheme.secondary,
			child: AspectRatio(
				aspectRatio: 5/8,
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 32),
					child: Stack(
					children: [
						LayoutBuilder(builder: (context, constrains)=>
							Center(
								child:Icon(
									Icons.question_mark,
									color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
									size: min(300, constrains.maxWidth - 50),
								)
							),
						),
						Column(children: [
							Stack(children: [
								Align(
									alignment: AlignmentDirectional.topEnd,
									child: Padding(
										padding: const EdgeInsets.only(right: 20, top: 12),
										child: IconButton(
											color: Theme.of(context).colorScheme.onPrimary,
											onPressed: (){
												_controller.reverse();
												isFront = true;
											},
											icon: const Icon(Icons.arrow_forward)
										),
									)
								),
								Padding(
									padding: const EdgeInsets.all(12),
									child: Center(
										child: Text(
											"Açıklama",
											style: Theme.of(context).dialogTheme.titleTextStyle
										)
									)
								),
							]),
							Expanded(
								child: Padding(
									padding: const EdgeInsets.symmetric(
										vertical: 48, horizontal: 32
									),
									child: Center(
									child: SingleChildScrollView(
										child: SelectableText(
											widget.card.description,
											textAlign: TextAlign.center,
											style: Theme.of(context).dialogTheme.contentTextStyle
										),
									),
								),
								)
							),
							ElevatedButton.icon(
								style: ElevatedButton.styleFrom(
									textStyle: const TextStyle(fontSize: 18),
									backgroundColor: Theme.of(context).colorScheme.primary,
									foregroundColor: Theme.of(context).colorScheme.onPrimary
								),
								onPressed: (){
									// TODO: Yardım iste -> Görevsiz mesaj
									Navigator.pop(context);
								},
								label: const Padding(
									padding: EdgeInsets.symmetric(vertical: 8),
									child: Text("Yardım iste")
								),
								icon: const Icon(Icons.chat)
							)
						])
					])
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

