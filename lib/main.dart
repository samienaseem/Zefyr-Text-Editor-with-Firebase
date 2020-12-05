import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefyr_text_editor/DBHelper/DBHelper.dart';
import 'package:zefyr_text_editor/Model/SavedNotes.dart';

import 'EditorPage.dart';
import 'Model/notes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DBHelper dbHelper=new DBHelper();
  final databaseReference = FirebaseDatabase().reference().child('two');
  Query query=FirebaseDatabase.instance.reference().child('two').orderByKey();
  int count=0;
  List<SavedNotes> list;
  List<notes> nlist;//to store savednotes object return from database
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(nlist==null){
      list=List<SavedNotes>();
      nlist=List<notes>();
      getdata2();
    }

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Container(
        padding:EdgeInsets.all(10.0),
        child: GetListData(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          /*bool result=await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditorPage(new SavedNotes(""))));*/
          bool result=await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditorPage(new notes(""))));

          if(result==true){
            getdata2();
            //GetListData();

          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void getData() {
    final dbfuture=dbHelper.initDatabase(); //return manager
    dbfuture.then((result){
      final Notes=dbHelper.getNotes(); // return list
      Notes.then((result){
        List<SavedNotes> tempList=List<SavedNotes>();
        int count=result.length;
        for(int i=0;i<count;i++){
          tempList.add(SavedNotes.FromObject(result[i])); //result[0] have id and content returned from db in the form of map.
        }
        setState(() {
          list=tempList;
          this.count=count;
          //assign temp list to main list.
        });
      });
    });
  }

 ListView GetListData() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (context,position){
          return Card(
            elevation: 4.0,
            child: Container(
              child: ListTile(
                title: Text((this.nlist[position].key).toString()),
                trailing: IconButton(
                 icon: Icon(Icons.delete),
                  onPressed: (){
                   print("hello");
                   databaseReference.child(this.nlist[position].key).remove();
                   getdata2();
                  },
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute( builder: (context)=>EditorPage(this.nlist[position])));

                },
              ),
            ),
          );
        }
    );
 }

  void getdata2()async{
    var value;
    DataSnapshot snap;
    int cc;
    List<notes> tempList=List<notes>();
    print("hello");
    await databaseReference.once().then((DataSnapshot snapshot){
      print(snapshot.value.entries.length);
      cc=snapshot.value.entries.length;
      for (var val in snapshot.value.entries){
        tempList.add(new notes.name(val.key, val.value['body']));
        print(val.value['body']);
      }
    });
    print(nlist.length);
    setState(() {
      this.nlist=tempList;
      this.count=cc;
    });





  }
  FirebaseAnimatedList GetListData2() {
    return FirebaseAnimatedList(
      query: databaseReference,
        itemBuilder: (context,DataSnapshot snap,Animation<double> anim, position){
          return Card(
            elevation: 4.0,
            child: Container(
              child: ListTile(
                title: Text(snap.key),
                onTap: (){
                  //Navigator.push(context, MaterialPageRoute( builder: (context)=>EditorPage(this.list[position])));
                },
              ),
            ),
          );
        }
    );
  }
}
