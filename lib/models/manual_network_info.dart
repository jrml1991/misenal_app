import 'dart:convert';
import 'package:misenal_app/models/models.dart';

ManualNetworkInfo manualNetworkInfoFromMap(String str) =>
    ManualNetworkInfo.fromMap(json.decode(str));
String manualNetworkInfoToJson(ManualNetworkInfo data) =>
    json.encode(data.toJson());

class ManualNetworkInfo extends Model {
  static String table = 'manualnetworkinfo';
  String? id_lectura;
  String? zona;
  String? ambiente;
  String? tipoAmbiente;
  String? descripcionAmbiente;
  String? comentarios;
  String? fotografia;
  String? enviado;

  ManualNetworkInfo({
    id,
    this.id_lectura,
    this.zona,
    this.ambiente,
    this.tipoAmbiente,
    this.descripcionAmbiente,
    this.comentarios,
    this.fotografia,
    this.enviado,
  }) : super(id);

  static ManualNetworkInfo fromMap(Map<String, dynamic> json) {
    return ManualNetworkInfo(
      id: json['id'],
      id_lectura: json['id_lectura'].toString(),
      zona: json['zona'].toString(),
      ambiente: json['tipoAmbiente'].toString(),
      tipoAmbiente: json['modelo'].toString(),
      descripcionAmbiente: json['descripcionAmbiente'].toString(),
      comentarios: json['comentarios'].toString(),
      fotografia: json['fotografia'].toString(),
      enviado: json['enviado'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "id_lectura": id_lectura,
      "zona": zona,
      "ambiente": ambiente,
      "tipoAmbiente": tipoAmbiente,
      "descripcionAmbiente": descripcionAmbiente,
      "comentarios": comentarios,
      "fotografia": fotografia,
      "enviado": enviado,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  ManualNetworkInfo copyWith({
    int? id,
    String? id_lectura,
    String? zona,
    String? ambiente,
    String? tipoAmbiente,
    String? descripcionAmbiente,
    String? comentarios,
    String? fotografia,
    String? enviado,
  }) =>
      ManualNetworkInfo(
        id: id ?? this.id,
        id_lectura: id_lectura ?? this.id_lectura,
        zona: zona ?? this.zona,
        ambiente: ambiente ?? this.ambiente,
        tipoAmbiente: tipoAmbiente ?? this.tipoAmbiente,
        descripcionAmbiente: descripcionAmbiente ?? this.descripcionAmbiente,
        comentarios: comentarios ?? this.comentarios,
        fotografia: fotografia ?? this.fotografia,
        enviado: enviado ?? this.enviado,
      );
}
