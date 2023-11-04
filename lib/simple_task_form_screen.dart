import 'package:flutter/material.dart';
import 'package:flutter_frequency_list/datebase_helper.dart';
import 'package:flutter_frequency_list/main.dart';
import 'package:flutter_frequency_list/task_list_screen.dart';
import 'task_model.dart';

class SimpleTaskFormScreen extends StatefulWidget {
  const SimpleTaskFormScreen({super.key});

  @override
  State<SimpleTaskFormScreen> createState() => _SimpleTaskFormScreenState();
}

class _SimpleTaskFormScreenState extends State<SimpleTaskFormScreen> {
  var _taskController = TextEditingController();
  var _selectedFrequencyValue;
  String selectedPriority = 'High';
  bool statusDefaultValue = false;
  var _frequencyDropdownList = <DropdownMenuItem>[];

  //Edit only
  bool firstTimeFlag = false;
  int _selectedId = 0;
  String buttonText = 'Save';

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
    if (firstTimeFlag == false) {
      print('------> once execute');

      firstTimeFlag = true;

      final task = ModalRoute.of(context)!.settings.arguments;

      if (task == null) {
        print('-------> FAB: Insert'); //save
      } else {
        print('------> Listview clicked: Received Data: Edit/Delete');
        task as TaskModel;

        print('--------> Received Data');
        print(task.id);
        print(task.task);
        print(task.priority);
        print(task.status);

        _selectedId = task.id!;
        _taskController.text = task.task;
        _selectedFrequencyValue = task.frequency;
        buttonText = 'Update';

        //Radio button - Priority
        if (task.priority == 'High') {
          selectedPriority = 'High';
        } else {
          selectedPriority = 'Low';
        }

        //check box - Status
        if (task.status == 'true') {
          statusDefaultValue = true;
        } else {
          statusDefaultValue = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: _selectedId != 0 ? [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text('Delete'),
              ),
            ],
            elevation: 2,
            onSelected: (value) {
              if (value == 1) {
                _deleteFormDialog(context);
              }
            },
          ),
        ] : null,
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
                      if (_selectedId == 0) {
                        print('--------> Save');
                        _save();
                      } else {
                        print('--------> Update');
                        _update();
                      }
                    },
                    child: Text(
                      buttonText,
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

  _update() async {
    String tempStatusValue = 'false';

    if (statusDefaultValue == true) {
      print('-----> Update Status - true');
      tempStatusValue = 'true';
    } else {
      print('-----> Update Status - false');
      tempStatusValue = 'false';
    }

    print('----------> Id: $_selectedId');
    print('----------> Task: $_taskController.text');
    print('----------> Frequency: $_selectedFrequencyValue');
    print('----------> Priority: $selectedPriority');
    print('----------> Status: $tempStatusValue');

    Map<String, dynamic> row = {
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.columnTask: _taskController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
      DatabaseHelper.columnPriority: selectedPriority,
      DatabaseHelper.columnStatus: tempStatusValue,
    };

    final result = await dbHelper.updateData(row, DatabaseHelper.taskTable);

    debugPrint('---------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');

      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TaskListScreen()));
      });
    }
  }

  _deleteFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.deleteData(
                      _selectedId, DatabaseHelper.taskTable);

                  debugPrint('-------> Deleted Row Id: $result');

                  if (result > 0) {
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Deleted');

                    setState(() {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => TaskListScreen()));
                    });
                  }
                },
                child: Text('Delete'),
              ),
            ],
            title: Text('Are you sure, you want to delete this?'),
          );
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
