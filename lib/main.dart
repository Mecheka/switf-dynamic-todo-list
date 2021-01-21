import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:todo_list/screen/create_todo_list_screen.dart';
import 'package:todo_list/screen/todo_list_screen.dart';
import 'package:todo_list/model/todos.dart';

Future<void> main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(TodosAdapter());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BehaviorSubject<int> _$selectScreen = BehaviorSubject.seeded(0);

  PageController _controller = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
          future: Hive.openBox<Todos>('todos'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<int>(
                  stream: _$selectScreen,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final _selectScreen = snapshot.data;
                      return Scaffold(
                        body: TodoListScreen(),
                      );
                    }
                    return Container();
                  });
            } else {
              return Scaffold(
                body: Center(
                  child: Text('Someting wrong'),
                ),
              );
            }
          }),
      routes: {
        'create': (BuildContext context) => CreateTodoListScreen.create()
      },
    );
  }

  _changePage(int index) {
    _$selectScreen.add(index);
  }
}
