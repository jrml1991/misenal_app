import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misenal_app/blocs/blocs.dart';
import 'package:misenal_app/services/db_service.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:misenal_app/widgets/heart_beat_painter.dart';
import 'package:misenal_app/widgets/widgets.dart';
import 'package:wakelock/wakelock.dart';
import 'package:workmanager/workmanager.dart';

Future<void> doTask() async {
  NetworkInfoBloc info = NetworkInfoBloc();

  //EN INICIALIZACION de NetworkInfoBloc SE LLAMA A ACTUALIZAR / ENVIAR DATOS
  await info.actualizarDatos(esBackground: true);
  await info.enviarDatos();
}

void callBackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await doTask();
    return Future.value(true);
  });
}

class TrackingPage extends StatefulWidget {
  final AnimationController? animationController;
  const TrackingPage({Key? key, this.animationController}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  late Animation<double> agrandar;
  late AnimationController btnController;
  late AnimationController heartController;
  late Animation<double> opacidad;
  late Animation<double> heart;

  List<Widget> listWidgets = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  late NetworkInfoBloc networkInfoBloc;

  DBService _db = DBService();

  @override
  void initState() {
    super.initState();
    networkInfoBloc = BlocProvider.of<NetworkInfoBloc>(context);
    networkInfoBloc.init(
      esBackground: false,
    );

    _db.getInformacionDia();

    btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    agrandar = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: btnController,
        curve: Curves.easeOut,
      ),
    );

    heart = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: heartController,
        curve: Curves.easeOut,
      ),
    );

    opacidad = Tween(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: btnController,
        curve: const Interval(0, 1, curve: Curves.easeOut),
      ),
    );

    //Agregamos un listener
    btnController.addListener(() {
      if (btnController.status == AnimationStatus.completed) {
        btnController.reverse();
      } else if (btnController.status == AnimationStatus.dismissed) {
        btnController.forward();
      }
    });

    //Agregamos un listener
    heartController.addListener(() {
      if (heartController.status == AnimationStatus.completed) {
        heartController.repeat();
      }
    });

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    btnController.dispose();
    heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //iniciamos la animación

    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            getListofWidgets(),
            getAppBarTracking(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget getListofWidgets() {
    return BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
      builder: (context, state) {
        if (!state.actualizado) {
          return const Center(child: CircularProgressIndicator());
        }
        //NetworkInfo info = state.info!;

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top +
                35,
            bottom: 62 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: 4,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            widget.animationController?.forward();
            switch (index) {
              case 0:
                return Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.07,
                  ),
                  child: const Text(
                    "Lectura Automática",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'CronosSPro',
                      fontSize: 18,
                    ),
                  ),
                );
              case 1:
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCircularContainer(
                      radius: 200,
                    ),
                    _buildCircularContainer(
                      radius: 250,
                    ),
                    _buildCircularContainer(
                      radius: 300,
                    ),
                    Align(
                      child: Center(
                        child: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                          builder: (context, state) {
                            btnController.forward();
                            heartController.forward();
                            return GestureDetector(
                              child: state.activado
                                  ? _BotonTracking(
                                      label: "Detener",
                                    )
                                  : _BotonTracking(
                                      label: "Iniciar",
                                    ),
                              onTap: () async {
                                NetworkInfoBloc bloc = NetworkInfoBloc();

                                if (state.activado) {
                                  await Workmanager().cancelAll();
                                  await Wakelock.disable();
                                } else {
                                  await Workmanager().initialize(
                                    callBackDispatcher,
                                    //isInDebugMode: true,
                                  );
                                  await Workmanager().registerPeriodicTask(
                                    '1',
                                    'signal_tracker',
                                    frequency: const Duration(minutes: 15),
                                    initialDelay: const Duration(minutes: 10),
                                  );
                                  await Wakelock.enabled;
                                }
                                networkInfoBloc.toogleActivado();
                              },
                            );
                          },
                        ),
                      ),
                    )
                  ],
                );
              case 2:
                return Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.07,
                  ),
                  child: const Text(
                    "Mi Gestión",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'CronosSPro',
                      fontSize: 18,
                    ),
                  ),
                );
              case 3:
                return Container(
                  height: 245,
                  padding: const EdgeInsets.all(10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: false,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 25),
                    children: [
                      SOBlueIconCard(
                        title: "Hoy",
                        asset: 'assets/images/calendar.png',
                        content: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                          builder: (context, state) {
                            if (state.guardando) {
                              return const CircularProgressIndicator();
                            }
                            return FutureBuilder<List<int>>(
                              future: _db.getInformacionDia(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final informacion = snapshot.data!;

                                return Column(
                                  children: [
                                    SOIconLabel(
                                      label: "${informacion[1]} manuales",
                                      asset: 'assets/icons/phone.svg',
                                      size: const Size(18, 18),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    SOIconLabel(
                                      label: "${informacion[0]} automáticas",
                                      asset: 'assets/icons/trophy.svg',
                                      size: const Size(18, 18),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                        top: 30,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${informacion[0] + informacion[1]}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: kThirdColor,
                                              fontFamily: 'CronosLPro',
                                              fontSize: 24,
                                            ),
                                          ),
                                          const Text(
                                            " lecturas",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: kThirdColor,
                                              fontFamily: 'CronosLPro',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SOBlueIconCard(
                        title: 'Este mes',
                        asset: 'assets/images/month.png',
                        content: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                          builder: (context, state) {
                            if (state.guardando) {
                              return const CircularProgressIndicator();
                            }
                            return FutureBuilder<List<int>>(
                                future: _db.getInformacionMes(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  final informacion = snapshot.data!;

                                  return Column(
                                    children: [
                                      SOIconLabel(
                                        label: "${informacion[1]} manuales",
                                        asset: 'assets/icons/phone.svg',
                                        size: const Size(18, 18),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      SOIconLabel(
                                        label: "${informacion[0]} automáticas",
                                        asset: 'assets/icons/trophy.svg',
                                        size: const Size(18, 18),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                          top: 30,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${informacion[0] + informacion[1]}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: kThirdColor,
                                                fontFamily: 'CronosLPro',
                                                fontSize: 24,
                                              ),
                                            ),
                                            const Text(
                                              " lecturas",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: kThirdColor,
                                                fontFamily: 'CronosLPro',
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SOBlueIconCard(
                        title: 'Sin sincronizar',
                        asset: 'assets/images/no-internet.png',
                        content: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                          builder: (context, state) {
                            if (state.guardando) {
                              return const CircularProgressIndicator();
                            }
                            return FutureBuilder<List<int>>(
                                future: _db.getInformacionSinSincronizar(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  final informacion = snapshot.data!;

                                  return Column(
                                    children: [
                                      SOIconLabel(
                                        label: "${informacion[1]} manuales",
                                        asset: 'assets/icons/phone.svg',
                                        size: const Size(18, 18),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      SOIconLabel(
                                        label: "${informacion[0]} automáticas",
                                        asset: 'assets/icons/trophy.svg',
                                        size: const Size(18, 18),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                          top: 5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${informacion[0] + informacion[1]}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: kThirdColor,
                                                fontFamily: 'CronosLPro',
                                                fontSize: 24,
                                              ),
                                            ),
                                            const Text(
                                              " lecturas",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: kThirdColor,
                                                fontFamily: 'CronosLPro',
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                );

              default:
                return const SizedBox(
                  height: 10,
                );
            }
          },
        );
      },
    );
  }

  Widget _buildCircularContainer({
    required double radius,
  }) {
    return AnimatedBuilder(
      animation: agrandar,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            top: (radius - agrandar.value * radius) / 2,
            bottom: (radius - agrandar.value * radius) / 2,
          ),
          width: agrandar.value * radius,
          height: agrandar.value * radius,
          decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(1 - agrandar.value),
              shape: BoxShape.circle),
        );
      },
    );
  }

  Widget getAppBarTracking() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: kPrimaryColor //FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Tracking de Red',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'CronosSPro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22 + 6 - 6 * topBarOpacity,
                                      letterSpacing: 1.2,
                                      color:
                                          kSecondaryColor //FitnessAppTheme.darkerText,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.signal_cellular_4_bar_rounded,
                                  color:
                                      kSecondaryColor, //FitnessAppTheme.grey,
                                  size: 22 + 6 - 6 * topBarOpacity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _BotonTracking({required String label}) {
    return AnimatedBuilder(
      animation: heart,
      builder: (context, child) {
        return Container(
          width: 200, //* agrandar.value,
          height: 200, // * agrandar.value,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: kSecondaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomPaint(
                  painter: HeartBeatPainter(
                      progress: heart.value,
                      color: kPrimaryColor,
                      beat: label == 'Detener')),
              const SizedBox(
                height: 0,
              ),
              Text(
                label,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 32,
                  fontFamily: 'CronosLPro',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
