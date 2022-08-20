part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

class OnInitEvent extends FormEvent {
  final Form formulario;
  final bool inicializado;

  const OnInitEvent({
    required this.formulario,
    required this.inicializado,
  });
}
