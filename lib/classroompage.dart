import 'package:classroomdash/helpers.dart';
import 'package:flutter/material.dart';
import 'package:classroomdash/sharedprefsprovider.dart';
import 'dart:math';

class ClassRoomPage extends StatefulWidget {
  final ClassRoom classroom;
  const ClassRoomPage({super.key, required this.classroom});

  @override
  ClassRoomPageState createState() => ClassRoomPageState();
}

class ClassRoomPageState extends State<ClassRoomPage> {
  String _randomStudent = "";
  int _timerSeconds = 0;
  int _timerMinutes = 0;
  int _timerHours = 0;
  bool _timerRunning = false;
  int _stopwatchSeconds = 0;
  int _stopwatchMinutes = 0;
  int _stopwatchsHours = 0;
  bool _stopwatchRunning = false;

  @override
  Widget build(BuildContext context) {
    List<CheckboxListTile> studentTiles = [];

    for (var student in widget.classroom.students) {
      studentTiles.add(
        CheckboxListTile(
          title: Text(student.name),
          value: student.present,
          onChanged: (bool? value) {
            setState(() {
              student.present = value!;
            });
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name),
      ),
      body: Center(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ListView(
                children: studentTiles,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Column(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Random student",
                            style: TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_randomStudent,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                            onPressed: () async {
                              for (int i = 0; i < Random().nextInt(30) + 5; i++) {
                                final randomStudent = widget.classroom.students
                                    .where((element) => element.present)
                                    .toList()[Random().nextInt(widget
                                        .classroom.students
                                        .where((element) => element.present)
                                        .toList()
                                        .length)]
                                    .name;
                                setState(() {
                                  _randomStudent = randomStudent;
                                });
                                await asyncSleep(100);
                              }
                            },
                            child: const Icon(Icons.shuffle)),
                      )
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child:
                                  Text("Timer", style: TextStyle(fontSize: 30)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${_timerHours.toString().padLeft(2, '0')}:${_timerMinutes.toString().padLeft(2, '0')}:${_timerSeconds.toString().padLeft(2, '0')}",
                                  style: const TextStyle(fontSize: 40)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              _timerHours += 1;
                                            });
                                          },
                                          icon: const Icon(Icons.add)),
                                      IconButton(
                                          onPressed: () async {
                                            if (_timerHours < 1) {
                                              return;
                                            }
                                            setState(() {
                                              _timerHours -= 1;
                                            });
                                          },
                                          icon: const Icon(Icons.remove))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              _timerMinutes += 1;
                                            });
                                          },
                                          icon: const Icon(Icons.add)),
                                      IconButton(
                                          onPressed: () async {
                                            if (_timerMinutes < 1) {
                                              return;
                                            }
                                            setState(() {
                                              _timerMinutes -= 1;
                                            });
                                          },
                                          icon: const Icon(Icons.remove))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              _timerSeconds += 1;
                                            });
                                          },
                                          icon: const Icon(Icons.add)),
                                      IconButton(
                                          onPressed: () async {
                                            if (_timerSeconds < 1) {
                                              return;
                                            }
                                            setState(() {
                                              _timerSeconds -= 1;
                                            });
                                          },
                                          icon: const Icon(Icons.remove))
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _timerHours = 0;
                                            _timerMinutes = 15;
                                            _timerSeconds = 0;
                                          });
                                        },
                                        icon: const Icon(Icons.timer)),
                                  ),
                                  FloatingActionButton(
                                      child: _timerRunning
                                          ? const Icon(Icons.stop)
                                          : const Icon(Icons.play_arrow),
                                      onPressed: () async {
                                        if (_timerRunning) {
                                          setState(() {
                                            _timerRunning = false;
                                          });
                                        } else {
                                          // Convert everything to seconds
                                          int timerRemaining = _timerSeconds +
                                              (_timerMinutes * 60) +
                                              (_timerHours * 60 * 60);
                                          _timerHours = 0;
                                          _timerMinutes = 0;
                                          _timerSeconds = 0;
              
                                          // Change state
                                          setState(() {
                                            _timerRunning = true;
                                          });
              
                                          // Start counting down
                                          for (int i = timerRemaining;
                                              i >= 0 && _timerRunning;
                                              i--) {
                                            setState(() {
                                              _timerHours = i ~/ 3600;
                                              _timerMinutes = (i % 3600) ~/ 60;
                                              _timerSeconds = i % 60;
                                            });
                                            await Future.delayed(
                                                const Duration(seconds: 1));
                                          }
              
                                          // Reset state
                                          setState(() {
                                            _timerRunning = false;
                                          });
                                        }
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _timerHours = 0;
                                            _timerMinutes = 0;
                                            _timerSeconds = 0;
                                            _timerRunning = false;
                                          });
                                        },
                                        icon: const Icon(Icons.refresh)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Card(
                          child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Text("Stopwatch", style: TextStyle(fontSize: 30)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "${_stopwatchsHours.toString().padLeft(2, '0')}:${_stopwatchMinutes.toString().padLeft(2, '0')}:${_stopwatchSeconds.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 40)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          _timerHours = _stopwatchsHours;
                                          _timerMinutes = _stopwatchMinutes;
                                          _timerSeconds = _stopwatchSeconds;
                                        });
                                      },
                                      icon: const Icon(Icons.share_arrival_time)),
                                ),
                                FloatingActionButton(
                                    child: _stopwatchRunning
                                        ? const Icon(Icons.stop)
                                        : const Icon(Icons.play_arrow),
                                    onPressed: () async {
                                      if (_stopwatchRunning) {
                                        setState(() {
                                          _stopwatchRunning = false;
                                        });
                                      } else {
                                        // Convert everything to seconds
                                        int time = 0;
                                        _stopwatchsHours = 0;
                                        _stopwatchMinutes = 0;
                                        _stopwatchSeconds = 0;
              
                                        // Change state
                                        setState(() {
                                          _stopwatchRunning = true;
                                        });
              
                                        // Start counting down
                                        while (_stopwatchRunning) {
                                          setState(() {
                                            _stopwatchsHours = time ~/ 3600;
                                            _stopwatchMinutes =
                                                (time % 3600) ~/ 60;
                                            _stopwatchSeconds = time % 60;
                                          });
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          time++;
                                        }
                                      }
                                    }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          _stopwatchsHours = 0;
                                          _stopwatchMinutes = 0;
                                          _stopwatchSeconds = 0;
                                          _stopwatchRunning = false;
                                        });
                                      },
                                      icon: const Icon(Icons.refresh)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
