import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misenal_app/blocs/blocs.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:misenal_app/widgets/widgets.dart';

class GpsAccessPage extends StatefulWidget {
  const GpsAccessPage({Key? key}) : super(key: key);

  @override
  State<GpsAccessPage> createState() => _GpsAccessPageState();
}

class _GpsAccessPageState extends State<GpsAccessPage> {
  final FormGroup datosForm = FormGroup({
    'telefono': FormControl<String>(
      validators: [
        Validators.required,
        Validators.maxLength(8),
        Validators.minLength(8),
      ],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            Future.delayed(const Duration(milliseconds: 0), () {
              if (!state.isGpsPermissionGranted && !state.isGpsEnabled) {
                //mostrado = true;
              }
            });

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Permisos necesarios para utilizar esta aplicación",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kSecondaryColor,
                              fontSize: 24,
                              fontFamily: 'CronosSPro'),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      !state.isGpsEnabled
                          ? const _EnableGpsMessage()
                          : Container(),
                      !state.isDataEnabled ? const Divider() : Container(),
                      !state.isDataEnabled
                          ? const _EnableDataMessage()
                          : Container(),
                      !state.isGpsPermissionGranted
                          ? const Divider()
                          : Container(),
                      !state.isGpsPermissionGranted
                          ? const _AccessButton()
                          : Container(),
                      !state.isPhonePermissionGranted
                          ? const Divider()
                          : Container(),
                      !state.isPhonePermissionGranted
                          ? const _AccessPhoneStateButton()
                          : Container(),
                      !state.isBackgroundLocationEnabled
                          ? const Divider()
                          : Container(),
                      !state.isBackgroundLocationEnabled
                          ? const _AccessLocBackgroundButton()
                          : Container(),
                      !state.isCameraPermissionGranted
                          ? const Divider(
                              height: 50,
                            )
                          : Container(),
                      !state.isCameraPermissionGranted
                          ? const _AccessCameraButton()
                          : Container(),
                      !state.isSetPhone
                          ? const Divider(
                              height: 50,
                            )
                          : Container(),
                      !state.isSetPhone ? phoneForm() : Container(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget phoneForm() {
    return ReactiveForm(
      formGroup: datosForm,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomInputText(
            ctrlName: 'telefono',
            label: 'Número de Teléfono',
            type: FilteringTextInputFormatter.digitsOnly,
            borderColor: kPrimaryColor,
          ),
          const SizedBox(
            width: 10,
          ),
          MaterialButton(
            color: kSecondaryColor,
            shape: const StadiumBorder(),
            elevation: 0,
            splashColor: Colors.transparent,
            onPressed: () async {
              final permissionBloc = BlocProvider.of<PermissionBloc>(context);
              final prefs = await SharedPreferences.getInstance();
              if (datosForm.valid) {
                await prefs.setString(
                    'telefono', datosForm.control('telefono').value);

                permissionBloc.add(
                  const OnAddPhoneEvent(
                    isSetPhone: true,
                  ),
                );
              }
            },
            child: const Text(
              "       Guardar       ",
              style: TextStyle(color: Colors.white, fontFamily: 'CronosLPro'),
            ),
          )
        ],
      ),
    );
  }
}

class _AccessButton extends StatefulWidget {
  const _AccessButton({
    Key? key,
  }) : super(key: key);

  @override
  State<_AccessButton> createState() => _AccessButtonState();
}

class _AccessButtonState extends State<_AccessButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Es necesario el acceso al GPS",
          style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
        ),
        MaterialButton(
            color: kPrimaryColor,
            shape: const StadiumBorder(),
            elevation: 0,
            splashColor: Colors.transparent,
            onPressed: () {
              final permissionBloc = BlocProvider.of<PermissionBloc>(context);
              permissionBloc.askGpsAccess();
            },
            child: const Text(
              "Solicitar Acceso",
              style: TextStyle(color: Colors.white, fontFamily: 'CronosLPro'),
            ))
      ],
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Debe habilitar el GPS',
      style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
    );
  }
}

class _EnableDataMessage extends StatelessWidget {
  const _EnableDataMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Debe habilitar los Datos Móviles',
      style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
    );
  }
}

class _AccessPhoneStateButton extends StatelessWidget {
  const _AccessPhoneStateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            "Es necesario Acceso a Datos del Teléfono",
            style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
          ),
        ),
        MaterialButton(
          color: kPrimaryColor,
          shape: const StadiumBorder(),
          elevation: 0,
          splashColor: Colors.transparent,
          onPressed: () {
            final permissionBloc = BlocProvider.of<PermissionBloc>(context);
            permissionBloc.askPhoneAccess();
          },
          child: const Text(
            "Solicitar Acceso ",
            style: TextStyle(color: Colors.white, fontFamily: 'CronosLPro'),
          ),
        )
      ],
    );
  }
}

class _AccessCameraButton extends StatelessWidget {
  const _AccessCameraButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            "Es necesario Acceso a la cámara",
            style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
          ),
        ),
        MaterialButton(
          color: kPrimaryColor,
          shape: const StadiumBorder(),
          elevation: 0,
          splashColor: Colors.transparent,
          onPressed: () {
            final permissionBloc = BlocProvider.of<PermissionBloc>(context);
            permissionBloc.askCameraAccess();
          },
          child: const Text(
            "Solicitar Acceso ",
            style: TextStyle(color: Colors.white, fontFamily: 'CronosLPro'),
          ),
        )
      ],
    );
  }
}

class _AccessLocBackgroundButton extends StatelessWidget {
  const _AccessLocBackgroundButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            "Es necesario el Acceso a la Localización en Background",
            style: TextStyle(fontSize: 18, fontFamily: 'CronosLPro'),
          ),
        ),
        MaterialButton(
          color: kPrimaryColor,
          shape: const StadiumBorder(),
          elevation: 0,
          splashColor: Colors.transparent,
          onPressed: () {
            final permissionBloc = BlocProvider.of<PermissionBloc>(context);
            permissionBloc.askBackgroundLocation();
          },
          child: const Text(
            "Solicitar Acceso",
            style: TextStyle(color: Colors.white, fontFamily: 'CronosLPro'),
          ),
        )
      ],
    );
  }
}
