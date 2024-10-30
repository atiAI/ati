import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:flutter/cupertino.dart';
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

  Brightness brightness = Brightness.dark;

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
            color: Colors.white70,
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
			OnboardingPage(
				title: "Yaşın?",
				content: CupertinoPicker(
					itemExtent: 48,
					onSelectedItemChanged: (value) {data.user.age = value;},
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
				)
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
						color: Colors.white
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
												foregroundColor: Colors.white,
												disabledForegroundColor: Colors.grey
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
        padding: const EdgeInsets.only(
          top: 180,
					bottom: 160,
          left: 112,
          right: 96,
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
