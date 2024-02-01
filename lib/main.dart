import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:classroomdash/helpers.dart';
import 'package:classroomdash/settings.dart';
import 'package:classroomdash/classroompage.dart';
import 'package:classroomdash/homepage.dart';
import 'package:classroomdash/create_menu.dart';

// Shared Preferences Provider
import 'package:classroomdash/sharedprefsprovider.dart';

// Logger
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferencesProvider = SharedPreferencesProvider();
  await sharedPreferencesProvider.load();
  runApp(ClassRoomDash(sharedPreferencesProvider));
}

class ClassRoomDash extends StatelessWidget {
  // Root Widget
  final SharedPreferencesProvider _sharedPreferencesProvider;
  const ClassRoomDash(this._sharedPreferencesProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _sharedPreferencesProvider),
        ChangeNotifierProvider(
          create: (context) => ClassRoomDashState(_sharedPreferencesProvider),
        ),
      ],
      child: MainPage(sharedPreferencesProvider: _sharedPreferencesProvider),
    );
  }
}

class ClassRoomDashState extends ChangeNotifier {
  final SharedPreferencesProvider sharedPreferencesProvider;
  ClassRoomDashState(this.sharedPreferencesProvider);

  SharedPreferencesProvider? _sharedPreferencesProvider;
  Logger? log;
  int selectedIndex = 0;

  GlobalKey navigationRailKey = GlobalKey();
  Size? navigationRailSize;

  void changesMade() {
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.sharedPreferencesProvider});

  final SharedPreferencesProvider sharedPreferencesProvider;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //var selectedIndex = 0;
  bool confirmingdeletion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => updateNavigationRailWidth(context));
  }

  @override
  void reassemble() async {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ClassRoomDashState>();
    appState._sharedPreferencesProvider = widget.sharedPreferencesProvider;
    appState.log ??= Logger();

    if (appState.sharedPreferencesProvider.getSideBarAutoExpansion()) {
      double width = MediaQuery.of(context).size.width;
      if (width >= 600) {
        appState.sharedPreferencesProvider.setSideBarExpanded(true);
      } else {
        appState.sharedPreferencesProvider.setSideBarExpanded(false);
      }
    }

    Widget page; // Set Page

    switch (appState.selectedIndex) {
      // Sidebar Navigation
      case 0:
        page = HomePage(
            classRooms: appState.sharedPreferencesProvider.getClassRooms());
        break;
      case 1:
        List<Student> students = [];
        for (var i = 0; i < 50; i++) {
          students.add(Student(name: "Test Student ${i + 1}"));
        }
        page = ClassRoomPage(
            classroom:
                ClassRoom(name: "Example", students: students)); // Example
        break;
      default:
        try {
          page = ClassRoomPage(
              classroom: appState.sharedPreferencesProvider
                  .getClassRooms()[appState.selectedIndex - 2]);
        } catch (e) {
          throw Exception("Classroom not found");
        }
    }

    List<ClassRoom> classRooms =
        appState.sharedPreferencesProvider.getClassRooms();
    List<NavigationRailDestination> classRoomDest = [];
    // for every classroom add a new entry to classroomdest with the corrosponding name
    for (var i = 0; i < classRooms.length; i++) {
      classRoomDest.add(NavigationRailDestination(
        icon: Badge(
            label: Text(classRooms[i].students.length.toString()),
            child: const Icon(Icons.person_outline)),
        selectedIcon: Badge(
            label: Text(classRooms[i].students.length.toString()),
            child: const Icon(Icons.person)),
        label: Row(
          children: [
            Text(classRooms[i].name),
            const SizedBox(
              width: 2,
            ),
            IconButton(
                onPressed: () async {
                  if (appState.sharedPreferencesProvider.getConfirmDelete() ==
                      true) {
                    if (confirmingdeletion == false) {
                      setState(() {
                        confirmingdeletion = true;
                      });

                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() {
                            confirmingdeletion = false;
                          });
                        }
                      });
                      return;
                    }
                  }

                  appState.selectedIndex = 0;
                  classRooms.removeAt(i);
                  appState.sharedPreferencesProvider.setClassRooms(classRooms);
                  appState.changesMade();
                },
                icon: confirmingdeletion
                    ? const Icon(Icons.delete_forever)
                    : const Icon(Icons.delete))
          ],
        ),
      ));
    }

    return MaterialApp(
      title: 'Classroom Dash', // App Name
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: widget.sharedPreferencesProvider.getThemeColor()),
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: ColorScheme.fromSeed(
                        seedColor:
                            widget.sharedPreferencesProvider.getThemeColor(),
                        brightness: Brightness.light)
                    .surface,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: widget.sharedPreferencesProvider.getThemeColor(),
            brightness: Brightness.dark),
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: ColorScheme.fromSeed(
                        seedColor:
                            widget.sharedPreferencesProvider.getThemeColor(),
                        brightness: Brightness.dark)
                    .surface,
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light)),
      ),
      themeMode: widget.sharedPreferencesProvider.getTheme(), // Dark Theme
      home: LayoutBuilder(// Build Page
          builder: (context, constraints) {
        bool isexp = appState.sharedPreferencesProvider.getSideBarExpanded();
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        key: appState.navigationRailKey,
                        leading: FloatingActionButton(
                          elevation: 0,
                          onPressed: () async {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    const AlertDialog(
                                        title: Text("Create a classroom"),
                                        content: CreateMenu()));
                          },
                          child: const Icon(Icons.add),
                        ),
                        trailing: Expanded(
                            child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              elevation: 0,
                              onPressed: () async {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        const AlertDialog(
                                            title: Text("Settings"),
                                            content: SettingsMainPage()));
                              },
                              child: const Icon(Icons.settings),
                            ),
                          ),
                        )),
                        // Sidebar
                        extended: isexp,
                        labelType: isexp ? null : NavigationRailLabelType.all,
                        destinations: [
                          // Sidebar Items
                          const NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: Text("Home"),
                          ),
                          const NavigationRailDestination(
                            icon: Badge(
                                label: Text("50"),
                                child: Icon(Icons.person_outline)),
                            selectedIcon: Badge(
                                label: Text("50"), child: Icon(Icons.person)),
                            label: Text("Example"),
                          ),
                          ...classRoomDest,
                        ],
                        selectedIndex: appState.selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            appState.selectedIndex = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
