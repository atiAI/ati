import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:ati/profile.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

final canProceed = ValueNotifier<bool>(true);

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int currentPage = 0;
	bool eula = false;

  @override
  initState() {
    super.initState();
  }

  List<Widget> buildPages(context) {
    return [
      const OnboardingPage(
        title: "Hoşgeldin.",
        content: Text(
          "Başlamadan önce seni biraz tanıyalım.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
			OnboardingPage(
				title: "Adın?",
				content: TextField(
					onChanged: (value) {
						data.user.name = value;
						canProceed.value = data.user.name.length >= 3;
					},
					onSubmitted: (_)=>setState(() {
						if (canProceed.value) {
							currentPage++;
							_pageController.nextPage(
								duration: const Duration(milliseconds: 200),
								curve: Curves.ease
							);
						}
					}),
					autofocus: true,
					controller: TextEditingController(
						text: data.user.name
					),
				),
				proceedCondition: () => (data.user.name.length >= 3),
			),
			const OnboardingPage(
				title: "Yaşın?",
				content: AgePicker()
			),
			OnboardingPage(
				title: "Görünüş",
				content: 
				MediaQuery.sizeOf(context).width > 600 ?
				const Row(
					children: [
						ThemeButton(ThemeMode.light, Icons.light_mode, "Açık"),
						ThemeButton(ThemeMode.system, Icons.brightness_4, "Sistem"),
						ThemeButton(ThemeMode.dark, Icons.dark_mode, "Koyu")
					]
				) : 
				const Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							ThemeButton(ThemeMode.light, Icons.light_mode, "Açık"),
							ThemeButton(ThemeMode.dark, Icons.dark_mode, "Koyu")
						]
					),
						ThemeButton(ThemeMode.system, Icons.brightness_4, "Sistem"),
				])
			),
      OnboardingPage(
        title: "Tamamdır!",
				content: 
				Row(children: [
				Transform.scale(
				scale: 1.5,
				child: Checkbox(
					value: eula,
					onChanged: (v){
						setState(() {
							eula = v == true;
							canProceed.value = eula;	
						});
					},
				)),
				const SizedBox(width: 12),
				const SizedBox(
					width: 250,
					child: Text(
						"Ati kullanım koşullarını okudum, onaylıyorum.",
						style: TextStyle(fontSize: 18),
					)
				),
				]),
				proceedCondition: ()=> eula,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			bottomNavigationBar: SizedBox(
			height: 8,
			child: Align(
				alignment: AlignmentDirectional.bottomStart,
				child: TweenAnimationBuilder(
					tween: Tween<double>(
						begin: 
							MediaQuery.sizeOf(context).width * 
							(currentPage) / buildPages(context).length,
						end:
							MediaQuery.sizeOf(context).width *
							(currentPage + 1) / buildPages(context).length,
					),
					duration: const Duration(milliseconds: 100),
					builder: (context, width, child) => Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.horizontal(
							right: 
								(currentPage == buildPages(context).length - 1)
								? Radius.zero 
								: const Radius.circular(20)
						),
						color: Theme.of(context).colorScheme.primary
						),
						width: width,
					),
				)),
			),
      body: Stack(
        children: [
          PageView(
						physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: buildPages(context),
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
							child: ValueListenableBuilder(
								valueListenable: canProceed,
								builder: (context, canProceedValue, child) =>
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
										IconButton(
											onPressed: 
											currentPage != 0 ?
											() {
												_pageController.previousPage(
													duration: const Duration(milliseconds: 250),
													curve: Curves.easeInOut,
												);
											} : null,
											// color: Colors.white,
											icon: const Icon(
												Icons.chevron_left_rounded,
												size: 42
											),
										),
										currentPage != buildPages(context).length - 1 ?
										IconButton(
											onPressed: 
											canProceedValue ?
											() {
												_pageController.nextPage(
													duration: const Duration(
														milliseconds: 250
													),
												
											curve: Curves.easeInOut,
												);
												canProceed.value = false;
											} : null,
											// color: Colors.white,
											icon: const Icon(
												Icons.chevron_right_rounded,
												size: 42
											),
										)
									: TextButton(
											style: TextButton.styleFrom(
												foregroundColor: Theme.of(context).colorScheme.onSurface,
												disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
											),
											onPressed: canProceedValue ? 
											() {
												saveData();
												prefs.setBool("initialized", true);
												Navigator.popAndPushNamed(
													context,
													"home"
												);
											} : null,
											child: const Text(
												"Bitir",
												style: TextStyle(
													fontWeight: FontWeight.bold,
													fontSize: 16,
												),
											),
										),
									],
								)
							),
            ),
          ),
        ],
      ),
    );
  }
}



class OnboardingPage extends StatelessWidget {
  final Color? color;
  final String title;
  final Color? titleColor;
  final Widget content;
	final bool Function()? proceedCondition;

  const OnboardingPage({
    super.key,
    this.color,
    required this.title,
    required this.content,
    this.titleColor,
		this.proceedCondition
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Padding(
        padding: 
				MediaQuery.sizeOf(context).width > 500 ?
				const EdgeInsets.only(
          top: 180,
					bottom: 160,
          left: 112,
          right: 96,
        ) :
				const EdgeInsets.only(
          top: 180,
					bottom: 160,
          left: 50,
          right: 30,
        ),
        child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
							style: const TextStyle(fontSize: 42),
              textAlign: TextAlign.left,
            ),
            Expanded(
							child: Align(
								alignment: AlignmentDirectional.centerStart,
								child: VisibilityDetector(
									key: Key(title),
									child: content,
									onVisibilityChanged: (v) {
										if(proceedCondition != null) {
											if (v.visibleFraction == 1) {
												canProceed.value = proceedCondition!();
											}
											else { 
												canProceed.value = true;
											}
										}
										else {
											if (v.visibleFraction == 1) canProceed.value = true;
										}
									}
								),
							)
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeButton extends StatelessWidget {
  const ThemeButton (this.mode, this.iconData, this.text, {this.autoSaveData, super.key});

	final ThemeMode mode;
	final IconData iconData;
	final String text;
	final bool? autoSaveData;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
			listenable: data,
			builder: (context, _) => 
				Padding(
					padding: const EdgeInsets.all(12),
					child: ClipRRect(
						borderRadius: BorderRadius.circular(12),
						child: Material(
							color: data.themeMode == mode ?
								Theme.of(context).colorScheme.primary :
								Theme.of(context).colorScheme.secondary.withOpacity(0.7),
							child: InkWell(
								onTap: (){
									data.setThemeMode(mode);
									if (autoSaveData == true) {
										saveData();
									}
								},
								child: Padding(
									padding: const EdgeInsets.all(14),
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											Icon(
												iconData,
												size: 58,
												color: Theme.of(context).colorScheme.onPrimary
											),
											const SizedBox(height: 8),
											Text(
												text,
												style: TextStyle(
													color: Theme.of(context).colorScheme.onPrimary),
												)
										],
									),
								)
							)
						)
					)
				)
		);
  }
}
