import 'package:expenses/sqlhelper.dart';
import 'package:flutter/material.dart';

TextEditingController textEditingController = new TextEditingController();

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
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

@override
class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  final DbHelper dbHelper = new DbHelper();
  List<Todo> todos = [];

  // Step 1

  void loadData() async {
    await dbHelper.initdb();
    List<Map<String, dynamic>> list = await dbHelper.read();
    setState(() {
      todos = list.map((item) => Todo.fromMap(item)).toList();
    });
  }
  // Step 2 in step two we have to inset our data in todo and use insert function

  void addtodo() async {
    String title = textEditingController.text; // Use text instead of toString
    if (title.isNotEmpty) {
      // Check if title is not empty
      Todo newtodo = Todo(title: title, completed: false);
      await dbHelper.insert(newtodo.toMap());
      loadData();
      textEditingController.clear();
    }
  }

  void delete(int? id) async {
    await dbHelper.delete(id!);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo app'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Enter title'),
            controller: textEditingController,
          ),
          ElevatedButton(
              onPressed: () {
                addtodo();
                print(todos);
              },
              child: Text('+')),
          Expanded(
              child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              return ListTile(
                title: Text(todo.title ?? ''),
                trailing: IconButton(
                    onPressed: () {
                      delete(todo.id);
                    },
                    icon: const Icon(Icons.delete)),
              );
            },
          ))
        ],
      ),
    );
  }
}
