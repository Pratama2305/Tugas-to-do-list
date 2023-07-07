import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/helpers/dbhelper.dart';
import 'package:todo_list/models/note.dart';
import 'package:todo_list/screen/add_screen.dart';
import 'package:todo_list/screen/notes_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Note> noteList = [];

  @override
  void initState() {
    super.initState();
    updateListView(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddScreen(),
              ),
            );
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, size: 30, color: Colors.blueGrey),
        ),
        appBar: AppBar(
          title: const Text(
            'Todo List',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return NotesCard();
            }));
  }

  Future<Note> navigateToEntryForm(BuildContext context, Note contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AddScreen(Note: Note);
    }));
    return result;
  }

  ListView createListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.people),
            ),
            title: Text(this.noteList[index].title),
            subtitle: Text(this.noteList[index].description),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () {
                deleteNote(noteList[index]);
              },
            ),
            onTap: () async {
              var contact =
                  await navigateToEntryForm(context, this.noteList[index]);
              if (Note.title != '' && Note.description != '') {
                updateListView(Note);
              }
            },
          ),
        );
      },
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Note>> contactListFuture = dbHelper.getNoteList();
      contactListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void deleteNote(Note object) async {
    int result = await dbHelper.delete(object.id);
    if (result > 0) ;
    updateListView();
  }
}
