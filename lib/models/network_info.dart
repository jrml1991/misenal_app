import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:misenal_app/models/models.dart';

NetworkInfo networkInfoFromMap(String str) =>
    NetworkInfo.fromMap(json.decode(str));
String networkInfoToJson(NetworkInfo data) => json.encode(data.toJson());

class NetworkInfo extends Model {
  static String table = 'networkinfo';
  String? id_lectura;
  String? telefono;
  String? marca;
  String? modelo;
  String? datos;
  String? localizacion;
  String? latitud;
  String? longitud;
  String? estadoRed;
  String? tipoRed;
  String? tipoTelefono;
  String? esRoaming;
  String? nivelSignal;
  String? dB;
  String? enviado;
  DateTime? fecha;
  String? rsrp;
  String? rsrq;
  String? rssi;
  String? rsrp_asu;
  String? rssi_asu;
  String? cqi;
  String? snr;
  String? cid;
  String? eci;
  String? enb;
  String? network_iso;
  String? network_mcc;
  String? network_mnc;
  String? pci;
  //propiedades para 3G
  String? cgi;
  String? ci;
  String? lac;
  String? psc;
  String? rnc;
  String? operator_name;
  String? isManual;
  String? background;
  String? fechaCorta;

  NetworkInfo({
    id,
    this.id_lectura,
    this.telefono,
    this.marca,
    this.modelo,
    this.datos,
    this.localizacion,
    this.latitud,
    this.longitud,
    this.estadoRed,
    this.tipoRed,
    this.tipoTelefono,
    this.esRoaming,
    this.nivelSignal,
    this.dB,
    this.enviado,
    this.fecha,
    this.rsrp,
    this.rsrq,
    this.rssi,
    this.rsrp_asu,
    this.rssi_asu,
    this.cqi,
    this.snr,
    this.cid,
    this.eci,
    this.enb,
    this.network_iso,
    this.network_mcc,
    this.network_mnc,
    this.pci,
    this.cgi,
    this.ci,
    this.lac,
    this.psc,
    this.rnc,
    this.operator_name,
    this.isManual = "No",
    this.background = "No",
    this.fechaCorta,
  }) : super(id);

  static NetworkInfo fromMap(Map<String, dynamic> json) {
    return NetworkInfo(
      id: json['id'],
      id_lectura: json['id_lectura'].toString(),
      telefono: json['telefono'].toString(),
      marca: json['marca'].toString(),
      modelo: json['modelo'].toString(),
      datos: json['datos'].toString(),
      localizacion: json['localizacion'].toString(),
      latitud: json['latitud'].toString(),
      longitud: json['longitud'].toString(),
      estadoRed: json['estadoRed'].toString(),
      tipoRed: json['tipoRed'].toString(),
      tipoTelefono: json['tipoTelefono'].toString(),
      esRoaming: json['esRoaming'],
      nivelSignal: json['nivelSignal'].toString(),
      dB: json['dB'].toString(),
      enviado: json['enviado'].toString(),
      fecha: DateTime.parse(json["fecha"]),
      rsrp: json['rsrp'].toString(),
      rsrq: json['rsrq'].toString(),
      rssi: json['rssi'].toString(),
      rsrp_asu: json['rsrp_asu'].toString(),
      rssi_asu: json['rssi_asu'].toString(),
      cqi: json['cqi'].toString(),
      snr: json['snr'].toString(),
      cid: json['cid'].toString(),
      eci: json['eci'].toString(),
      enb: json['enb'].toString(),
      network_iso: json['network_iso'].toString(),
      network_mcc: json['network_mcc'].toString(),
      network_mnc: json['network_mnc'].toString(),
      pci: json['pci'].toString(),
      cgi: json['cgi'].toString(),
      ci: json['ci'].toString(),
      lac: json['lac'].toString(),
      psc: json['psc'].toString(),
      rnc: json['rnc'].toString(),
      operator_name: json['operator_name'].toString(),
      isManual: json['isManual'].toString(),
      background: json['background'].toString(),
      fechaCorta: DateFormat.yMd().format(DateTime.parse(json["fecha"])),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "id_lectura": id_lectura,
      "telefono": telefono,
      "marca": marca,
      "modelo": modelo,
      "datos": datos,
      "localizacion": localizacion,
      "latitud": latitud,
      "longitud": longitud,
      "estadoRed": estadoRed,
      "tipoRed": tipoRed,
      "tipoTelefono": tipoTelefono,
      "esRoaming": esRoaming,
      "nivelSignal": nivelSignal,
      "dB": dB,
      "enviado": enviado,
      "fecha": fecha?.toIso8601String(),
      "rsrp": rsrp,
      "rsrq": rsrq,
      "rssi": rssi,
      "rsrp_asu": rsrp_asu,
      "rssi_asu": rssi_asu,
      "cqi": cqi,
      "snr": snr,
      "cid": cid,
      "eci": eci,
      "enb": enb,
      "network_iso": network_iso,
      "network_mcc": network_mcc,
      "network_mnc": network_mnc,
      "pci": pci,
      "cgi": cgi,
      "ci": ci,
      "lac": lac,
      "psc": psc,
      "rnc": rnc,
      "operator_name": operator_name,
      "isManual": isManual,
      "background": background,
      "fechaCorta": fechaCorta,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  NetworkInfo copyWith({
    int? id,
    String? id_lectura,
    String? telefono,
    String? marca,
    String? modelo,
    String? datos,
    String? localizacion,
    String? latitud,
    String? longitud,
    String? estadoRed,
    String? tipoRed,
    String? tipoTelefono,
    String? esRoaming,
    String? nivelSignal,
    String? dB,
    String? enviado,
    DateTime? fecha,
    String? rsrp,
    String? rsrq,
    String? rssi,
    String? rsrp_asu,
    String? rssi_asu,
    String? cqi,
    String? snr,
    String? cid,
    String? eci,
    String? enb,
    String? network_iso,
    String? network_mcc,
    String? network_mnc,
    String? pci,
    String? cgi,
    String? ci,
    String? lac,
    String? psc,
    String? rnc,
    String? operator_name,
    String? isManual,
    String? background,
    String? fechaCorta,
  }) =>
      NetworkInfo(
        id: id ?? this.id,
        id_lectura: id_lectura ?? this.id_lectura,
        telefono: telefono ?? this.telefono,
        marca: marca ?? this.marca,
        modelo: modelo ?? this.modelo,
        datos: datos ?? this.datos,
        localizacion: localizacion ?? this.localizacion,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
        estadoRed: estadoRed ?? this.estadoRed,
        tipoRed: tipoRed ?? this.tipoRed,
        tipoTelefono: tipoTelefono ?? this.tipoTelefono,
        esRoaming: esRoaming ?? this.esRoaming,
        nivelSignal: nivelSignal ?? this.nivelSignal,
        dB: dB ?? this.dB,
        enviado: enviado ?? this.enviado,
        fecha: fecha ?? this.fecha,
        rsrp: rsrp ?? this.rsrp,
        rsrq: rsrq ?? this.rsrq,
        rssi: rssi ?? this.rssi,
        rsrp_asu: rsrp_asu ?? this.rsrp_asu,
        rssi_asu: rssi_asu ?? this.rssi_asu,
        cqi: cqi ?? this.cqi,
        snr: rssi ?? this.snr,
        cid: cid ?? this.cid,
        eci: eci ?? this.eci,
        enb: enb ?? this.enb,
        network_iso: network_iso ?? this.network_iso,
        network_mcc: network_mcc ?? this.network_mcc,
        network_mnc: network_mnc ?? this.network_mnc,
        pci: pci ?? this.pci,
        cgi: cgi ?? this.cgi,
        ci: ci ?? this.ci,
        lac: lac ?? this.lac,
        psc: psc ?? this.psc,
        rnc: rnc ?? this.rnc,
        operator_name: operator_name ?? this.operator_name,
        isManual: isManual ?? this.isManual,
        background: background ?? this.background,
        fechaCorta: fechaCorta ?? this.fechaCorta,
      );
}
