import 'dart:math';
import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:ati/onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

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
								data.user.profilePictureAsset,
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
								data.updateUser(name: value);
								saveData();
								editingName = false;
							});
							},
							controller: TextEditingController(text: data.user.name),
						)):
						Text(
							data.user.name,
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
					onTap: (){
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (c) =>Scaffold(
									appBar: AppBar(title: const Text("Kullanıcı Bilgileri"),),
									body: ListView(
										children: const [
											Padding(
												padding: EdgeInsets.symmetric(vertical: 12, horizontal: 36),
												child: SizedBox(
													height: 300,
													child: AgePicker(autoSave: true,)
												)
											)
										],
									)
								)
							)
						);
					},
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
					iconData: Icons.auto_awesome,
				),
				SettingsRow(
					name: "Gelişmiş Ayarlar",
					onTap: (){
						Navigator.push(
							context,
							MaterialPageRoute(
								builder: (c) => SettingsList(
									title: const Text("Gelişmiş ayarlar"),
									children: [
										ElevatedButton.icon(
											style: ElevatedButton.styleFrom(
												backgroundColor: Theme.of(context).colorScheme.primary,
												foregroundColor: Theme.of(context).colorScheme.onPrimary
											),
											onPressed: (){
												data.clear();
												saveData();

												prefs.setBool("initialized", false);

												Navigator.pushNamedAndRemoveUntil(
													context,
													"onboarding",
													(r) => r.isFirst,
												);
											},
											label: const Text("Kullanıcı verisini sıfırla"),
											icon: const Icon(Icons.delete)
										)
									]
								)
							)
						);
					},
					iconData: Icons.settings,
				),
				const SizedBox(height: 120),
				const Center(
					child:Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							ThemeButton(ThemeMode.light, Icons.light_mode, "Açık", autoSaveData: true,),
							ThemeButton(ThemeMode.system, Icons.brightness_4, "Sistem", autoSaveData: true,),
							ThemeButton(ThemeMode.dark, Icons.dark_mode, "Koyu", autoSaveData: true,)
						]
					),
				)
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
				textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
				child: InkWell(
					onTap: onTap,
					borderRadius: BorderRadius.circular(8),
					child: Padding(
						padding: const EdgeInsets.symmetric(
							vertical: 14, horizontal: 20
						),
						child: Row(children: [
							Icon(
								iconData,
								color: Theme.of(context).colorScheme.onPrimary
							),
							const SizedBox(width: 8),
							Expanded(
								child: Text(
									name,
									style: const TextStyle(fontSize: 18)
								)
							),
							Icon(
								Icons.chevron_right_rounded,
								color: Theme.of(context).colorScheme.onPrimary
							)
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

class AgePicker extends StatelessWidget {
  const AgePicker({this.autoSave, super.key});

	final bool? autoSave;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
			itemExtent: 48,
			scrollController: FixedExtentScrollController(initialItem: data.user.age),
			onSelectedItemChanged: (value) {
				data.user.age = value;
				if (autoSave == true) {
					saveData();
				}
			},
			children: List.generate(
				100,
				(index) => Center(
					child: Text(
						(index == 0) ?
						"Belirtmek İstemiyorum" :
						"$index",
						style: const TextStyle(fontSize: 18),
					)
				)
			)
		);
  }
}
