import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ati/chat.dart';
import 'package:ati/gemini.dart';
import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

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
  User _user;
	final List<File> _files;
	ThemeMode _themeMode;

  Data.fromJson(Map<String, dynamic> json)
      : _messages = (json["messages"] as List? ?? [])
            .map((m) => ChatMessage.fromJson(m))
            .toList(),
        _tasks = (json["tasks"] as List? ?? [])
            .map((t) => Task.fromJson(t))
            .toList(),
        _user = User.fromJson(json["user"]),
				_themeMode = ThemeMode.values[json["themeMode"] ?? 2],
				_files = (json["files"] as List? ?? []).
						map<File>((s) => File(s.toString()))
						.toList();

  Map<String, dynamic> toJson() => {
        "messages": _messages.map((m) => m.toJson()).toList(),
        "tasks": _tasks.map((t) => t.toJson()).toList(),
        "user": _user.toJson(),
				"themeMode": _themeMode.index,
				"files": _files.map<String>((f)=>f.path).toList(),
      };

	Data.clean()
		: _messages = [],
			_tasks = [],
			_user = User.empty,
			_themeMode = ThemeMode.dark,
			_files = [];

  List<ChatMessage> get messages => _messages;
  List<Task> get tasks => _tasks;
  User get user => _user;
	ThemeMode get themeMode => _themeMode;
	List<File> get files => _files;

	void addFile(File file) {
		_files.add(file);
		notifyListeners();
	}
	
	void removeFile(File file) {
		_files.remove(file);
		notifyListeners();
	}
	
	void removeFileByPath(String path) {
		_files.removeWhere((f) => f.path == path);
		notifyListeners();
	}

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

	Future sendMessage(String prompt, File? file) async {
		if (prompt.startsWith("//")) {
			switch (prompt) {
				case "//clearchat":
					messages.clear();
					break;
				case "//cleartasks":
					tasks.clear();
					break;
				case "//clearfiles":
					files.clear();
					break;
			}
			notifyListeners();
			saveData();
			return;
		}

		canSend.value = false;

		messages.add(ChatMessage(
			data: prompt,
			role: ChatRole.user,
			tail: true,
			timeStamp: DateTime.now(),
			fileRef: file,
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
		final AtiResponse response;
		try{
			final gcResponse = await AtiGemini.askGeneric(prompt, file);
			final String text = gcResponse?.text ?? "{}";
			response = AtiResponse.fromJson(jsonDecode(text));
		} catch(e){
			messages.removeLast();
			messages.add(ChatMessage(
				data: e.toString(),
				error: true,
				role: ChatRole.bot,
				timeStamp: DateTime.now()
			));
			notifyListeners();
			canSend.value = true;
			return;
		}


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
				soru: prompt,
				difficulty: response.difficulty,
				timeStamp: DateTime.now(),
				description: response.aciklama
			));
		}
		if (response.gorevler.isNotEmpty) {
			messages.add(ChatMessage(
				data: "${min(kMaxGorev, response.gorevler.length)} yeni görev eklendi.",
				role: ChatRole.bot,
				timeStamp: DateTime.now()
			));
			toastification.show(
				type: ToastificationType.info,
				title: Text("${min(kMaxGorev, response.gorevler.length)} yeni görev."),
				description: Text("${response.konu} hakkında."),
				autoCloseDuration: const Duration(seconds: 3),
				closeOnClick: true,
				callbacks: ToastificationCallbacks(
					onTap: (_){
						homePageController.animateToPage(
							2, duration: Durations.short4, curve: Curves.ease
						);
					}
				),
			);
		}


		if (response.arama != null) {
			messages.add(ChatMessage(
				data: response.arama,
				arama: true,
				role: ChatRole.bot,
				timeStamp: DateTime.now()
			));
		}

		messages.last.tail = true;
		notifyListeners();

		saveData();

		canSend.value = true;
	}

	Future taskHelp(Task task, String? prompt) async {
		canSend.value = false;

		messages.add(ChatMessage(
			role: ChatRole.user,
			timeStamp: DateTime.now(),
			gorevRef: task,
			data: prompt,
			tail: true
		));

		notifyListeners();

		await Future.delayed(kSimulatedDelay);

		messages.add(ChatMessage(
			role: ChatRole.bot,
			tail: true,
			data: null,
			timeStamp: DateTime.now(),
		));

		notifyListeners();

		final answer = await AtiGemini.askTaskHelp(task, prompt);
		
		messages.removeLast();

		messages.add(
			ChatMessage(
				role: ChatRole.bot,
				timeStamp: DateTime.now(),
				data: answer?.text,
				tail: true,
			)
		);

		notifyListeners();
		saveData();

		canSend.value = true;
	}

	Future generateQuestions(String initial) async {
		canSend.value = false;

		messages.add(ChatMessage(
			role: ChatRole.user,
			timeStamp: DateTime.now(),
			data: "Soruyu geliştir: $initial",
			blockSuggest: true,
			tail: true
		));

		notifyListeners();

		await Future.delayed(kSimulatedDelay);
		messages.add(ChatMessage(
			role: ChatRole.bot,
			tail: true,
			data: null,
			timeStamp: DateTime.now(),
		));

		notifyListeners();

		final suggestion = await AtiGemini.askQuestionSuggestions(initial);

		messages.removeLast();

		messages.add(ChatMessage(
			data: suggestion?.text,
			suggestion: true,
			timeStamp: DateTime.now(),
			role: ChatRole.bot
		));

		notifyListeners();
		canSend.value = true;
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

	void setThemeMode(ThemeMode mode) {
		_themeMode = mode;
		notifyListeners();
	}

	void clear() {
		_user = User.empty;
		_messages.clear();
		_tasks.clear();
		_themeMode = ThemeMode.dark;
		_files.clear();
		notifyListeners();
	}
}

class ChatMessage {
  final String? data;
  final ChatRole role;
  final DateTime timeStamp;
	bool? tail;
	final bool? arama;
	final Task? gorevRef;
	final bool? suggestion;
	final bool? blockSuggest;
	final bool? error;
	final File? fileRef;

	ChatMessage({this.data, required this.role, required this.timeStamp, this.tail, this.arama, this.gorevRef, this.suggestion, this.blockSuggest, this.error, this.fileRef});

  ChatMessage.fromJson(Map<String, dynamic> json)
      : data = json["data"] ?? '',
        role = ChatRole.values.elementAt(json["role"] ?? 0),
        timeStamp = DateTime.fromMillisecondsSinceEpoch(json["timeStamp"] ?? 0),
				tail = json["tail"] ?? false,
				arama = json["arama"] ?? false,
				gorevRef = json["gorevRef"] != null ? Task.fromJson(json["gorevRef"]) : null,
				suggestion = json["suggestion"] ?? false,
				blockSuggest = json["blockSuggest"] ?? false,
				error = json["error"] ?? false,
				fileRef = json["fileRef"] != null ? File(json["fileRef"]) : null;

  Map<String, dynamic> toJson() => {
        "data": data,
        "role": role.index,
        "timeStamp": timeStamp.millisecondsSinceEpoch,
				"tail": tail ?? false,
				"arama": arama ?? false,
				"gorevRef": gorevRef?.toJson(),
				"suggestion": suggestion ?? false,
				"blockSuggest": blockSuggest ?? false,
				"error": error ?? false,
				"fileRef": fileRef?.path,
      };
}

enum ChatRole{ 
	user,
	bot;

	String get genai {
		switch (this) {
			case ChatRole.user:
				return "user";
			case ChatRole.bot:
				return "model";
		}
	}
}

class Task {
  final String task;
  final String konu;
  final double difficulty;
  final DateTime timeStamp;
	final String description;
	final String soru;

	Task({
		required this.task,
		required this.konu,
		required this.difficulty,
		required this.timeStamp,
		required this.description,
		required this.soru,
	});

  Task.fromJson(Map<String, dynamic> json)
      : task = json["task"] ?? '<BUG> NO TASK',
        konu = json["konu"] ?? '<BUG> NO CATEGORY',
        difficulty = (json["difficulty"] as double?) ?? -1,
				timeStamp = DateTime.fromMillisecondsSinceEpoch(json["timeStamp"] ?? 0),
				description = json["description"] ?? '<BUG> NO DESCRIPTION',
				soru = json["soru"] ?? '<BUG> NO QUESTION';

  Map<String, dynamic> toJson() => {
        "task": task,
        "konu": konu,
        "difficulty": difficulty,
        "timeStamp": timeStamp.millisecondsSinceEpoch,
				"description": description,
				"soru": soru
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

