import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rover_app/providers/panels.dart';

/// Središnji dio ekrana
///
/// Sadrži [TabBarView] kojim se kontrolira biranje modula
/// Koristi [Panels] provider
class Panel extends StatelessWidget {
  const Panel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Panels>(
      builder: (context, panelsProvider, child) {
        /// Na svaku promijenu modula [TabBar] se ponovno prikazuje
        return DefaultTabController(
          length: panelsProvider.listOfPanels.length,
          child: Scaffold(
            bottomNavigationBar: TabBar(
              dividerColor: Colors.transparent,
              tabs: panelsProvider.listOfTabButtons,
              isScrollable: false,
              physics: const BouncingScrollPhysics(),
              labelColor: Colors.blueGrey,
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
                key: UniqueKey(), children: panelsProvider.getPanels()),
          ),
        );
      },
    );
  }
}
