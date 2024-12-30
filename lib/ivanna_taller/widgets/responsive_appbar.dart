import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/custom_appbar.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/tablet_appbar.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  ResponsiveAppBar({super.key, required bool isTablet})
      : preferredSize = Size.fromHeight(
          isTablet ? kToolbarHeight * 1.25 : kToolbarHeight * 1.25,
        );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double tabletThreshold = 600;

    if (size.width > tabletThreshold) {
      return const TabletAppBar();
    } else {
      return const CustomAppBar();
    }
  }
}
