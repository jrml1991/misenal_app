import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Login sample'),
            ),
            ListTile(
              title: const Text('Complex sample'),
            ),
            ListTile(
              title: const Text('Simple sample'),
            ),
            ListTile(
              title: const Text('Array sample'),
            ),
            ListTile(
              title: const Text('Datepicker sample'),
            ),
            ListTile(
              title: const Text('Reactive forms widgets'),
            ),
            // ListTile(
            //   title: Text('Disable form sample'),
            //   onTap: () => Navigator.of(context).pushReplacementNamed(
            //     Routes.disableFormSample,
            //   ),
            // ),
            // ListTile(
            //   title: Text('Add dynamic controls'),
            //   onTap: () => Navigator.of(context).pushReplacementNamed(
            //     Routes.addDynamicControls,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
