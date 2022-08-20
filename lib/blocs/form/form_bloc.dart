import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  FormBloc() : super(const FormState()) {
    on<OnInitEvent>((event, emit) {
      emit(
        state.copyWith(
          formulario: event.formulario,
          inicializado: event.inicializado,
        ),
      );
    });

    //_init();
  }
/*
  Future<void> _init() async {
    final form = loadForm();
    add(
      OnInitEvent(
        formulario: form,
        inicializado: true,
      ),
    );
  }

  Form loadForm() {
    String titulo = "Marcación Manual";
    String name = "marcacion_manual";

    List<Input> campos = [
      Input(
          ctrlName: "tipo_captura",
          label: "Tipo de Captura",
          type: "Seleccion Unica",
          opciones: ["Interior", "Exterior"]),
      Input(
          ctrlName: "tipo_lugar",
          label: "Característica del Lugar",
          type: "Seleccion Unica",
          opciones: ["Parque", "Montaña", "Calle", "Casa", "Edificio"]),
      Input(
        ctrlName: "observaciones",
        label: "Observaciones",
        type: "Abierta Texto",
      ),
    ];

    Form formulario = Form(
      name: name,
      title: titulo,
      fields: campos,
    );

    return formulario;
  }
*/
/*
  ReactiveFormBuilder buildForm(Form formulario) {
    final campos = formulario.fields;

    Map<String, Object> _portaInfoMap = {
      "name": "Vitalflux.com",
      "domains": ["Data Science", "Mobile", "Web"],
      "noOfArticles": [
        {"type": "data science", "count": 50},
        {"type": "web", "count": 75}
      ]
    };

    campos.forEach((campo) {
      final current = {
        campo.ctrlName!: ['', Validators.required]
      };

      _portaInfoMap.addEntries([..._portaInfoMap.entries, ...current.entries,]);
    });

    FormGroup form = fb.group(_portaInfoMap);
    return ReactiveFormBuilder(
      form: () => form,
      builder: (context, form, child) {
        return Column(
          children: [
            
          ],
        );
      },
    );
  }*/
}
