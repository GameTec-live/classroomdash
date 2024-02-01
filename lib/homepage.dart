import 'package:flutter/material.dart';
import 'package:classroomdash/sharedprefsprovider.dart';
import 'package:provider/provider.dart';
import 'package:classroomdash/main.dart';
import 'package:classroomdash/create_menu.dart';

class HomePage extends StatelessWidget {
  final List<ClassRoom> classRooms;
  const HomePage({super.key, required this.classRooms});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ClassRoomDashState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Dash'),
      ),
      body: classRooms.isEmpty
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Classroom dashboard", style: TextStyle(fontSize: 40)),
                    Text("by Benedikt Werner aka GameTec_live"),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Create a classroom to get started",
                        style: TextStyle(fontSize: 30))
                  ],
                ),
              ],
            )
          : ListView.builder(
              itemCount: classRooms.length,
              itemBuilder: (context, index) {
                final classRoom = classRooms[index];
                return ListTile(
                  title: Row(
                    children: [
                      Badge(
                        label: Text(classRoom.students.length.toString()),
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(classRoom.name),
                    ],
                  ),
                  onTap: () {
                    appState.selectedIndex = index + 2;
                    appState.changesMade();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => const AlertDialog(
                  title: Text("Create a classroom"), content: CreateMenu()));
        },
      ),
    );
  }
}
