import 'package:flutter/material.dart';
import 'package:flutter_frequency_list/datebase_helper.dart';
import 'package:flutter_frequency_list/frequency_list_screen.dart';
import 'package:flutter_frequency_list/main.dart';
import 'package:flutter_frequency_list/task_list_screen.dart';
import 'task_by_frequency.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({super.key});

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  List<Widget> _frequencyList = <Widget>[];

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
        _frequencyList.add(InkWell(
          onTap: () {
            print('---------> Selected Category:');
            print(frequency['_id']);
            print(frequency['frequency']);

            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) =>
                    TaskByFrequency(frequency: frequency['frequency'])));
          },
          child: ListTile(
            title: Text(frequency['frequency']),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Task', style: TextStyle(
                fontSize: 18,
              ),),
              accountEmail: Text('Version 1.0', style: TextStyle(
                fontSize: 15,
              ),),
              currentAccountPicture: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/task_list.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Task List'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskListScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list_rounded),
              title: Text('Frequency List'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FrequencyListScreen()));
              },
            ),
            Divider(),
            Column(
              children: _frequencyList,
            )
          ],
        ),
      ),
    );
  }
}
