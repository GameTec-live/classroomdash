import 'dart:convert';
import 'package:classroomdash/colors.dart' as colors;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Student {
  String name;
  bool present;

  Student({required this.name, this.present = true});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String,
    );
  }
}

class ClassRoom {
  String id;
  String name;
  List<Student> students;

  ClassRoom({String? id, this.name = "", List<Student>? students})
      : id = id ?? const Uuid().v4(),
        students = students ?? [];

  String toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'students': students.map((e) => e.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  factory ClassRoom.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    final id = data['id'] as String;
    final name = data['name'] as String;
    final savedStudents = data['students'] as List<dynamic>;

    List<Student> students = savedStudents.map((studentData) {
      return Student.fromJson(studentData as Map<String, dynamic>);
    }).toList();

    return ClassRoom(id: id, name: name, students: students);
  }
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
