import 'dart:convert';
import 'dart:math';

import 'package:ati/gemini.dart';
import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:flutter/material.dart';

const kSimulatedDelay = Duration(milliseconds: 500);

late Data data;

void saveData() {
  prefs.setString("data", jsonEncode(data));
}

void loadData() {
	data = Data.clean();
	final dataText = prefs.getString("data");
	if (dataText != null){
		data = Data.fromJson(jsonDecode(dataText));
	}
}

class Data extends ChangeNotifier {
  final List<ChatMessage> _messages;
  final List<Task> _tasks;
  final User _user;

  Data.fromJson(Map<String, dynamic> json)
      : _messages = (json["messages"] as List? ?? [])
            .map((m) => ChatMessage.fromJson(m))
            .toList(),
        _tasks = (json["tasks"] as List? ?? [])
            .map((t) => Task.fromJson(t))
            .toList(),
        _user = User.fromJson(json["user"]);

	Data.clean()
		: _messages = [],
			_tasks = [],
			_user = User.empty;

  List<ChatMessage> get messages => _messages;
  List<Task> get tasks => _tasks;
  User get user => _user;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }


	Future sendMessage(String prompt) async {
		messages.add(ChatMessage(
			data: prompt,
			role: ChatRole.user,
			tail: true,
			timeStamp: DateTime.now()
		));

		notifyListeners();

		await Future.delayed(kSimulatedDelay);

		messages.add(ChatMessage(
			data: null,
			role: ChatRole.bot,
			tail: true,
			timeStamp: DateTime.now())
		);

		notifyListeners();

		final gcResponse = await AtiGemini.ask(prompt);
		final String text = gcResponse?.text ?? "{}";
		final AtiResponse response = AtiResponse.fromJson(jsonDecode(text));

		messages.removeLast();
		
		messages.add(ChatMessage(
			data: response.aciklama,
			role: ChatRole.bot,
			timeStamp: DateTime.now()
		));

		for (var i = 0; i < min(kMaxGorev, response.gorevler.length); i++) {
			tasks.add(Task(
				task: response.gorevler[i],
				konu: response.konu,
				difficulty: response.difficulty,
				timeStamp: DateTime.now()
			));
		}
		messages.add(ChatMessage(
			data: "${min(kMaxGorev, response.gorevler.length)} yeni görev eklendi.",
			role: ChatRole.bot,
			timeStamp: DateTime.now()
		));

		if (response.arama != null) {
			messages.add(ChatMessage(
				data: "Google'da ara: ${response.arama}",
				role: ChatRole.bot,
				timeStamp: DateTime.now()
			));
		}

		messages.last.tail = true;

		notifyListeners();

		saveData();

	}

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

	Task removeTask(int index) {
		Task ret = _tasks.removeAt(index);
		notifyListeners();
		return ret;
	}

  void updateUser({String? name, String? profilePictureAsset, int? age}) {
    _user.name = name ?? _user.name;
		_user.profilePictureAsset = profilePictureAsset ?? _user.profilePictureAsset;
		_user.age = age ?? _user.age;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        "messages": _messages.map((m) => m.toJson()).toList(),
        "tasks": _tasks.map((t) => t.toJson()).toList(),
        "user": _user.toJson(),
      };
}

class ChatMessage {
  final String? data;
  final ChatRole role;
  final DateTime timeStamp;
	bool? tail;

	ChatMessage({this.data, required this.role, required this.timeStamp, this.tail});

  ChatMessage.fromJson(Map<String, dynamic> json)
      : data = json["data"] ?? '',
        role = ChatRole.values.elementAt(json["role"] ?? 0),
        timeStamp = DateTime.fromMillisecondsSinceEpoch(json["timeStamp"] ?? 0),
				tail = json["tail"];

  Map<String, dynamic> toJson() => {
        "data": data,
        "role": role.index,
        "timeStamp": timeStamp.millisecondsSinceEpoch,
				"tail": tail ?? false,
      };
}

enum ChatRole { user, bot }

class Task {
  final String task;
  final String konu;
  final double difficulty;
  final DateTime timeStamp;

	Task({
		required this.task,
		required this.konu,
		required this.difficulty,
		required this.timeStamp
	});

  Task.fromJson(Map<String, dynamic> json)
      : task = json["task"] ?? '',
        konu = json["konu"] ?? '',
        difficulty = (json["difficulty"] as double?) ?? 0.0, // handles missing/invalid values
        timeStamp = DateTime.fromMillisecondsSinceEpoch(json["timeStamp"] ?? 0);

  Map<String, dynamic> toJson() => {
        "task": task,
        "konu": konu,
        "difficulty": difficulty,
        "timeStamp": timeStamp.millisecondsSinceEpoch,
      };
}

class User {
  String name;
  String profilePictureAsset;
  int age;

  User.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? '',
        profilePictureAsset = json["pfpAsset"] ?? 'assets/images/user.png',
        age = json["age"] ?? 0;

	static get empty => User.fromJson({});
		

  Map<String, dynamic> toJson() => {
        "name": name,
        "pfpAsset": profilePictureAsset,
        "age": age,
      };
}

