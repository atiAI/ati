import 'dart:ui';

import 'package:ati/chat.dart';
import 'package:ati/tasks.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import './profile.dart';

late SharedPreferences prefs;

void main() async {
  runApp(const ToastificationWrapper(
		config: ToastificationConfig(
			alignment: AlignmentDirectional.bottomEnd
		),
		child: MyApp()
	));
	prefs = await SharedPreferences.getInstance();
	await fetchMessages();
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
					onSecondary: Colors.white,
					error: Color(0xffdd0000),
					onError: Colors.white,
					surface: Color(0xff00001e),
					onSurface: Colors.white,

				),
				appBarTheme: const AppBarTheme(	
	        backgroundColor: Color(0x57130B32),
					foregroundColor: Color(0xffbebebe),
					centerTitle: true,
				),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	int currentPage = 1;

	final pageController = PageController(initialPage: 1);

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
			bottomNavigationBar: NavigationBar(
				destinations: const [
					NavigationDestination(
						icon: Icon(Icons.chat),
						label: "Sohbet",
					),
					NavigationDestination(
						icon: Icon(Icons.home),
						label: "Home"
					),
					NavigationDestination(
						icon: Icon(Icons.task),
						label: "Görevler"
					),
				],
				selectedIndex: currentPage,
				onDestinationSelected: (value){
					setState((){
						currentPage = value;
						pageController.animateToPage(
							value,
							duration: const Duration(milliseconds: 150),
							curve: Curves.easeInOut
						);
					});
				},
			),
			body: 
				PageView(
					controller: pageController,
					onPageChanged: (index) => setState(() {
														currentPage = index;
													}),
					children: const [
						ChatPage(key: PageStorageKey("chatPage")),
						HomeGreet(key: PageStorageKey("homePage")),
						TasksPage(key: PageStorageKey("tasksPage")),
					],
				),
    );
  }
}

class HomeGreet extends StatelessWidget {
	const HomeGreet ({super.key});


  @override
  Widget build(BuildContext context) {
		return Stack(children: [
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
				Center(
					child: Column(
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
					)
				)
			]);
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

	late TextEditingController controller;

	@override
	void initState() {
		super.initState();
		controller = widget.controller ?? TextEditingController();
	}

  @override
  Widget build(BuildContext context) {
    return Expanded(
			child: ClipRRect(
				borderRadius: BorderRadius.circular(16),
				child: BackdropFilter(
					filter: ImageFilter.blur(sigmaY: 4, sigmaX: 4),
					child: Container(
						color: const Color(0xA513003F),
						child: Padding(
							padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
							child: Row(
								children: [
									Expanded(
										child: ClipRRect(
											borderRadius: BorderRadius.circular(0),
											child:TextField(
												controller: controller,
												onSubmitted: controller.text.isNotEmpty ? widget.onSubmitted : null,
												onChanged: (s)=>setState((){}),
												style: const TextStyle(fontSize: 14),
												decoration: InputDecoration(
													icon: AnimatedSize(
													duration: const Duration(milliseconds: 100),
													child: Image.asset(
														"assets/images/background_A.png",
														height: controller.text.isEmpty ? 32 : 0 
													)
													),
													suffixIcon: InkWell(
														onTap: ()=>widget.onSubmitted(controller.text),
														child: Icon(Icons.send, size: controller.text.isEmpty ? 0 : 26)
													),
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
			)
		);
  }
}
