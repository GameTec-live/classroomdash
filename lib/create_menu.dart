import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classroomdash/main.dart';
import 'package:classroomdash/sharedprefsprovider.dart';

class CreateMenu extends StatefulWidget {
  const CreateMenu({super.key});

  @override
  CreateMenuState createState() => CreateMenuState();
}

class CreateMenuState extends State<CreateMenu> {
  TextEditingController controller = TextEditingController();
  TextEditingController nameController = TextEditingController();
  List<String> entries = [];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ClassRoomDashState>();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Student Name',
                          ),
                          maxLines: null,
                          controller: controller,
                          onChanged: (text) {
                            controller.text = text.replaceAll('\t', ' ');
                            // check if the last character is a newline
                            if (text.isNotEmpty &&
                                text[text.length - 1] == '\n') {
                              // trim newlines
                              text = text.trimRight();
                              setState(() {
                                entries.addAll(text.split('\n'));
                              });
                              controller.clear();
                            }
                          },
                          onSubmitted: (text) {
                            setState(() {
                              entries.addAll(text.split('\n'));
                            });
                            controller.clear();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            entries.addAll(controller.text.split('\n'));
                          });
                          controller.clear();
                        },
                      ),
                    ],
                  );
                } else {
                  return ListTile(
                    title: Text(entries[index - 1]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          entries.removeAt(index - 1);
                        });
                      },
                    ),
                    onTap: () {
                      controller.text = entries[index - 1];
                      setState(() {
                        entries.removeAt(index - 1);
                      });
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Check if the user has entered anything
                    if (entries.isNotEmpty) {
                      // Sort alphabetically
                      entries.sort();
                      // Convert the strings to student
                      List<Student> students = [];
                      for (String entry in entries) {
                        students.add(Student(name: entry));
                      }
                      // Create the class
                      ClassRoom room = ClassRoom(
                        name: nameController.text,
                        students: students,
                      );
                      // Add the class to the list
                      List<ClassRoom> classRooms =
                          appState.sharedPreferencesProvider.getClassRooms();
                      classRooms.add(room);
                      appState.sharedPreferencesProvider
                          .setClassRooms(classRooms);
                      appState.changesMade();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
