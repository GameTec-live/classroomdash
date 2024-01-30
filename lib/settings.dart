import 'package:classroomdash/component/toggle_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classroomdash/main.dart';
import 'package:classroomdash/helpers.dart';

class SettingsMainPage extends StatefulWidget {
  const SettingsMainPage({super.key});

  @override
  SettingsMainPageState createState() => SettingsMainPageState();
}

class SettingsMainPageState extends State<SettingsMainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ClassRoomDashState>();
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text("Sidebar expansion",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ToggleButtonsWrapper(
                items: const ["Expand", "Auto", "Retract"],
                selectedValue: appState.sharedPreferencesProvider
                    .getSideBarExpandedIndex(),
                onChange: (int index) async {
                  if (index == 0) {
                    appState.sharedPreferencesProvider.setSideBarExpanded(true);
                    appState.sharedPreferencesProvider
                        .setSideBarAutoExpansion(false);
                  } else if (index == 2) {
                    appState.sharedPreferencesProvider
                        .setSideBarExpanded(false);
                    appState.sharedPreferencesProvider
                        .setSideBarAutoExpansion(false);
                  } else {
                    appState.sharedPreferencesProvider
                        .setSideBarAutoExpansion(true);
                  }
                  appState.sharedPreferencesProvider
                      .setSideBarExpandedIndex(index);
                  appState.changesMade();

                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => updateNavigationRailWidth(context));
                }),
            const SizedBox(height: 10),
            const Text(
              "Theme",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ToggleButtonsWrapper(
                items: const ["System", "Light", "Dark"],
                selectedValue:
                    appState.sharedPreferencesProvider.getTheme().index,
                onChange: (int index) async {
                  appState.sharedPreferencesProvider
                      .setTheme(ThemeMode.values[index]);
                  appState.changesMade();
                }),
            const SizedBox(height: 10),
            const Text(
              "Color scheme",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            DropdownButton(
              value: appState.sharedPreferencesProvider.getThemeColorIndex(),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (value) {
                appState.sharedPreferencesProvider.setThemeColor(value ?? 0);
                appState.changesMade();
              },
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text("Default"),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text("Purple"),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text("Blue"),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text("Green"),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text("Indigo"),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text("Lime"),
                ),
                DropdownMenuItem(
                  value: 6,
                  child: Text("Red"),
                ),
                DropdownMenuItem(
                  value: 7,
                  child: Text("Yellow"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Confirm deletions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Switch(
                  value: appState.sharedPreferencesProvider.getConfirmDelete(),
                  onChanged: (value) async {
                    appState.sharedPreferencesProvider.setConfirmDelete(value);
                    appState.changesMade();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
