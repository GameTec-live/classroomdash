import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:classroomdash/helpers.dart';
import 'package:classroomdash/settings.dart';

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
  var selectedIndex = 0;

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

    switch (selectedIndex) {
      // Sidebar Navigation
      case 0:
        page = const Placeholder();
        break;
      case 1:
        page = const Placeholder();
        break;
      default:
        try {
          //page = ClassRoomPage(
          //    classRoom: appState.sharedPreferencesProvider.getClassRooms()[selectedIndex - 2]);
          page = const Placeholder();
        } catch (e) {
          page = const Placeholder();
        }
    }

    List<ClassRoom> classRooms = appState.sharedPreferencesProvider.getClassRooms();
    List<NavigationRailDestination> classRoomDest = [];
    // for every classroom add a new entry to classroomdest with the corrosponding name
    for (var i = 0; i < classRooms.length; i++) {
      classRoomDest.add(NavigationRailDestination(
        icon: Badge(
            label: Text(classRooms[i].names.length.toString()),
            child: const Icon(Icons.person_outline)),
        selectedIcon:
            Badge(label: Text(classRooms[i].names.length.toString()), child: const Icon(Icons.person)),
        label: Row(
          children: [
            Text(classRooms[i].name),
            IconButton(onPressed: () async {
              selectedIndex = i-1;
              classRooms.removeAt(i);
              appState.sharedPreferencesProvider.setClassRooms(classRooms);
              appState.changesMade();
            }, icon: const Icon(Icons.delete))
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        key: appState.navigationRailKey,
                        leading: FloatingActionButton(
                          elevation: 0,
                          onPressed: () async {
                            ClassRoom room = ClassRoom(
                                name: "Test",
                                names: ["Test1", "Test2", "Test3"],
                              );
                            classRooms.add(room);
                            appState.sharedPreferencesProvider.setClassRooms(classRooms);
                            appState.changesMade();
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
                            icon: Badge(
                                label: Text("28"), child: Icon(Icons.person_outline)),
                            selectedIcon:
                                Badge(label: Text("28"), child: Icon(Icons.person)),
                            label: Text("2AHIT"),
                          ),
                          const NavigationRailDestination(
                            icon: Badge(
                                label: Text("31"), child: Icon(Icons.person_outline)),
                            selectedIcon:
                                Badge(label: Text("31"), child: Icon(Icons.person)),
                            label: Text("3AHIT"),
                          ),
                          ...classRoomDest,
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
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
