import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/model/todos.dart';
import 'package:todo_list/screen/create_todo_list_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  TodoStatus _status = TodoStatus.Pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo list'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 16),
            alignment: Alignment.topRight,
            child: DropdownButton(
              value: _status,
              items: [
                DropdownMenuItem(
                  value: TodoStatus.All,
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: TodoStatus.Pending,
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: TodoStatus.Success,
                  child: Text('Success'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value;
                });
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Todos>>(
              valueListenable: Hive.box<Todos>('todos').listenable(),
              builder: (context, box, _) {
                List<Todos> todos;
                switch (_status) {
                  case TodoStatus.All:
                    todos = box.values.toList().cast<Todos>();
                    break;
                  case TodoStatus.Pending:
                    todos = box.values
                        .where((e) => !e.isSuccess)
                        .toList()
                        .cast<Todos>();
                    break;
                  case TodoStatus.Success:
                    todos = box.values
                        .where((e) => e.isSuccess)
                        .toList()
                        .cast<Todos>();
                    break;
                }
                if (todos.isEmpty) {
                  return Center(
                    child: Text('Todo list is empty'),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: todos.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CreateTodoListScreen.edit(
                                      todos: todos[index],
                                    )));
                      },
                      child: Card(
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(start: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      todos[index].title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(todos[index].detail.isEmpty
                                        ? '-'
                                        : todos[index].detail)
                                  ],
                                ),
                              ),
                              todos[index].isSuccess
                                  ? Container()
                                  : IconButton(
                                      icon: Icon(Icons.done),
                                      onPressed: () {
                                        todos[index].isSuccess = true;
                                        todos[index].save();
                                      },
                                    ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await showDialog(
                                      builder: (context) {
                                        return AlertDialog(
                                          actions: [
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                todos[index].delete();
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            )
                                          ],
                                          title:
                                              Text('Do you have to delete it?'),
                                        );
                                      },
                                      context: context);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'create');
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

enum TodoStatus { All, Pending, Success }
