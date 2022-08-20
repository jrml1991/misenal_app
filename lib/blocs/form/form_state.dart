part of 'form_bloc.dart';

class FormState extends Equatable {
  final Form? formulario;
  final bool inicializado;
  final bool valido;

  const FormState({
    this.formulario,
    this.inicializado = false,
    this.valido = false,
  });

  FormState copyWith({
    Form? formulario,
    bool? inicializado,
    bool? valido,
  }) =>
      FormState(
        formulario: formulario ?? this.formulario,
        inicializado: inicializado ?? this.inicializado,
        valido: valido ?? this.valido,
      );

  @override
  List<Object> get props => [
        inicializado,
        valido,
      ];
}
