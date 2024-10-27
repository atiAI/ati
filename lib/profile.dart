import 'dart:math';
import 'package:ati/main.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

String getProfilePic() {
	return prefs.getString("profileImageAsset") ?? "assets/images/user.png";
}

String getProfileName() {
	return prefs.getString("profileName") ?? "Username";
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

@override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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
								getProfilePic(),
								height: min(MediaQuery.sizeOf(context).width * 0.4, 256),
							),
						)
					)
				],)),
				const SizedBox(height: 12),
				Center(child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text(
							getProfileName(),
							style: Theme.of(context).textTheme.titleLarge
						),
						const SizedBox(width: 6),
						const Icon(Icons.edit)
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
										TextSetting(labelText: "API Anahtarı", settingsKey:"geminiKey")
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
				color: Colors.blue[500],
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
