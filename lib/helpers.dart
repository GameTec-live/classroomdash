import 'package:classroomdash/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> asyncSleep(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}


void updateNavigationRailWidth(BuildContext context) async {
  if (context.mounted) {
    var appState = Provider.of<ClassRoomDashState>(context, listen: false);
    await asyncSleep(500);
    appState.navigationRailSize =
        appState.navigationRailKey.currentContext!.size;
    appState.changesMade();
  }
}