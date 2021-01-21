import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_list/model/todos.dart';

class CreateTodoListScreen extends StatefulWidget {
  final ScreenMode mode;
  Todos todos;

  CreateTodoListScreen.create() : mode = ScreenMode.Create;

  CreateTodoListScreen.edit({@required this.todos}) : mode = ScreenMode.Edit;

  @override
  _CreateTodoListScreenState createState() => _CreateTodoListScreenState();
}

class _CreateTodoListScreenState extends State<CreateTodoListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _detailC = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.mode == ScreenMode.Edit) {
      _titleC.text = widget.todos.title;
      _detailC.text = widget.todos.detail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create todo list'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleC,
                enabled: !widget.todos.isSuccess,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Title is empty';
                  }

                  return null;
                },
                autofocus: true,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextFormField(
                controller: _detailC,
                enabled: !widget.todos.isSuccess,
                maxLines: 5,
                style: TextStyle(
                  fontSize: 14,
                ),
                decoration: InputDecoration(hintText: 'Detail'),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    if (widget.mode == ScreenMode.Create) {
      return RaisedButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            final todo = Todos(_detailC.text, _titleC.text);
            await Hive.box<Todos>('todos').add(todo);
            await showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text('Success'),
                    actions: [
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          //* Pop dialog
                          Navigator.pop(context);
                          //* Pop screen
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
          }
        },
        child: Text('Create'),
      );
    } else {
      if (widget.todos.isSuccess) {
        return RaisedButton(
          onPressed: () async {
            await showDialog(
                builder: (context) {
                  return AlertDialog(
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('No'),
                      ),
                      FlatButton(
                        onPressed: () {
                          widget.todos.delete();
                          Navigator.pop(context);
                        },
                        child: Text('Yes'),
                      )
                    ],
                    title: Text('Do you have to delete it?'),
                  );
                },
                context: context);
          },
          child: Text('Delete'),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RaisedButton(
            onPressed: () async {
              widget.todos.isSuccess = true;
              widget.todos.save();
            },
            child: Text('Success'),
          ),
          RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                await showDialog(
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('No'),
                          ),
                          FlatButton(
                            onPressed: () {
                              widget.todos.title = _titleC.text;
                              widget.todos.detail = _detailC.text;
                              widget.todos.save();
                              Navigator.pop(context);
                            },
                            child: Text('Yes'),
                          )
                        ],
                        title: Text('Do you want to edit the information?'),
                      );
                    },
                    context: context);
              }
            },
            child: Text('Edit'),
          ),
          RaisedButton(
            onPressed: () async {
              await showDialog(
                  builder: (context) {
                    return AlertDialog(
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('No'),
                        ),
                        FlatButton(
                          onPressed: () {
                            widget.todos.delete();
                            Navigator.pop(context);
                          },
                          child: Text('Yes'),
                        )
                      ],
                      title: Text('Do you have to delete it?'),
                    );
                  },
                  context: context);
            },
            child: Text('Delete'),
          ),
        ],
      );
    }
  }
}

enum ScreenMode { Create, Edit }
