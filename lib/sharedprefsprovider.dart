import 'dart:convert';
import 'package:classroomdash/colors.dart' as colors;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class ClassRoom {
  String id;
  String name;
  List<String> names;

  factory ClassRoom.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    final id = data['id'] as String;
    final name = data['name'] as String;
    final savedNames = data['names'] as List<dynamic>;

    List<String> names = [];
    for (var key in savedNames) {
      names.add(key);
    }
    return ClassRoom(id: id, name: name, names: names,);
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'color': name,
      'names': names.map((key) => key).toList()
    });
  }



  ClassRoom(
      {String? id,
      this.name = "",
      this.names = const []})
      : id = id ?? const Uuid().v4();
}

class SharedPreferencesProvider extends ChangeNotifier {
  SharedPreferencesProvider._privateConstructor();

  static final SharedPreferencesProvider _instance =
      SharedPreferencesProvider._privateConstructor();

  factory SharedPreferencesProvider() {
    return _instance;
  }

  late SharedPreferences _sharedPreferences;

  Future<void> load() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  ThemeMode getTheme() {
    final themeValue = _sharedPreferences.getInt('app_theme') ?? 0;
    return ThemeMode.values[themeValue];
  }

  void setTheme(ThemeMode theme) {
    _sharedPreferences.setInt('app_theme', theme.index);
  }

  bool getSideBarAutoExpansion() {
    return _sharedPreferences.getBool('sidebar_auto_expanded') ?? true;
  }

  bool getSideBarExpanded() {
    return _sharedPreferences.getBool('sidebar_expanded') ?? false;
  }

  int getSideBarExpandedIndex() {
    return _sharedPreferences.getInt('sidebar_expanded_index') ?? 1;
  }

  void setSideBarAutoExpansion(bool autoExpanded) {
    _sharedPreferences.setBool('sidebar_auto_expanded', autoExpanded);
  }

  void setSideBarExpanded(bool expanded) {
    _sharedPreferences.setBool('sidebar_expanded', expanded);
  }

  void setSideBarExpandedIndex(int index) {
    _sharedPreferences.setInt('sidebar_expanded_index', index);
  }

  int getThemeColorIndex() {
    return _sharedPreferences.getInt('app_theme_color') ?? 0;
  }

  MaterialColor getThemeColor() {
    return colors.getThemeColor(getThemeColorIndex());
  }

  Color getThemeComplementaryColor() {
    final themeMode = _sharedPreferences.getInt('app_theme') ?? 2;
    return colors.getThemeComplementary(themeMode, getThemeColorIndex());
  }

  void setThemeColor(int color) {
    _sharedPreferences.setInt('app_theme_color', color);
  }



  List<ClassRoom> getClassRooms() {
    List<ClassRoom> output = [];
    final data = _sharedPreferences.getStringList('classrooms') ?? [];
    for (var classroom in data) {
      output.add(ClassRoom.fromJson(classroom));
    }
    return output;
  }

  void setClassRooms(List<ClassRoom> classrooms) {
    List<String> output = [];
    for (var classroom in classrooms) {
      if (classroom.id != "") {
        output.add(classroom.toJson());
      }
    }
    _sharedPreferences.setStringList('classrooms', output);
  }

  bool getConfirmDelete() {
    return _sharedPreferences.getBool('confirm_delete') ?? true;
  }

  void setConfirmDelete(bool value) {
    _sharedPreferences.setBool('confirm_delete', value);
  }
}