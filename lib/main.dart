import 'dart:ui';

import 'package:ati/chat.dart';
import 'package:ati/data.dart';
import 'package:ati/onboarding.dart';
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
	loadData();
}

const Map<Brightness, Color> logoTints = {
	Brightness.light: Color(0x302A2AD2),
	Brightness.dark: Color(0x40AEAEF8)
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
		listenable: data,
		builder: (context, child) => MaterialApp(
			debugShowCheckedModeBanner: false,
      title: 'Ati - Educational AI',
			themeMode: data.themeMode,
			// AYDINLIK MOD
      theme: ThemeData(
        useMaterial3: true,
				colorScheme: const ColorScheme(
					brightness: Brightness.light,
					primary: Color(0xff4A69F1),
					onPrimary: Colors.white,
					secondary: Color(0xff726DFF),
					onSecondary: Colors.white,
					tertiary: Color(0xffB3D3EC),
					onTertiary: Colors.black,
					error: Color(0xfffc5a4e),
					onError: Colors.black,
					surface: Color(0xffE0E0FF),
					onSurface: Colors.black,
				),
				appBarTheme: const AppBarTheme(	
	        backgroundColor: Color(0xccBEBEF4),
					foregroundColor: Color(0xff404040),
					centerTitle: true,
				),
				dialogTheme: const DialogTheme(
					titleTextStyle: TextStyle(
						fontWeight: FontWeight.bold,
						color: Colors.black,
						fontSize: 28,
					),
					contentTextStyle: TextStyle(
						fontWeight: FontWeight.normal,
						color: Colors.black,
					)
				),
      ),
			// KARANLIK MOD
      darkTheme: ThemeData(
        useMaterial3: true,
				colorScheme: const ColorScheme(
					brightness: Brightness.dark,
					primary: Color(0xff3142d8),
					onPrimary: Colors.white,
					secondary: Color(0xff5d1bb3),
					onSecondary: Colors.white,
					tertiary: Color(0xff0090ff),
					onTertiary: Colors.black,
					error: Color(0xffdd0000),
					onError: Colors.white,
					surface: Color(0xff00001e),
					onSurface: Colors.white,
				),
				appBarTheme: const AppBarTheme(	
	        backgroundColor: Color(0xd3080838),
					foregroundColor: Color(0xffbebebe),
					centerTitle: true,
				),
				dialogTheme: const DialogTheme(
					titleTextStyle: TextStyle(
						fontWeight: FontWeight.bold,
						color: Colors.white,
						fontSize: 28,
					),
					contentTextStyle: TextStyle(
						fontWeight: FontWeight.normal,
						color: Colors.white,
					)
				),
      ),
			routes: {
				"home": (context) => const HomeScreen(),
				"onboarding": (context) => const Onboarding(),
			},
			initialRoute: (prefs.getBool("initialized") ?? false) ? "home" : "onboarding",
    ));
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
			extendBodyBehindAppBar: true,
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
									child: ListenableBuilder(
										listenable: data,
										builder: (context, widget) =>
											Image.asset(
												data.user.profilePictureAsset,
												height: kToolbarHeight - 16,
											)
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
					children: [
						const ChatPage(),
						HomeGreet(
							key: const PageStorageKey("homePage"),
							changePage: setPage
						),
						const TasksPage(key: PageStorageKey("tasksPage")),
					],
				),
    );
  }

	setPage(int page){
		setState(() {
			currentPage = page;
			pageController.animateToPage(
				page,
				duration: const Duration(milliseconds: 150),
				curve: Curves.easeInOut
			);
		});
	}
}

class HomeGreet extends StatelessWidget {
	const HomeGreet ({required this.changePage, super.key});

	final Function changePage;

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
							color: logoTints[Theme.of(context).brightness],
							"assets/images/bigA.png",
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
								decoration: BoxDecoration(
									border: Border(
										left: BorderSide(width: 2, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))
									)
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
													?.copyWith(
														color: Theme.of(context)
															.colorScheme.onSurface.withOpacity(0.7)
													)
											),
										]
									)
								),
							),
							const SizedBox(height: 16),
							SizedBox(
								width: 350,
								child: SearchBox(
									onSubmitted: (s){
										data.sendMessage(s);
										changePage(0);
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

	onSubmitted(String s) {
		if (controller.text.trim().isNotEmpty){
			controller.clear();
			widget.onSubmitted(s.trim());
		}
	}

  @override
  Widget build(BuildContext context) {
		return 
		Padding(
		padding: const EdgeInsets.all(8),

		child: ClipRRect(
			borderRadius: BorderRadius.circular(12),
			child: BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
				child: Material(
				color: Theme.of(context).appBarTheme.backgroundColor?.withOpacity(0.5),
				child: Padding(
				padding: const EdgeInsets.all(8),
				child: TextField(
					decoration: InputDecoration(
						fillColor: Colors.transparent,
						filled: true,
						hintText: "Ati'ye sor",
						hintStyle: TextStyle(
							color: Theme.of(context)
								.colorScheme.onSurface.withOpacity(0.5)
						),
						suffixIcon: IconButton(
							onPressed: (){
								setState(() {
									onSubmitted(controller.text);
								});
							},
							icon: const Icon(Icons.send)
						)
					),
					onSubmitted: onSubmitted,
					controller: controller,
				),
				)
				)
			)
		)
	);
  }
}
