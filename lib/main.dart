import 'package:ati/chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import './profile.dart';

late SharedPreferences prefs;

void main() async {
  runApp(const ToastificationWrapper(child: MyApp()));
	prefs = await SharedPreferences.getInstance();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
			debugShowCheckedModeBanner: false,
      title: 'Ati - Educational AI',
      theme: ThemeData(
        useMaterial3: true,
				colorScheme: const ColorScheme(
					brightness: Brightness.dark,
					primary: Color(0xff3b178e),
					onPrimary: Colors.white,
					secondary: Color(0xff4a3283),
					onSecondary: Colors.black,
					error: Colors.red, onError: Colors.redAccent,
					surface: Color(0xff00001e),
					onSurface: Colors.white,
				),
				appBarTheme: const AppBarTheme(	
	        backgroundColor: Color(0x57130B32),
					foregroundColor: Color(0xffbebebe),
					centerTitle: true,
				),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
				actions: [
					Stack(
					alignment: Alignment.centerRight,
					children: [
						ClipRRect(
							borderRadius: const BorderRadius.horizontal(
								left: Radius.circular(kToolbarHeight/2)
							),
							child: Container(
								color: Colors.black.withOpacity(0.3),
								height: kToolbarHeight,
								width: 92,
							),
						),
						Padding(
							padding: const EdgeInsets.all(8),
							child: ClipRRect(
							borderRadius: BorderRadius.circular(32),
								child: InkWell(
									borderRadius: BorderRadius.circular(32),
									onTap: (){Navigator.push(
										context,
										MaterialPageRoute(builder: (context){return const UserProfile();})
									);},
									child: Image.asset(
										"assets/images/user.png",
										height: kToolbarHeight - 16,
										)
									)
								)
							)
					])
				],
				leading: Image.asset(
					"assets/images/yuzuncuyil.png",
				),
      ),
			body: Stack(children: [
				OverflowBox(
					alignment: Alignment.centerRight,
					minHeight: 0,
					minWidth: 0,
					maxWidth: double.infinity,
					maxHeight: double.infinity,
					child: Padding(
						padding: const EdgeInsets.only(top: 64, right: 16),
						child: Image.asset(
							"assets/images/background_A.png",
							fit: BoxFit.cover,
							height: MediaQuery.of(context).size.height - 192,
						)
					)
				),
				const Center(child: HomeGreet())
			])
    );
  }
}

class HomeGreet extends StatelessWidget {
	const HomeGreet ({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				Container(
					decoration: const BoxDecoration(
						border: Border(left: BorderSide(color: Colors.white60, width: 2))
					),
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									"Çalışma Alanını Yarat",
									style: Theme.of(context).textTheme.titleLarge
								),
								const SizedBox(height: 12),
								Text(
									"Create Your Workspace",
									style: Theme.of(context).textTheme.titleLarge
										?.copyWith(color: Colors.white70)
								),
							]
						)
					),
				),
				const SizedBox(height: 16),
				SizedBox(
					height: 64,
					width: 350,
					child:SearchBox(
						onSubmitted: (s){
							showBottomSheet(context: context, builder: (context){
								return const ChatPage();
							},
							showDragHandle: true,
							);
						},
					)
				)
			]
		);
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({required this.onSubmitted, this.controller, super.key});

	final void Function(String) onSubmitted;
	final TextEditingController? controller;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
	bool empty = true;

  @override
  Widget build(BuildContext context) {
    return Expanded(
			child: ClipRRect(
				borderRadius: BorderRadius.circular(16),
				child: Container(
					color: const Color(0xA513003F),
					child: Padding(
						padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
						child: Row(
							children: [
								Expanded(
									child: ClipRRect(
										borderRadius: BorderRadius.circular(16),
										child:TextField(
											controller: widget.controller,
											onSubmitted: widget.onSubmitted,
											style: const TextStyle(fontSize: 14),
											decoration: InputDecoration(
												icon: Image.asset("assets/images/background_A.png", height: 32),
												suffixIcon: empty ? null : const Icon(Icons.send),
												fillColor: const Color(0xA500001E),
												filled: true,
												hintText: "Fizik basit makineler animasyon",
												hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
											),
										),
									)
								)
							]),
					)
				)
			)
		);
  }
}
