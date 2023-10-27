import 'package:flutter/material.dart';
import 'package:flutter_frequency_list/datebase_helper.dart';
import 'package:flutter_frequency_list/main.dart';
import 'package:flutter_frequency_list/task_list_screen.dart';


class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  var _taskController = TextEditingController();
  var _selectedFrequencyValue;
  String selectedPriority = 'High';
  bool statusDefaultValue = false;
  var _frequencyDropdownList = <DropdownMenuItem>[];

  @override
  void initState() {
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {
    var frequencies =
    await dbHelper.queryAllRows(DatabaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        _frequencyDropdownList.add(DropdownMenuItem(
          child: Text(frequency['frequency']),
          value: frequency['frequency'],
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  hintText: 'Enter Task',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField(
                      value: _selectedFrequencyValue,
                      items: _frequencyDropdownList,
                      hint: Text('Frequency'),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequencyValue = value;
                          print(_selectedFrequencyValue);
                        });
                      }),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Task Priority',
                    style: TextStyle(fontSize: 20),
                  ),
                  RadioListTile(
                      title: Text(
                        'High',
                        style: TextStyle(fontSize: 18),
                      ),
                      value: 'High',
                      groupValue: selectedPriority,
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value as String;
                          print('------> Task Priority: $value');
                        });
                      }),
                  RadioListTile(
                      title: Text(
                        'Low',
                        style: TextStyle(fontSize: 18),
                      ),
                      value: 'Low',
                      groupValue: selectedPriority,
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value as String;
                          print('------> Task Priority: $value');
                        });
                      }),
                  SizedBox(
                    height: 40,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Checkbox(
                              value: this.statusDefaultValue,
                              onChanged: (value) {
                                setState(() {
                                  this.statusDefaultValue = value!;
                                  print('-------> Status CheckBox: $value');
                                });
                              }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('----> TaskForm: Save');
                      _save();
                    },
                    child: Text('Save',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _save() async {
    String tempStatusValue = 'false';

    if (statusDefaultValue == true) {
      print('-----> Save Status - true');
      tempStatusValue = 'true';
    } else {
      print('-----> Save Status - false');
      tempStatusValue = 'false';
    }

    print('----------> Task: $_taskController.text');
    print('----------> Frequency: $_selectedFrequencyValue');
    print('----------> Priority: $selectedPriority');
    print('----------> Status: $tempStatusValue');

    Map<String, dynamic> row = {
      DatabaseHelper.columnTask: _taskController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
      DatabaseHelper.columnPriority: selectedPriority,
      DatabaseHelper.columnStatus: tempStatusValue,
    };

    final result = await dbHelper.insertData(row, DatabaseHelper.taskTable);

    debugPrint('---------> Inserted Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');

      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => TaskListScreen()));
      });
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
