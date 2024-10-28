import 'dart:convert';
import 'dart:math';
import 'package:ati/main.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

User user = User.empty;

class User{
	User({
		required this.name,
		required this.pfpAsset,
		required this.age,
		required this.employment
	});

	String pfpAsset;
	String name;
	int age;
	Employment employment;

	User.fromJson(Map<String, dynamic> json)
		: name = json["name"] as String,
			pfpAsset = json["pfpAsset"] as String,
			age = json["age"] as int,
			employment = Employment.values[json["employment"] as int];

	Map<String, dynamic> toJson() => {
		"name": name,
		"pfpAsset": pfpAsset,
		"age": age,
		"employment": employment.index,
	};

	static User get empty => 
		User(
			name: "Empty user",
			pfpAsset: "assets/images/user.png",
			age: 18,
			employment: Employment.other
		);

}

enum Employment {
	teacher,
	student,
	other
}

void loadUser() {
	final userData = prefs.getString("user");
	print(userData);
	if (userData == null){
		user = User.empty;
		saveUser();
		return;
	}
	user = User.fromJson(jsonDecode(userData));
}

void saveUser() {
	prefs.setString("user", jsonEncode(user.toJson()));
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

@override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

	bool editingName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(title: const Text("Profil Ayarları")),
			body: Center(
			child: Container(
			constraints: const BoxConstraints(maxWidth: 600),
			child: ListView(children: [
				Center(child: Stack(children: [
					Padding(
					padding: const EdgeInsets.only(top: 32),
						child: ClipRRect(
							borderRadius: BorderRadius.circular(10000),
							child: Image.asset(
								user.pfpAsset,
								height: min(MediaQuery.sizeOf(context).width * 0.4, 256),
							),
						)
					)
				],)),
				const SizedBox(height: 12),
				Center(child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						editingName ?
						SizedBox(
						width: 200,
						child:TextField(
							autofocus: true,
							onSubmitted: (value){
							setState((){
								user.name = value;
								saveUser();
								editingName = false;
							});
							},
							controller: TextEditingController(text: user.name),
						)):
						Text(
							user.name,
							style: Theme.of(context).textTheme.titleLarge
						),
						const SizedBox(width: 6),
						InkWell(
							onTap: (){
							setState((){
								editingName = true;
							});
							},
							child: const Icon(Icons.edit)
						)
					]
				)),
				const SizedBox(height: 16),
				SettingsRow(
					name: "Kullanıcı Bilgileri",
					onTap: (){},
					iconData: Icons.person,
				),
				SettingsRow(
					name: "Gemini Ayarları",
					onTap: (){
						Navigator.push(
							context,
							MaterialPageRoute(
								builder:(c) => const SettingsList(
									title: Text("Gemini Ayarları"),
									children: [
										TextSetting(
											labelText: "API Anahtarı",
											settingsKey:"geminiKey"
										),
									]
								)
							),
						);
					},
					iconData: Icons.person,
				),
				SettingsRow(
					name: "Gelişmiş Ayarlar",
					onTap: (){},
					iconData: Icons.person,
				),
			]),
			)
			)
		);
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({required this.name, required this.onTap, this.iconData, super.key});

	final String name;
	final GestureTapCallback onTap;
	final IconData? iconData;
	
  @override
  Widget build(BuildContext context) {
    return 
		Padding(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
		child: ClipRRect(
			borderRadius: BorderRadius.circular(8),
			child: Material(
				color: Theme.of(context).colorScheme.primary,
				child: InkWell(
					onTap: onTap,
					borderRadius: BorderRadius.circular(8),
					child: Padding(
						padding: const EdgeInsets.symmetric(
							vertical: 14, horizontal: 20
						),
						child: Row(children: [
							Icon(iconData),
							Expanded(
								child: Text(
									name,
									style: const TextStyle(fontSize: 18)
								)
							),
							const Icon(Icons.chevron_right_rounded)
						])
					)
				)
			)
		)
		);
  }
}

class TextSetting extends StatelessWidget {
  const TextSetting({required this.labelText, required this.settingsKey, super.key});

	final String settingsKey;
	final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
			decoration: InputDecoration(
				labelText: labelText
			),
			onSubmitted: (s) async {
				if (await prefs.setString(settingsKey, s)){
					toastification.show(
						type: ToastificationType.success,
						title: const Text("Başarılı"),
						autoCloseDuration: const Duration(seconds: 2),
						style: ToastificationStyle.fillColored
					);
				}
				else {
					toastification.show(
						type: ToastificationType.error,
						title: const Text("Hata"),
						autoCloseDuration: const Duration(seconds: 2),
						style: ToastificationStyle.fillColored,
					);
				}
			},
			controller: TextEditingController(text: prefs.getString(settingsKey) ?? ""),
		);
  }
}

class SettingsList extends StatelessWidget {
  const SettingsList({required this.children, this.title, super.key});

	final List<Widget> children;
	final Widget? title;

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: title),
			body: Center(
				child:Container(
					constraints: const BoxConstraints(maxWidth: 400),
					child: Padding(
						padding: const EdgeInsets.all(16).copyWith(top: 32),
						child: ListView(children: children)
					)
				)
			)
		);
  }
}
