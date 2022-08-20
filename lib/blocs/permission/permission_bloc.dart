import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  StreamSubscription? gpsServiceSubscription;
  StreamSubscription? dataServiceSubscription;

  PermissionBloc()
      : super(const PermissionState(
            isGpsEnabled: false,
            isGpsPermissionGranted: false,
            isPhonePermissionGranted: false,
            isBackgroundLocationEnabled: false,
            isDataEnabled: false,
            isSetPhone: false,
            isCameraPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) {
      return emit(
        state.copyWith(
          isGpsEnabled: event.isGpsEnabled,
          isGpsPermissionGranted: event.isGpsPermissionGranted,
          isPhonePermissionGranted: event.isPhonePermissionGranted,
          isBackgroundLocationEnabled: event.isBackgroundLocationEnabled,
          isDataEnabled: event.isDataEnabled,
          isSetPhone: event.isSetPhone,
          isCameraPermissionGranted: event.isCameraPermissionGranted,
        ),
      );
    });
    on<OnAddPhoneEvent>((event, emit) {
      return emit(
        state.copyWith(
          isSetPhone: event.isSetPhone,
        ),
      );
    });

    _init();
  }

  Future<void> _init() async {
    //llamar multiples futures simultaneos
    final permissionInitStatus = await Future.wait([
      _checkGpsStatus(),
      _isPermissionGranted(),
      _isPhonePermissionGranted(),
      _checkLocBackgroundGranted(),
      _checkDataStatus(),
      _isSetPhone(),
      _isCameraPermissionGranted(),
    ]);

    add(
      GpsAndPermissionEvent(
        isGpsEnabled: permissionInitStatus[0],
        isGpsPermissionGranted: permissionInitStatus[1],
        isPhonePermissionGranted: permissionInitStatus[2],
        isBackgroundLocationEnabled: permissionInitStatus[3],
        isDataEnabled: permissionInitStatus[4],
        isSetPhone: permissionInitStatus[5],
        isCameraPermissionGranted: permissionInitStatus[6],
      ),
    );
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  Future<bool> _isCameraPermissionGranted() async {
    final isGranted = await Permission.camera.isGranted;
    return isGranted;
  }

  Future<bool> _isSetPhone() async {
    final prefs = await SharedPreferences.getInstance();

    final String? actual = prefs.getString('telefono');
    if (actual == null || actual == '') {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _checkLocBackgroundGranted() async {
    final isGranted = await Permission.locationAlways.isGranted;
    return isGranted;
  }

  Future<bool> _isPhonePermissionGranted() async {
    final isGranted = await Permission.phone.isGranted;
    return isGranted;
  }

  Future<bool> _checkGpsStatus() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();

    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isPhonePermissionGranted: state.isPhonePermissionGranted,
          isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted));
    });
    return isEnabled;
  }

  Future<bool> _checkDataStatus() async {
    bool isEnabled = false;

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isEnabled = true;
      }

      dataServiceSubscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        final isEnabled = (result == ConnectivityResult.mobile ||
                result == ConnectivityResult.wifi)
            ? true
            : false;
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled,
            isGpsPermissionGranted: state.isGpsPermissionGranted,
            isPhonePermissionGranted: state.isPhonePermissionGranted,
            isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
            isDataEnabled: isEnabled,
            isSetPhone: state.isSetPhone,
            isCameraPermissionGranted: state.isCameraPermissionGranted));
      });
    } catch (e) {
      return true;
    }

    return isEnabled;
  }

  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();
    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled,
            isGpsPermissionGranted: true,
            isPhonePermissionGranted: state.isPhonePermissionGranted,
            isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
            isDataEnabled: state.isDataEnabled,
            isSetPhone: state.isSetPhone,
            isCameraPermissionGranted: state.isCameraPermissionGranted));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: false,
          isPhonePermissionGranted: state.isPhonePermissionGranted,
          isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted,
        ));
        openAppSettings();
    }
  }

  Future<void> askCameraAccess() async {
    final status = await Permission.camera.request();
    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled,
            isGpsPermissionGranted: true,
            isPhonePermissionGranted: state.isPhonePermissionGranted,
            isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
            isDataEnabled: state.isDataEnabled,
            isSetPhone: state.isSetPhone,
            isCameraPermissionGranted: true));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled,
            isGpsPermissionGranted: false,
            isPhonePermissionGranted: state.isPhonePermissionGranted,
            isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
            isDataEnabled: state.isDataEnabled,
            isSetPhone: state.isSetPhone,
            isCameraPermissionGranted: false));
        openAppSettings();
    }
  }

  Future<void> askPhoneAccess() async {
    final status = await Permission.phone.request();
    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
          isPhonePermissionGranted: true,
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted,
        ));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
          isPhonePermissionGranted: false,
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isBackgroundLocationEnabled: state.isBackgroundLocationEnabled,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted,
        ));
        openAppSettings();
    }
  }

  Future<void> askBackgroundLocation() async {
    final status = await Permission.locationAlways.request();
    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
          isPhonePermissionGranted: state.isPhonePermissionGranted,
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isBackgroundLocationEnabled: true,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted,
        ));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
          isPhonePermissionGranted: state.isPhonePermissionGranted,
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isBackgroundLocationEnabled: false,
          isDataEnabled: state.isDataEnabled,
          isSetPhone: state.isSetPhone,
          isCameraPermissionGranted: state.isCameraPermissionGranted,
        ));
        openAppSettings();
    }
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    dataServiceSubscription?.cancel();
    return super.close();
  }
}
