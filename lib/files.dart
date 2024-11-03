import 'dart:io';
import 'dart:ui';

import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

const kMaxFileSize = 20 * 1024 * 1024; // 20mb

ValueNotifier<File?> selectedFile = ValueNotifier(null);

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(title: const Text("Dosyalarım")),
			body: Column(children: [
				Flexible(
					flex: 10,
					child: ListenableBuilder(
						listenable: data, 
						builder: (context, _) => 
							ListView(children: 
								data.files.map( (f) =>
									Padding(
									padding: const EdgeInsets.symmetric(
										vertical: 12,
										horizontal: 24
									),
									child: Material(
										borderRadius: BorderRadius.circular(12),
										color: Theme.of(context).colorScheme.primary,
										child: InkWell(
											borderRadius: BorderRadius.circular(12),
											onTap: (){
												selectedFile.value = f;
												Navigator.pop(context);
												if (currentPage.value != 0) {
													homePageController.animateToPage(
														0,
														duration: const Duration(milliseconds: 500),
														curve: Curves.easeInOut
														);
													currentPage.value = 0;
												}
											},
											child: 
											Padding(
												padding: const EdgeInsets.all(8),
												child: Row(
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
													children: [
														Flexible(
															child: Row(children: [
																const Icon(Icons.insert_drive_file_outlined),
																const SizedBox(width: 10),
																Flexible(
																	child: Text(f.path.split("/").last),
																)
															])
														),
														Align(
															alignment: AlignmentDirectional.centerEnd,
															child:IconButton(
																onPressed: (){
																	data.removeFile(f);
																},
																icon: Icon(
																	Icons.delete_outline,
																	color: Theme.of(context).colorScheme.error,
																)
															)
														)
													]
												),
											)
										),
									))
								).toList()
								)
					)
				),
				Flexible(
					flex: 9,
					child: Container(
						decoration: BoxDecoration(
							color: Theme.of(context).appBarTheme.backgroundColor,
							borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
						),
						child: Padding(
							padding: const EdgeInsets.all(32),
							child: CustomPaint(
								painter: DashRectPainter(
									Theme.of(context).appBarTheme.foregroundColor!,
									const Radius.circular(32),
									8
								),
								child: InkWell(
									onTap: () async {
										FilePickerResult? result = await FilePicker.platform.pickFiles();

										if (result == null) {
											return;
										}
										for (var f in result.files){
											if (f.size < kMaxFileSize) {
												final file = File(f.path!);
												if (!data.files.map((f)=>f.path).contains(f.path!)){
													data.addFile(file);
												}
												else {
													toastification.show(
														closeOnClick: true,
														title: const Text(
														 "Dosya zaten yüklü."
														),
														description: Text(f.path!.split("/").last),
														autoCloseDuration: const Duration(seconds: 2),
														type: ToastificationType.warning
													);
												}
											}
											else {
												toastification.show(
													closeOnClick: true,
													title: Text(
														"${f.path!.split("/").last} çok büyük."
													),
													description: const Text(
														"Yüklenen dosyalar en fazla 20MB olabilir"
													),
													autoCloseDuration: const Duration(seconds: 2),
													type: ToastificationType.error
												);
											}
										}

									},
									child: const Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch,
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(Icons.file_upload, size: 80,),
												Text("Dosya Ekle", textAlign: TextAlign.center)
											],
										)
									),
								)
							),
						)
					)
				),
			]),
		);

  }
}
class DashRectPainter extends CustomPainter {
	const DashRectPainter(this.color, this.radius, this.width);

	final Color color;
	final Radius radius;
	final double width;
	
@override
  void paint(Canvas canvas, Size size) {
    double dashWidth = width, dashSpace = width;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    // Create a path for the rounded rectangle
    final Path path = Path()..addRRect(roundedRect);

    // Create a dashed path along the rounded rectangle
    //double totalLength = path.computeMetrics().fold(0, (len, metric) => len + metric.length);
    double distance = 0.0;

    for (PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final double length = distance + dashWidth > metric.length ? metric.length - distance : dashWidth;
        final Path extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
      distance -= metric.length;  // Reset distance for next side of rounded rectangle
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

