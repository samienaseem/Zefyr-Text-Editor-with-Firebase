import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'package:zefyr_text_editor/DBHelper/DBHelper.dart';
import 'package:zefyr_text_editor/Model/SavedNotes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zefyr_text_editor/Model/notes.dart';

/*final FirebaseApp app= FirebaseApp(
    options: FirebaseOptions(
      googleAppID: '1:196708944515:android:07b475b289cde2b986a9b6',
      apiKey: 'AIzaSyAHwdk0eiOIk__7eZprzJQZkifLtBXd7nQ',
      databaseURL: 'https://zefyr-firebase-eaa41.firebaseio.com',

    )
);*/

DBHelper helper=DBHelper();
class EditorPage extends StatefulWidget{
  /*SavedNotes _savedNotes;*/
  notes _note;
  EditorPage(this._note);
  @override
  State<StatefulWidget> createState()=>createNote(_note);

}

class createNote extends State{
  notes _notes;
  createNote(this._notes);
  final databaseReference = FirebaseDatabase().reference();
  ZefyrController _controller;
  FocusNode _focusNode;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Note"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ZefyrScaffold(
          child: ZefyrEditor(
            padding: EdgeInsets.all(5.0),
            controller: _controller,
            focusNode: _focusNode,
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context){
          return FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
            onPressed: (){
              save3();
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    final document=_loadDocument();
    _controller=ZefyrController(document);
    _focusNode=FocusNode();
  }

  NotusDocument _loadDocument(){
    if(_notes.key==null) {
      final Delta delta = Delta()..insert("Insert text here\n"); //import quill_delta
      return NotusDocument.fromDelta(delta);
    }
    else{
      print(_notes.content);
      final Delta delta = Delta()..insert(_notes.content.toString()+"\n"); //import quill_delta
      //return NotusDocument.fromDelta(delta);

      //return NotusDocument.fromJson(jsonDecode(_notes.content));
      return NotusDocument.fromJson(jsonDecode(_notes.content));
    }
  }

  /*void save() {
    final content=jsonEncode(_controller.document);
    debugPrint(content.toString());
    _notes.content=content;
    if(_notes.id!=null){
      //write update logic here
    }
    else{
      helper.insertNote(_notes);
    }
    Navigator.pop(context,true);
    //lets try to run it see if any error
    //exception is thrown because we never called initDatabase method of DBHelper class
    //Lets write some more code for that in main.dart .
  }*/
  void save2(){
    final content=jsonEncode(_controller.document);
    debugPrint(databaseReference.toString());
    databaseReference.child('One').push().set({
      'Data':content
    });
    databaseReference.onChildAdded.listen(_onChanged);
  }
  _onChanged(Event event){
    debugPrint("Hogya");
  }

  void save3() {
    if(_notes.key==null) {
      dynamic content = jsonEncode(_controller.document);
      _notes.content = content;
      databaseReference.child("two").push().set({
        'body': content
      });
    }
    else{
      dynamic content = jsonEncode(_controller.document);
      _notes.content = content;
      databaseReference.child('two').child(_notes.key).update(_notes.toJson());
    }

    Navigator.pop(context,true);
  }
}