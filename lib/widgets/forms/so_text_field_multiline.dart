import 'package:flutter/material.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SOTextFieldMultiline extends StatelessWidget {
  final String campo;

  const SOTextFieldMultiline({Key? key, required this.campo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField(
      clipBehavior: Clip.none,
      formControlName: campo,
      validationMessages: (control) => {
        ValidationMessage.required: '$campo es requerido',
      },
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: kPrimaryColor,
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        labelText: campo,
        labelStyle: const TextStyle(
          fontSize: 18,
          color: kSecondaryColor,
          fontFamily: 'CronosLPro',
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 18,
          color: kSecondaryColor,
          fontFamily: 'CronosSPro',
        ),
      ),
      minLines: 3,
      maxLines: 3,
    );
  }
}
