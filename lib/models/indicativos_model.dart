// To parse this JSON data, do
//
//     final indicativosPaises = indicativosPaisesFromJson(jsonString);

import 'dart:convert';

List<IndicativosPaises> indicativosPaisesFromJson(String str) => List<IndicativosPaises>.from(json.decode(str).map((x) => IndicativosPaises.fromJson(x)));

String indicativosPaisesToJson(List<IndicativosPaises> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IndicativosPaises {
    String? nameEs;
    String? nameEn;
    String? iso2;
    String? iso3;
    String? phoneCode;

    IndicativosPaises({
        this.nameEs,
        this.nameEn,
        this.iso2,
        this.iso3,
        this.phoneCode,
    });

    factory IndicativosPaises.fromJson(Map<String, dynamic> json) => IndicativosPaises(
        nameEs: json["nameES"],
        nameEn: json["nameEN"],
        iso2: json["iso2"],
        iso3: json["iso3"],
        phoneCode: json["phoneCode"],
    );

    Map<String, dynamic> toJson() => {
        "nameES": nameEs,
        "nameEN": nameEn,
        "iso2": iso2,
        "iso3": iso3,
        "phoneCode": phoneCode,
    };
}

class Pais {
  final String nombreES;
  final String nombreEN;
  final String iso2;
  final String iso3;
  final String phoneCode;

  Pais({
    required this.nombreES,
    required this.nombreEN,
    required this.iso2,
    required this.iso3,
    required this.phoneCode,
  });

  String get bandera {
    // Convertir código ISO a emoji de bandera
    final flagOffset = 0x1F1E6;
    final asciiOffset = 0x41;

    final firstChar = iso2.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = iso2.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  String get indicativo => '+$phoneCode';

  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      nombreES: json['nameES'] as String,
      nombreEN: json['nameEN'] as String,
      iso2: json['iso2'] as String,
      iso3: json['iso3'] as String,
      phoneCode: json['phoneCode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'nameES': nombreES,
        'nameEN': nombreEN,
        'iso2': iso2,
        'iso3': iso3,
        'phoneCode': phoneCode,
      };
}

class Indicativos {
  final List<Pais> paises;

  Indicativos({required this.paises});

  factory Indicativos.fromJson(List<dynamic> json) {
    return Indicativos(
      paises: json.map((e) => Pais.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  List<dynamic> toJson() => paises.map((e) => e.toJson()).toList();
}
