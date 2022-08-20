import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_image_picker/image_file.dart';
import 'package:misenal_app/blocs/blocs.dart';
import 'package:misenal_app/screens/screens.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:misenal_app/widgets/headers.dart';
import 'package:misenal_app/widgets/widgets.dart';

class RegistroManualPage extends StatelessWidget {
  final String id;
  const RegistroManualPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final form = FormGroup({
      'Id': FormControl(
        validators: [
          Validators.required,
        ],
        value: id,
      ),
      'Zona': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'Ambiente': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'Tipo Ambiente': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'Comentarios': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'Fotografia': FormControl<ImageFile>(
        validators: [
          Validators.required,
        ],
      ),
    });

    Future openDialog() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => const AlertDialog(
              backgroundColor: Colors.transparent,
              content: ProcessingScreen(),
            ));

    return Scaffold(
      body: CustomPaint(
        painter: HeaderWavesGradientPainter(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: kPrimaryColor,
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Registro Manual",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'CronosSPro',
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 80),
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 10, left: 10, right: 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.1, 0.1),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: ReactiveFormBuilder(
                        form: () => form,
                        builder: (context, formulario, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SOSeleccionUnicaField(
                                campo: "Zona",
                                listaValores: "Rural,Urbana",
                                form: form,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SOSeleccionUnicaField(
                                campo: "Ambiente",
                                listaValores: "Interior,Exterior",
                                form: form,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SOSeleccionUnicaField(
                                campo: "Tipo Ambiente",
                                listaValores:
                                    "Parque,Montaña,Calle,Casa,Edificio",
                                form: form,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SOTextFieldMultiline(
                                campo: "Comentarios",
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SOPhotoField(
                                campo: "Fotografia",
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ReactiveFormConsumer(
                                        builder: (context, form, child) {
                                      return SORoundedButton(
                                        label: "Guardar",
                                        funcion: !form.valid
                                            ? () {
                                                form.markAllAsTouched();
                                              }
                                            : () {
                                                NetworkInfoBloc
                                                    networkInfoBloc =
                                                    BlocProvider.of<
                                                            NetworkInfoBloc>(
                                                        context);
                                                networkInfoBloc
                                                    .guardarMarcacionManual(
                                                  formulario: form,
                                                );
                                                openDialog();
                                              },
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: SORoundedButton(
                                      label: "Cerrar",
                                      funcion: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _onSubmit() {
  print('Formulario valido');
}
