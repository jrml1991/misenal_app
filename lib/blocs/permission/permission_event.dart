part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class GpsAndPermissionEvent extends PermissionEvent {
  final bool isGpsEnabled;
  final bool isGpsPermissionGranted;
  final bool isPhonePermissionGranted;
  final bool isBackgroundLocationEnabled;
  final bool isDataEnabled;
  final bool isSetPhone;
  final bool isCameraPermissionGranted;

  const GpsAndPermissionEvent(
      {required this.isGpsEnabled,
      required this.isGpsPermissionGranted,
      required this.isPhonePermissionGranted,
      required this.isBackgroundLocationEnabled,
      required this.isDataEnabled,
      required this.isSetPhone,
      required this.isCameraPermissionGranted});
}

class OnAddPhoneEvent extends PermissionEvent {
  final bool isSetPhone;

  const OnAddPhoneEvent({
    required this.isSetPhone,
  });
}
