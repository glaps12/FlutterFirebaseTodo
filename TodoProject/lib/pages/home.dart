import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    _initializeFirebase(); // Initialize Firebase
    _fetchTodos(); // Fetch ToDo items from Firestore
    super.initState();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _fetchTodos() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('todos').get();
      List<ToDo> todos = querySnapshot.docs
          .map((doc) => ToDo.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        _foundToDo = todos;
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: (todo) => _handleToDoChange(todo),
                          onDeleteItem: (id) => _deleteToDoItem(id),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo item',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) async {
    try {
      CollectionReference todosCollection =
          FirebaseFirestore.instance.collection('todos');
      await todosCollection.doc(todo.id!).update({
        'isDone': !todo.isDone,
      });
      setState(() {
        todo.isDone = !todo.isDone;
      });
    } catch (e) {
      print('Error updating todo in Firestore: $e');
    }
  }

  Future<void> _deleteToDoItem(String id) async {
    try {
      CollectionReference todosCollection =
          FirebaseFirestore.instance.collection('todos');
      await todosCollection.doc(id).delete();
      setState(() {
        _foundToDo.removeWhere((item) => item.id == id);
      });
    } catch (e) {
      print('Error deleting todo from Firestore: $e');
    }
  }

  Future<void> _addToDoItem(String toDo) async {
    try {
      String newId = DateTime.now().millisecondsSinceEpoch.toString();
      CollectionReference todosCollection =
          FirebaseFirestore.instance.collection('todos');
      await todosCollection.doc(newId).set(
        ToDo(
          id: newId,
          todoText: toDo,
          isDone: false, // Set isDone to false initially
        ).toMap(),
      );
      _todoController.clear();
      _fetchTodos(); // Fetch updated list of todos after adding
    } catch (e) {
      print('Error adding todo to Firestore: $e');
    }
  }

  

  

  AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: tdBGColor,
    elevation: 0,
    title: Text(
      'TodoApp',
      style: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    ),
    centerTitle: true,
  );
}

}
