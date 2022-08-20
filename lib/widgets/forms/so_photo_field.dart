import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:reactive_image_picker/reactive_image_picker.dart';

class SOPhotoField extends StatelessWidget {
  final String campo;

  const SOPhotoField({Key? key, required this.campo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReactiveImagePicker(
      formControlName: campo,
      validationMessages: (control) => {
        ValidationMessage.required: '$campo es requerido',
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelText: campo,
        labelStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'CronosLPro',
          color: kSecondaryColor,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'CronosSPro',
          color: kSecondaryColor,
        ),
        filled: false,
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
        disabledBorder: InputBorder.none,
        helperText: '',
      ),
      inputBuilder: (onPressed) => TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text(
          'Subir Foto',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'CronosLPro',
          ),
        ),
      ),
      maxHeight: 480,
      maxWidth: 480,
      popupDialogBuilder: obtenerImagen,
      imageViewBuilder: (imagen) {
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(20),
          child: Image.file(imagen.image!),
        );
      },
    );
  }
}

void obtenerImagen(
  BuildContext context,
  ImagePickCallback pickImage,
) {
  pickImage.call(context, ImageSource.camera);
}
