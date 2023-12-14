import 'dart:io';
import 'package:expenses/sqlhelper.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DbHelper dbHelper = DbHelper();
  List<Todo> todos = [];
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await dbHelper.initdb();
    List<Map<String, dynamic>> data = await dbHelper.read();
    setState(() {
      todos = data.map((item) => Todo.fromMap(item)).toList();
    });
  }

  void _addTodo() async {
    String title = _textEditingController.text;
    if (title.isNotEmpty) {
      Todo newTodo = Todo(
        title: title,
        completed: false,
      );
      await dbHelper.insert(newTodo.toMap());
      _textEditingController.clear();
      _loadData();
    }
  }

  void _deleteTodo(int id) async {
    await dbHelper.delete(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Enter a new todo',
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: Text('Add Todo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index];
                return ListTile(
                  title: Text(todo.title ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodo(todo.id ?? 0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
