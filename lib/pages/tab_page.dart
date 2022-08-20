import 'package:flutter/material.dart';
import 'package:misenal_app/pages/pages.dart';
import 'package:misenal_app/ui/app_styles.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController animationController;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SOSnackBarContent(
              title: "¡Tranquilo!",
              content:
                  "Todas tus lecturas serán sincronizadas automaticamente."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    });*/
  }

  void onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 0) {
            setState(() {
              if (selectedIndex == 1) {
                selectedIndex = 0;
              }
            });
            _pageController.animateToPage(selectedIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          }

          // Swiping in left direction.
          if (details.delta.dx < 0) {
            setState(() {
              if (selectedIndex == 0) {
                selectedIndex = 1;
              }
            });
            _pageController.animateToPage(selectedIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    TrackingPage(
                      animationController: animationController,
                    ),
                    ReportePage(
                      animationController: animationController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SlidingClippedNavBar.colorful(
        backgroundColor: kSecondaryColor,
        onButtonPressed: onButtonPressed,
        iconSize: 30,
        selectedIndex: selectedIndex,
        barItems: <BarItem>[
          BarItem(
            icon: Icons.network_cell_rounded,
            title: 'Tracking de Red',
            activeColor: kPrimaryColor,
            inactiveColor: Colors.white,
          ),
          BarItem(
            icon: Icons.list_outlined,
            title: 'Reporte',
            activeColor: kPrimaryColor,
            inactiveColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
