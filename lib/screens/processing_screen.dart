import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misenal_app/blocs/blocs.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:misenal_app/widgets/forms/so_rounded_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late Animation<double> agrandar;
  late AnimationController btnController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    agrandar = Tween(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: btnController,
        curve: Curves.easeOut,
      ),
    );

    //Agregamos un listener
    btnController.addListener(() {
      if (btnController.status == AnimationStatus.completed) {
        btnController.repeat();
      }
    });
  }

  @override
  void dispose() {
    btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kSecondaryColor.withOpacity(0.9),
            kSecondaryColor.withOpacity(0.6),
            kPrimaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -9,
                right: -9,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: kThirdColor,
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.stretchedDots(
                      color: kThirdColor,
                      size: 60.0,
                    ),
                    Text(
                      state.mensaje,
                      style: const TextStyle(
                        fontFamily: 'CronosLPro',
                        fontSize: 18,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
