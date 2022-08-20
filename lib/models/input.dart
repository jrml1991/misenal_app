import 'package:flutter/cupertino.dart';

class Input {
  final String? ctrlName;
  final String? label;
  final String? type;
  final Color? borderColor;
  final Color? labelColor;
  final List<String> opciones;

  Input({
    this.ctrlName,
    this.label,
    this.type,
    this.borderColor,
    this.labelColor,
    this.opciones = const [],
  });

  Input copyWith({
    String? ctrlName,
    String? label,
    String? type,
    Color? borderColor,
    Color? labelColor,
    List<String>? opciones,
  }) =>
      Input(
        ctrlName: ctrlName ?? this.ctrlName,
        label: label ?? this.label,
        type: type ?? this.type,
        borderColor: borderColor ?? this.borderColor,
        labelColor: labelColor ?? this.labelColor,
        opciones: opciones ?? this.opciones,
      );
}
