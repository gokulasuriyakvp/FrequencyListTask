import 'package:flutter_frequency_list/datebase_helper.dart';
import 'package:flutter_frequency_list/drawer_navigator.dart';
import 'task_model.dart';
import 'main.dart';
import 'package:flutter/material.dart';

class TaskByFrequency extends StatefulWidget {
  String frequency;

  TaskByFrequency({Key? key, required this.frequency}) : super(key: key);

  @override
  State<TaskByFrequency> createState() => _TaskByFrequencyState();
}

class _TaskByFrequencyState extends State<TaskByFrequency> {
  late List<TaskModel> _taskList;

  @override
  void initState() {
    super.initState();
    getTaskByCategories();
  }

  getTaskByCategories() async {
    _taskList = <TaskModel>[];

    print('----------> Received Frequency:');
    print(this.widget.frequency);

    var habits = await dbHelper.readDataByColumnName(DatabaseHelper.taskTable,
        DatabaseHelper.columnFrequency, this.widget.frequency);

    habits.forEach((task) {
      setState(() {
        print(task['_id']);
        print(task['task']);
        print(task['frequency']);
        print(task['priority']);
        print(task['status']);

        var taskModel = TaskModel(task['_id'], task['task'],
            task['frequency'], task['priority'], task['status']);
        _taskList.add(taskModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task - Frequency List'),
      ),
      drawer: DrawerNavigation(),
      body: ListView.builder(
          itemCount: _taskList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    print(_taskList[index].id);
                    print(_taskList[index].task);
                    print(_taskList[index].frequency);
                    print(_taskList[index].priority);
                    print(_taskList[index].status);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(_taskList[index].task ?? 'No Data',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _taskList[index].frequency ?? 'No Data',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
