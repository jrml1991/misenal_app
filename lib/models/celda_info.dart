import 'dart:convert';

CeldaInfo celdaInfoFromMap(String str) => CeldaInfo.fromMap(json.decode(str));
String celdaInfoToJson(CeldaInfo data) => json.encode(data.toJson());

class CeldaInfo {
  String? tipo;
  String? dbm;
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

  CeldaInfo({
    this.tipo,
    this.dbm,
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
  });

  static CeldaInfo fromMap(Map<String, dynamic> json) {
    return CeldaInfo(
      tipo: json['tipo'].toString(),
      dbm: json['dbm'].toString(),
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
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "tipo": tipo,
      "dbm": dbm,
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
    };

    return map;
  }

  CeldaInfo copyWith({
    String? tipo,
    String? dbm,
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
  }) =>
      CeldaInfo(
        tipo: tipo ?? this.tipo,
        dbm: dbm ?? this.dbm,
        rsrp: rsrp ?? this.rsrp,
        rsrq: rsrq ?? this.rsrq,
        rssi: rssi ?? this.rssi,
        rsrp_asu: rsrp_asu ?? this.rsrp_asu,
        rssi_asu: rssi_asu ?? this.rssi_asu,
        cqi: cqi ?? this.cqi,
        snr: snr ?? this.snr,
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
      );
}
