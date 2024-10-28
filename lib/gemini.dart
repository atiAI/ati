import 'package:ati/main.dart';
import 'package:ati/tasks.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:toastification/toastification.dart';

class AtiGemini {
	static Future<GenerateContentResponse?> ask(String prompt) async {
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
					requiredProperties: ["valid", "Açıklama", "Konu", "Eğitim Düzeyi", "Görevler"],
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
			'Ati adında eğitsel bir yapay zekasın.'
			'Milli değerlerimize ve toplumsal ahlağa uymaya özen gösterirsin.\n'
			'- Gençlerle ile iletişim kuracağın için gerektikçe emoji kullan.\n'
			'- Sadece eğitsel sorulara cevap ver. Sana sorulan soruların cevaplarını direkt olarak cevaplamak yerine bir öğretmen gibi konuyu açıklayarak karşındakinin konuyu kavramasına yardımcı olacaksın. Karşındakine her zaman hoş görülü ve şefkatli ol.\n'
			'- Konuyu bir paragrafta kısaca açıkla. Konunun kavranması için en az $kMinGorev en fazla $kMaxGorev görev ver. Görevler örnek soru, araştırma konusu, serbest ödev vb olabilir. Eğer bilimsel bir formül yazman gerekirse latex kullan.\n'
			'- Konuyu daha çok anlamak için gerekecek Google aramasını arama\'ya yaz.\n'
			'- Sadece valid olan soruları cevapla\n'
			'- Eğer sana valid olmayan bir soru sorulursa, cevaplamayı kibarca reddet.\n'
			'- Valid konular eğitsel olanlardır.\n'
			'- Siyasi ve ideolojik sorulara kesinlikle cevap verme\n'
			'- Valid olmayan konular gaming, küfür, ahlak dışı şeyler, siyaset, devam eden savaşlar vb.\n'
			'- Eğer sana kendin hakkında bir soru sorulursa veya sana selam verilirse kim olduğunu tanıt, görev verme ve valid\'i false olarak işaretle.'
			'- Nasıl hissettiğini sorarlarsa iyi olduğunu söyle ve valid\'i false olarak işaretle'
			),
		);

		final chat = model.startChat(history: [
		]);
		final content = Content.text(prompt);

		return chat.sendMessage(content);
	}
}

class AtiMessage {
	AtiMessage({
		required this.aciklama,
		required this.egitimDuzeyi,
		required this.konu,
		required this.gorevler,
		required this.valid,
		this.arama
	});

	final String aciklama;
	final String egitimDuzeyi;
	final String konu;
	final List<String> gorevler;
	final bool valid;
	final String? arama;

	static AtiMessage fromJson(Map<String, dynamic> json){
		return AtiMessage(
			aciklama: json["Açıklama"],
			egitimDuzeyi: json["Eğitim Düzeyi"],
			konu: json["Konu"],
			gorevler: (json["Görevler"] as List).map<String>((el)=>el.toString()).toList(),
			valid: json["valid"],
			arama: json["Arama"]
		);
	}
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
