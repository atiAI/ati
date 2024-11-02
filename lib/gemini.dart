import 'dart:convert';

import 'package:ati/data.dart';
import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:toastification/toastification.dart';

const kSuggestQuestionCount = 3;

String get atiBaseSP => 
			'Ati adında eğitsel bir yapay zekasın.'
			'Milli değerlerimize ve toplumsal ahlağa uymaya özen gösterirsin.\n'
			'- Sadece eğitsel sorulara cevap ver.'
				'Sana sorulan soruların cevaplarını direkt olarak cevaplamak yerine bir öğretmen gibi '
				'konuyu açıklayarak karşındakinin konuyu kavramasına yardımcı olacaksın. '
				'Karşındakine her zaman hoş görülü ve şefkatli ol.\n'
			'- Konuştuğun kişi ${data.user.age} yaşında, ${data.user.name} adında biri.';

const String atiGeneralQuestionSP = 
			'- Konuyu bir paragrafta kısaca açıkla. '
				'Konunun kavranması için eğer gerekiyorsa en az $kMinGorev en fazla $kMaxGorev görev ver. '
				'Görevler örnek soru, araştırma konusu, serbest ödev vb olabilir. '
				'Görevler olabildiğince deskriptif olsun. '
				'Sorudaki anahtar kelimelerin tümü her görevin içinde olmalı. '
				'Eğer bilimsel bir formül yazman gerekirse latex kullan.\n'
			'- Konuyu daha çok anlamak için gerekecek Google aramasını arama\'ya yaz.\n';

const String atiTaskHelpSP =
			'- Kullanıcıya verdiğin görevi yerine getirmesi için yardımcı olacaksın.\n'
			'- Kullanıcı görev hakkında kesin bir soru sorduysa sorduğu soruyu cevapla.\n'
			'- Kullanıcı görev hakkında belli bir soru sormadıysa görevi tamamlaması için gereken adımları anlat.\n';

String get atiQuestionSuggestSP =>
			'- Kullanıcının sorması için $kSuggestQuestionCount sayıda, kısa, 1 cümlelik yeni soru oluştur.\n'
			'- Sorular kısmına sadece oluşturduğun soruları yaz. Kullanıcı ile sohbet etme. Konu anlatımı yapma.\n'
			'- Konuştuğun kişi ${data.user.age} yaşında, ${data.user.name} adında biri.';

const String atiSafetyPrompt = 
			'- Sadece valid olan soruları cevapla\n'
			'- Eğer sana valid olmayan bir soru sorulursa, cevaplamayı kibarca reddet.\n'
			'- Valid konular eğitsel olanlardır.\n'
			'- Siyasi ve ideolojik sorulara ASLA cevap verme\n'
			'- Valid olmayan konular gaming, küfür, ahlak dışı şeyler, siyaset, devam eden savaşlar vb.\n'
			'- Eğer sana kendin hakkında bir soru sorulursa veya sana selam verilirse kim olduğunu tanıt, '
				'görev verme ve valid\'i false olarak işaretle.\n'
			'- Nasıl hissettiğini sorarlarsa iyi olduğunu söyle ve valid\'i false olarak işaretle\n';

class AtiGemini {
	static Future<GenerateContentResponse?> askGeneric(String prompt) async {
		var geminiKey = prefs.getString("geminiKey");
		if (geminiKey == null ) {
			toastification.show(
				title: const Text("API Anahtarı bulunamadı"),
				type: ToastificationType.error,
			);
			return null;
		}

		final model = GenerativeModel(
			model: 'gemini-1.5-flash',
			apiKey: geminiKey,
			generationConfig: GenerationConfig(
				temperature: 0,
				topK: 64,
				topP: 0.95,
				maxOutputTokens: 8192,
				responseMimeType: 'application/json',
				responseSchema: Schema(
					SchemaType.object,
					requiredProperties: ["valid", "Açıklama", "Konu", "Eğitim Düzeyi", "Görevler", "Zorluk"],
					properties: {
						"valid": Schema(
							SchemaType.boolean,
						),
						"Açıklama": Schema(
							SchemaType.string,
						),
						"Konu": Schema(
							SchemaType.string,	
							enumValues: [
								"Matematik",
								"Fizik",
								"Kimya",
								"Biyoloji",
								"Edebiyat",
								"Tarih",
								"Coğrafya",
								"Din",
								"Felsefe",
								"Yabancı Dil",
								"Kodlama",
								"Bilgisayar",
								"Elektronik",
								"Hukuk",
								"Mimarlık",
								"Tasarım",
								"Yapay Zeka",
								"Spor",
								"Genel Kültür"
							],
						),
						"Eğitim Düzeyi": Schema(
							SchemaType.string,
							enumValues: [
								"İlköğretim",
								"Lise",
								"Üniversite",
								"Yüksek Lisans",
								"İş Hayatı",
								"Genel"
							],
						),
						"Zorluk": Schema(
							SchemaType.number,
						),
						"Görevler": Schema(
							SchemaType.array,
							items: Schema(
								SchemaType.string,
							),
						),
						"Arama": Schema(
							SchemaType.string,
						),
					},
				),
			),
			systemInstruction: Content.system(
			[
			atiBaseSP,
			atiGeneralQuestionSP,
			atiSafetyPrompt,
			].join("\n")
			),
		);

		final chat = model.startChat(
			history: data.messages
			.map<Content>(
				(m){
					if (m.gorevRef != null) {
						return Content("model", [TextPart("Görev yardımı: ${m.gorevRef!.task}")]);
					}
					if (m.suggestion == true) {
						return Content("model", [
							TextPart("Önerilen sorular:"),
							...(jsonDecode(m.data!)["sorular"] as List)
								.map<TextPart>((s)=>TextPart("$s\n"))
						]);
					}
					return Content(m.role.genai, [TextPart(m.data ?? "")]);
				}
			).toList()
		);
		final content = Content.text(prompt);
		
		return chat.sendMessage(content);
	}

	static Future<GenerateContentResponse?> askTaskHelp(Task task, String? prompt) async {
		var geminiKey = prefs.getString("geminiKey");
		if (geminiKey == null ) {
			toastification.show(
				title: const Text("API Anahtarı bulunamadı"),
				type: ToastificationType.error,
			);
			return null;
		}

		final model = GenerativeModel(
			model: 'gemini-1.5-flash',
			apiKey: geminiKey,
			generationConfig: GenerationConfig(
				temperature: 0,
				topK: 64,
				topP: 0.95,
				maxOutputTokens: 8192,
				responseMimeType: 'text/plain',
			),
			systemInstruction: Content.system([
				atiBaseSP,
				atiTaskHelpSP,
				atiSafetyPrompt,
			].join("\n"))
		);

		final chat = model.startChat(history: [
			Content("user", [TextPart(task.soru)]),
			Content("model", [TextPart(task.description), TextPart(task.task)]),
		]);

		return chat.sendMessage(Content.text("Görev yardımı: ${prompt ?? ""}"));
	}

	static Future<GenerateContentResponse?> askQuestionSuggestions(String initialQuestion) async {
		var geminiKey = prefs.getString("geminiKey");
		if (geminiKey == null ) {
			toastification.show(
				title: const Text("API Anahtarı bulunamadı"),
				type: ToastificationType.error,
			);
			return null;
		}

		final model = GenerativeModel(
			model: 'gemini-1.5-flash',
			apiKey: geminiKey,
			generationConfig: GenerationConfig(
				temperature: 0,
				topK: 64,
				topP: 0.95,
				maxOutputTokens: 8192,
				responseMimeType: 'application/json',
				responseSchema: Schema.object(
					properties: {
						"sorular": Schema.array(
							items: Schema.string()
						)
					}, 
					requiredProperties: ["sorular"]
				)
			),
			systemInstruction: Content.system([
				atiBaseSP,
				atiQuestionSuggestSP,
				atiSafetyPrompt,
			].join("\n"))
		);

		final chat = model.startChat(history: [
		]);

		return chat.sendMessage(Content.multi([
			TextPart(initialQuestion)
		]));
	}
	
}





class AtiResponse {
	AtiResponse({
		required this.aciklama,
		required this.egitimDuzeyi,
		required this.konu,
		required this.gorevler,
		required this.valid,
		required this.difficulty,
		this.arama
	});

	final String aciklama;
	final String egitimDuzeyi;
	final double difficulty;
	final String konu;
	final List<String> gorevler;
	final bool valid;
	final String? arama;

	AtiResponse.fromJson(Map<String, dynamic> json)
			: aciklama = json["Açıklama"],
				egitimDuzeyi = json["Eğitim Düzeyi"],
				difficulty = json["Zorluk"],
				konu = json["Konu"],
				gorevler = (json["Görevler"] as List).map<String>((el)=>el.toString()).toList(),
				valid = json["valid"],
				arama = json["Arama"];

}


const Map<String,IconData?> atiIcons = {
	"Matematik": Icons.functions,
	"Fizik": Icons.rocket,
	"Kimya": Icons.science,
	"Biyoloji": Icons.biotech,
	"Edebiyat": Icons.library_books,
	"Tarih": Icons.history_edu,
	"Coğrafya": Icons.terrain,
	"Din": Icons.mosque,
	"Felsefe": Icons.lightbulb,
	"Yabancı Dil": Icons.record_voice_over,
	"Kodlama": Icons.code,
	"Bilgisayar": Icons.computer,
	"Elektronik": Icons.electrical_services,
	"Hukuk": Icons.gavel,
	"Mimarlık": Icons.architecture,
	"Tasarım": Icons.design_services,
	"Yapay Zeka": Icons.auto_awesome,
	"Spor": Icons.sports_score,
	"Genel Kültür": Icons.school,
};
