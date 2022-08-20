import 'package:reactive_forms/reactive_forms.dart';
import 'package:misenal_app/models/input.dart';

class Form {
  final String? name;
  final String? title;
  final List<Input> fields;

  Form({
    this.name,
    this.title,
    this.fields = const [],
  });

  Form copyWith({
    String? name,
    String? title,
    List<Input>? fields,
  }) =>
      Form(
        name: name ?? this.name,
        title: title ?? this.title,
        fields: fields ?? this.fields,
      );
}
