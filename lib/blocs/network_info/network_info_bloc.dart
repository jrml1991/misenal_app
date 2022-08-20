import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:cell_info/CellResponse.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_image_picker/image_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misenal_app/global/environment.dart';
import 'package:misenal_app/models/models.dart';
import 'package:misenal_app/services/db_service.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;

part 'network_info_event.dart';
part 'network_info_state.dart';

class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  DBService db = DBService();
  StreamSubscription? gpsServiceSubscription;
  // Lifted from Default carrier configs and max range of RSRP
  final List rsrpThresholds = [
    -115, // SIGNAL_STRENGTH_POOR
    -105, // SIGNAL_STRENGTH_MODERATE
    -95, // SIGNAL_STRENGTH_GOOD
    -85, // SIGNAL_STRENGTH_GREAT
  ];
  // Lifted from Default carrier configs and max range of RSRQ
  final List rsrqThresholds = [
    -19,
    /* SIGNAL_STRENGTH_POOR */
    -17,
    /* SIGNAL_STRENGTH_MODERATE */
    -14,
    /* SIGNAL_STRENGTH_GOOD */
    -12, /* SIGNAL_STRENGTH_GREAT */
  ];
  // Lifted from Default carrier configs and max range of RSSNR
  final List rssiThresholds = [
    -3,
    /* SIGNAL_STRENGTH_POOR */
    1,
    /* SIGNAL_STRENGTH_MODERATE */
    5,
    /* SIGNAL_STRENGTH_GOOD */
    13, /* SIGNAL_STRENGTH_GREAT */
  ];

  NetworkInfoBloc()
      : super(const NetworkInfoState(
          actualizado: false,
          activado: false,
          guardando: false,
          enviando: false,
        )) {
    on<ActualizarNuevaInfoEvent>((event, emit) {
      return emit(
        state.copyWith(
          actualizado: event.actualizado,
          info: event.info,
        ),
      );
    });
    on<ToogleActivadoEvent>((event, emit) {
      return emit(
        state.copyWith(
          activado: event.activado,
        ),
      );
    });
    on<OnGuardandoEvent>((event, emit) {
      return emit(
        state.copyWith(
          guardando: event.guardando,
          mensaje: event.mensaje,
        ),
      );
    });
    on<OnEnviandoEvent>((event, emit) {
      return emit(
        state.copyWith(
          enviando: event.enviando,
          mensaje: event.mensaje,
        ),
      );
    });
  }

  Future<void> init({required bool esBackground}) async {
    final info = await actualizarDatos(esBackground: esBackground);
    await enviarDatos();
    add(ActualizarNuevaInfoEvent(info: info, actualizado: true));

    final activado = await verificarActivado();
    add(ToogleActivadoEvent(
      activado: activado,
    ));
  }

  Future<bool> verificarActivado() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? actual = prefs.getBool('activado');
    if (actual == null) {
      return false;
    } else {
      return actual;
    }
  }

  Future<void> toogleActivado() async {
    final prefs = await SharedPreferences.getInstance();
    bool estadoFinal;
    final bool? actual = prefs.getBool('activado');
    if (actual == null) {
      await prefs.setBool('activado', true);
      estadoFinal = true;
    } else {
      await prefs.setBool('activado', !actual);
      estadoFinal = !actual;
    }

    add(ToogleActivadoEvent(
      activado: estadoFinal,
    ));
  }

  Future<NetworkInfo> actualizarDatos({required bool esBackground}) async {
    final telephony = Telephony.instance;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    DataState networkState = await telephony.cellularDataState;
    String strnetworkState = networkState.name;
    String? operatorName = await telephony.simOperatorName;
    var networkType = await telephony.dataNetworkType;
    PhoneType phoneType = await telephony.phoneType;
    bool? isNetworkRoaming = await telephony.isNetworkRoaming;

    String nivelSenal = "";

    try {
      List<SignalStrength> signalLevel = await telephony.signalStrengths;
      nivelSenal = signalLevel[0].name;
    } catch (e) {
      nivelSenal = "No Soportado";
    }

    String datosHabilitados = await _checkDataStatus();
    String localizacionHabilitada = await _checkGpsStatus();
    final signal = await _getSignal();

    LatLng coordenadas = await _getLocation();

    final androidInfo = await deviceInfoPlugin.androidInfo;

    final fechaCaptura = DateTime.now();
    final telefono = await _getPhoneNumber();

    final idCaptura =
        "$telefono${fechaCaptura.year}${fechaCaptura.month}${fechaCaptura.day}${fechaCaptura.hour}${fechaCaptura.minute}${fechaCaptura.second}${fechaCaptura.microsecond}";

    NetworkInfo info = NetworkInfo(
      id_lectura: idCaptura,
      telefono: telefono,
      marca: androidInfo.manufacturer,
      modelo: androidInfo.model,
      datos: datosHabilitados.toString(),
      localizacion: localizacionHabilitada,
      tipoRed: networkType.name,
      estadoRed: strnetworkState,
      fecha: fechaCaptura,
      esRoaming: isNetworkRoaming! ? 'SI' : 'NO',
      tipoTelefono: phoneType.name,
      nivelSignal: nivelSenal,
      longitud: coordenadas.longitude.toString(),
      latitud: coordenadas.latitude.toString(),
      dB: signal.dbm,
      rsrp: signal.rsrp,
      rsrq: signal.rsrq,
      rssi: signal.rssi,
      enviado: 'NO',
      rsrp_asu: signal.rsrp_asu,
      rssi_asu: signal.rssi_asu,
      cqi: signal.cqi,
      snr: signal.snr,
      cid: signal.cid,
      eci: signal.eci,
      enb: signal.enb,
      network_iso: signal.network_iso,
      network_mcc: signal.network_mcc,
      network_mnc: signal.network_mnc,
      pci: signal.pci,
      operator_name: operatorName.toString(),
      background: esBackground ? "SI" : "NO",
    );

    await db.addInformacion(info);

    return info;
  }

  Future<String> _getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();

    final String? telefono = prefs.getString('telefono');
    if (telefono == null || telefono == '') {
      return "";
    } else {
      return telefono;
    }
  }

  Future<String> _checkDataStatus() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.mobile) {
        return "Mobile";
      }

      if (connectivityResult == ConnectivityResult.wifi) {
        return "Wifi";
      }
    } catch (e) {
      return "No Identificado";
    }

    return "No Habilitado";
  }

  Future<LatLng> _getLocation() async {
    LatLng localizacion;
    try {
      var position = await Geolocator.getCurrentPosition();
      localizacion = LatLng(position.latitude, position.longitude);
    } catch (e) {
      localizacion = const LatLng(0, 0);
    }

    return localizacion;
  }

  Future<String> _checkGpsStatus() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();

    if (isEnabled) {
      return 'Habilitado';
    }

    if (!isEnabled) {
      return 'Deshabilitado';
    }

    return 'Error';
  }

  Future<CeldaInfo> _getSignal() async {
    CellsResponse cellsResponse;
    CeldaInfo celda = CeldaInfo();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String? platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion ?? "");

      cellsResponse = CellsResponse.fromJson(body);

      //Validamos que se pueda leer al menos una SIMCARD
      if (cellsResponse.primaryCellList!.isNotEmpty) {
        CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
        if (currentCellInFirstChip.type == "LTE") {
          //4G
          celda = CeldaInfo(
            tipo: currentCellInFirstChip.type,
            dbm: currentCellInFirstChip.lte!.signalLTE!.dbm.toString(),
            rsrp: currentCellInFirstChip.lte!.signalLTE!.rsrp.toString(),
            rsrq: currentCellInFirstChip.lte!.signalLTE!.rsrq.toString(),
            rssi: currentCellInFirstChip.lte!.signalLTE!.rssi.toString(),
            rsrp_asu: currentCellInFirstChip.lte!.signalLTE!.rsrpAsu.toString(),
            rssi_asu: currentCellInFirstChip.lte!.signalLTE!.rssiAsu.toString(),
            cqi: currentCellInFirstChip.lte!.signalLTE!.cqi.toString(),
            snr: currentCellInFirstChip.lte!.signalLTE!.snr.toString(),
            cid: currentCellInFirstChip.lte!.cid!.toString(),
            eci: currentCellInFirstChip.lte!.eci!.toString(),
            enb: currentCellInFirstChip.lte!.enb!.toString(),
            network_iso: currentCellInFirstChip.lte!.network!.iso.toString(),
            network_mcc: currentCellInFirstChip.lte!.network!.mcc.toString(),
            network_mnc: currentCellInFirstChip.lte!.network!.mnc.toString(),
            pci: currentCellInFirstChip.lte!.pci!.toString(),
          );
        } else if (currentCellInFirstChip.type == "NR") {
          //5G
          celda = CeldaInfo(
            tipo: currentCellInFirstChip.type,
            dbm: currentCellInFirstChip.nr!.signalNR!.dbm.toString(),
            rsrp: currentCellInFirstChip.nr!.signalNR!.ssRsrp.toString(),
            rsrq: currentCellInFirstChip.nr!.signalNR!.ssRsrq.toString(),
            rsrp_asu: currentCellInFirstChip.nr!.signalNR!.ssRsrpAsu.toString(),
            network_iso: currentCellInFirstChip.nr!.network!.iso.toString(),
            network_mcc: currentCellInFirstChip.nr!.network!.mcc.toString(),
            network_mnc: currentCellInFirstChip.nr!.network!.mnc.toString(),
            pci: currentCellInFirstChip.nr!.pci!.toString(),
          );
        } else if (currentCellInFirstChip.type == "WCDMA") {
          celda = CeldaInfo(
            tipo: currentCellInFirstChip.type,
            dbm: currentCellInFirstChip.wcdma!.signalWCDMA!.dbm.toString(),
            cgi: currentCellInFirstChip.wcdma!.cgi,
            network_iso: currentCellInFirstChip.wcdma!.network!.iso.toString(),
            network_mcc: currentCellInFirstChip.wcdma!.network!.mcc.toString(),
            network_mnc: currentCellInFirstChip.wcdma!.network!.mnc.toString(),
            ci: currentCellInFirstChip.wcdma!.ci!.toString(),
            lac: currentCellInFirstChip.wcdma!.lac!.toString(),
            psc: currentCellInFirstChip.wcdma!.psc!.toString(),
            rnc: currentCellInFirstChip.wcdma!.rnc!.toString(),
            cid: currentCellInFirstChip.wcdma!.cid!.toString(),
          );
        } else if (currentCellInFirstChip.type == "GSM") {
          //3G
          celda = CeldaInfo(
            tipo: currentCellInFirstChip.type,
            dbm: currentCellInFirstChip.gsm!.signalGSM!.dbm.toString(),
            /*cgi: currentCellInFirstChip.wcdma!.cgi == null
                ? ""
                : currentCellInFirstChip.wcdma!.cgi,
            network_iso: currentCellInFirstChip.wcdma!.network!.iso.toString(),
            network_mcc: currentCellInFirstChip.wcdma!.network!.mcc.toString(),
            network_mnc: currentCellInFirstChip.wcdma!.network!.mnc.toString(),
            ci: currentCellInFirstChip.wcdma!.ci!.toString(),
            lac: currentCellInFirstChip.wcdma!.lac!.toString(),
            psc: currentCellInFirstChip.wcdma!.psc!.toString(),
            rnc: currentCellInFirstChip.wcdma!.rnc!.toString(),
            cid: currentCellInFirstChip.wcdma!.cid!.toString(),*/
          );
        }
      }
    } on PlatformException {
      //cellsResponse = null;
    }

    return celda;
  }

  Future<void> enviarDatos() async {
    DBService db = DBService();

    final infoList = await db.getInformacion();

    final now = DateTime.now();
    for (var info in infoList) {
      if (info.fecha!.isBefore(now.subtract(const Duration(days: 3))) &&
          info.enviado!.toUpperCase() == 'SI') {
        db.deleteInformacion(info);
      } else if (info.enviado!.toUpperCase() == 'NO') {
        try {
          final data = {
            'brand': info.marca.toString(),
            'model': info.modelo.toString(),
            'capture_id': info.id_lectura.toString(),
            'phone_number': int.parse(info.telefono.toString()),
            'mobile_data': info.datos.toString(),
            'location': info.localizacion.toString(),
            'latitude': double.parse(info.latitud.toString()),
            'longitude': double.parse(info.longitud.toString()),
            'network_status': info.estadoRed.toString(),
            'network_type': info.tipoRed.toString(),
            'smarthpone_type': info.tipoTelefono.toString(),
            'is_roaming': info.esRoaming.toString(),
            'signal_level': info.nivelSignal.toString(),
            'db': int.parse(info.dB == 'null' ? '0' : info.dB!),
            'date': info.fecha!.toIso8601String(),
            'rsrp': int.parse(info.rsrp == 'null' ? '0' : info.rsrp!),
            'rsrq': int.parse(info.rsrq == 'null' ? '0' : info.rsrq!),
            'rssi': int.parse(info.rssi == 'null' ? '0' : info.rssi!),
            'rssi_asu':
                int.parse(info.rssi_asu == 'null' ? '0' : info.rssi_asu!),
            'rsrp_asu':
                int.parse(info.rsrp_asu == 'null' ? '0' : info.rsrp_asu!),
            'cqi': info.cqi ?? '0',
            'snr': int.parse(info.snr == 'null' ? '0' : info.snr!),
            'cid': info.cid ?? 'Unknown',
            'eci': info.eci ?? 'Unknown',
            'enb': info.enb ?? 'Unknown',
            'network_iso': info.network_iso ?? 'Unknown',
            'network_mcc': info.network_mcc ?? 'Unknown',
            'network_mnc': info.network_mnc ?? 'Unknown',
            'pci': info.pci == 'null' ? 'Unknown' : info.pci!,
            'cgi': info.cgi == 'null' ? 'Unknown' : info.cgi!,
            'ci': info.ci == 'null' ? 'Unknown' : info.ci,
            'lac': info.lac == 'null' ? 'Unknown' : info.lac,
            'psc': info.psc == 'null' ? 'Unknown' : info.psc,
            'rnc': info.rnc == 'null' ? 'Unknown' : info.rnc,
            'operator_name': info.operator_name ?? 'Unknown',
            'is_background': info.background,
          };

          final resp = await http
              .post(
                Uri.parse('${Environment.apiURL}/guardar'),
                body: jsonEncode(data),
                headers: {'Content-Type': 'application/json'},
                encoding: Encoding.getByName('utf-8'),
              )
              .timeout(const Duration(seconds: 15));

          if (resp.statusCode == 200) {
            await db.updateInformacion(info.copyWith(enviado: 'SI'));
          }
        } on TimeoutException catch (_) {
          return;
        } catch (e) {
          return;
        }
      }
    }
  }

  Future<bool> guardarMarcacionManual({required FormGroup formulario}) async {
    final imageFile =
        File((formulario.control('Fotografia').value as ImageFile).image!.path);

    Uint8List imagebytes = await imageFile.readAsBytes(); //convert to bytes
    final imagen = base64.encode(imagebytes);

    final informacion = ManualNetworkInfo(
      id_lectura: formulario.control('Id').value,
      zona: formulario.control('Zona').value,
      ambiente: formulario.control('Ambiente').value,
      tipoAmbiente: formulario.control('Tipo Ambiente').value,
      comentarios: formulario.control('Comentarios').value,
      descripcionAmbiente: "No implementado",
      fotografia: imagen,
      enviado: "No",
    );

    //guardar información localmente
    add(const OnGuardandoEvent(
      guardando: true,
      mensaje: "Guardando localmente...",
    ));
    await db.addInformacionManual(informacion);
    add(const OnGuardandoEvent(
      guardando: false,
      mensaje: "Guardado localmente.",
    ));

    //enviar información
    add(const OnEnviandoEvent(
      enviando: true,
      mensaje: "Enviando datos...",
    ));
    await enviarDatosManuales();
    add(const OnEnviandoEvent(
      enviando: false,
      mensaje: "Enviado exitosamente.",
    ));
    return true;
  }

  Future<void> enviarDatosManuales() async {
    DBService db = DBService();

    final infoList = await db.getInformacionManual();

    for (var info in infoList) {
      try {
        if (info.enviado == 'No') {
          final data = {
            'id': info.id_lectura.toString(),
            'tipo_marcacion_manual': "No soportado",
            'zona': info.zona.toString(),
            'ambiente': info.ambiente.toString(),
            'tipo_ambiente': info.tipoAmbiente.toString(),
            'descr_ambiente': info.descripcionAmbiente.toString(),
            'comentarios': info.comentarios.toString(),
            'foto': info.fotografia.toString(),
          };

          final resp = await http
              .post(
                Uri.parse('${Environment.apiURL}/ejecucion_manual'),
                body: jsonEncode(data),
                headers: {'Content-Type': 'application/json'},
                encoding: Encoding.getByName('utf-8'),
              )
              .timeout(const Duration(seconds: 15));

          if (resp.statusCode == 200) {
            await db.updateInformacionManual(info.copyWith(enviado: 'Si'));
          }
        }
      } on TimeoutException catch (_) {
        return;
      } catch (e) {
        return;
      }
    }
  }
}
